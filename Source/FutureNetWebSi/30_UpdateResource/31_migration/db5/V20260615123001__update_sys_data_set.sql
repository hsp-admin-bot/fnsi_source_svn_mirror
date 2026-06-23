DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (4, 190);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4, 'WITH ord_tbl AS (
	SELECT
			ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, ind_medi_info
	FROM
		ord_main
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
	ORDER BY treat_date
)
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) as medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) AS class_cd
		, info ->> ''class_name'' AS class_name
		, CAST(info ->> ''class_type'' AS INTEGER) AS class_type
		, info ->> ''cd'' as cd
		, info ->> ''name'' AS medicine_name
		, info ->> ''short_name'' AS medicine_short_name
		, info ->> ''amount'' AS amount
		, info ->> ''unit'' AS unit
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' AS timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' AS procedure_name
		, (info ->> ''date_interval'')::NUMERIC as date_interval
		, info ->> ''comment'' as comment
		, info ->> ''ind_user_id'' as ind_user_id
		, info ->> ''upd_user_id'' as upd_user_id
		, info ->> ''ind_user_last_name'' as ind_user_last_name
		, info ->> ''upd_user_last_name'' as upd_user_last_name
		, info ->> ''ind_user_first_name'' as ind_user_first_name
		, info ->> ''upd_user_first_name'' as upd_user_first_name
	FROM
		ord_tbl ord
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info)
)
, selector_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name,
    master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_mix'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, med_tbl AS (
		SELECT
			ord.ord_no
      , ord.facility_cd
      , ord.treat_date
      , ord.treat_week
      , ord.rst_dialysis_state
			, ord.init_date
			, ord.no
			, ord.cd
			, ord.medicine_type
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.class_cd
						ELSE med.class_cd
					END
				ELSE ord.class_cd
			END AS class_cd
			, CASE WHEN rst_dialysis_state = ''0'' THEN
				CASE WHEN mix.class_cd = -1 THEN ''未分類'' ELSE med_cls.class_name END 
			ELSE
				CASE WHEN ord.class_cd = -1 THEN ''未分類'' ELSE ord.class_name END 
			END AS class_name
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN med_cls.class_type
				ELSE ord.class_type
			END AS class_type
			
      , CASE
          WHEN medicine_type = 1 THEN ord.cd
          ELSE null
        END AS medicine_cd
      , CASE
          WHEN medicine_type = 2 THEN ord.cd
          ELSE null
        END AS medicine_mix_cd  
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.medicine_mix_name
						ELSE med.medicine_name
					END
				ELSE ord.medicine_name
			END AS medicine_name,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.medicine_mix_short_name
						ELSE med.medicine_short_name
					END
				ELSE ord.medicine_short_name
			END AS medicine_short_name,
			ord.amount,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.unit
						ELSE med.unit
					END
				ELSE ord.unit
			END AS medicine_unit,
			ord.comment, 
			
			ord.timing_cd,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
				ELSE ord.timing_name
			END AS medicate_timing_name,
			
			ord.procedure_cd,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
				ELSE ord.procedure_name
			END AS pricedure_name
			
			, ord.date_interval
			
			, ord.ind_user_id
			, ord.ind_user_last_name
			, ord.upd_user_last_name
			, concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
			, ord.upd_user_id
			, ord.ind_user_first_name
			, ord.upd_user_first_name
			, concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
			
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_1 else mix.in_hospital_cd_1 end as medi_in_hospital_cd_1
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_2 else mix.in_hospital_cd_2 end as medi_in_hospital_cd_2
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_3 else mix.in_hospital_cd_3 end as medi_in_hospital_cd_3
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_4 else '''' end as medi_in_hospital_cd_4
			,CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a1
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
				ELSE ''''
			END AS procedure_in_hospital_cd_1
			,CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a2
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
				ELSE ''''
			END AS procedure_in_hospital_cd_2
			,save.receipt_value
			,save.receipt_unit
		from
			med_info as ord
			left join mst_medicine as med on (ord.cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord.facility_cd and ord.medicine_type = 1)
			left join mst_medicine_mix as mix on (ord.cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and mix.facility_cd = ord.facility_cd and ord.medicine_type = 2)
			LEFT JOIN mst_medicine_class as med_cls on (rst_dialysis_state = ''0'' AND med.class_cd = med_cls.class_cd and ord.medicine_type = 1) OR (rst_dialysis_state = ''0'' AND mix.class_cd = med_cls.class_cd and ord.medicine_type = 2) 
			left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
			left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd::text)
			left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1'' and supplies_class != ''20'')
			and save.medicine_no ->>''no'' = ord.no::TEXT
)
, med_order_tbl AS (
	SELECT
		m.*
		, dmed_cls.code_order AS class_order
		, dmed.code_order as code_order
		, dmed_mix.code_order as code_mix_order
		, dtim.code_order as timing_order
		, dpro.code_order as proc_order
	FROM
		med_tbl m
	LEFT JOIN selector_sort as dmed_cls on dmed_cls.code = m.class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
	LEFT JOIN selector_sort as dmed on dmed.code = CAST(m.medicine_cd AS INTEGER) AND dmed.master_physical_name = ''mst_medicine''
	LEFT JOIN selector_sort as dmed_mix on dmed_mix.code = CAST(m.medicine_mix_cd AS INTEGER) AND dmed_mix.master_physical_name = ''mst_medicine_mix''
	LEFT JOIN selector_sort as dtim on dtim.code = CAST(m.timing_cd AS INTEGER) AND dtim.master_physical_name = ''mst_medicate_timing''
	LEFT JOIN selector_sort as dpro on dpro.code = CAST(m.procedure_cd AS INTEGER) AND dpro.master_physical_name = ''mst_procedure''
	WHERE
		m.class_cd IN (@medIds)
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
	
SELECT * FROM med_order_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,							 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "medicine_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @patIds @facilityCd @ordNos @medIds', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'WITH ord_tbl AS (
	SELECT
			ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, ind_medi_info
	FROM
		 ord_main
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
)
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) as medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) as class_cd
		, info ->> ''class_name'' as class_name
		, CAST(info ->> ''class_type'' AS INTEGER) as class_type
		, info ->> ''cd'' as cd
		, info ->> ''name'' as medicine_name
		, info ->> ''short_name'' as medicine_short_name
		, CAST(info ->> ''amount'' AS NUMERIC) as amount
		, info ->> ''unit'' AS unit
		, info ->> ''comment'' as comment
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' as timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' as procedure_name
		, CAST(info ->> ''date_interval'' AS INTEGER) as date_interval
		, info ->> ''ind_user_id'' as ind_user_id
		, info ->> ''upd_user_id'' as upd_user_id
		, info ->> ''ind_user_first_name'' as ind_user_first_name
		, info ->> ''ind_user_last_name'' as ind_user_last_name
		, info ->> ''upd_user_first_name'' as upd_user_first_name
		, info ->> ''upd_user_last_name'' as upd_user_last_name
	FROM
			ord_tbl
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info)
)
, selector_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name,
    master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, medicine_mix_tbl as (
	select
		 mix.*
		, medimix ->> ''cd'' as medi_cd
		, medimix ->> ''amount'' as amount
		, medimix ->> ''solvent'' as solvent
	from
		mst_medicine_mix mix
		CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
	where
		mix.facility_cd  = @facilityCd
	and
		mix.is_disp = ''1''
	and
		mix.is_del = ''0''
)
, med_tbl AS (
	select
		ord_no
		, ord.facility_cd
		, ord.treat_date
		, ord.treat_date as dial_treat_date
		, ord.no
		, ord.medicine_type
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.class_cd
			ELSE ord.class_cd
		 END AS class_cd
		, CASE WHEN ord.rst_dialysis_state = ''0'' THEN
					CASE WHEN med.class_cd = -1 THEN ''未分類'' ELSE med_cls.class_name END 
		 ELSE			
					CASE WHEN ord.class_cd = -1 THEN ''未分類'' ELSE ord.class_name END
		 END as class_name		
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med_cls.class_type
			ELSE ord.class_type
		 END AS class_type
		 
		, ord.cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.medicine_name
			ELSE ord.medicine_name
		END AS medicine_name
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.medicine_short_name
			ELSE ord.medicine_short_name
		 END AS medicine_short_name
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.unit
			ELSE ord.unit
		 END AS medicine_unit
		, ord.amount
		
		, ord.timing_cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
			ELSE ord.timing_name
		 END AS medicate_timing_name

		, ord.procedure_cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
			ELSE ord.procedure_name
		 END AS procedure_name

		, ord.init_date
		, ord.date_interval
		, ord.comment
		, ord.ind_user_id
		, ord.upd_user_id
		, concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
		, concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
		, med.in_hospital_cd_1 as medi_in_hospital_cd_1
		, med.in_hospital_cd_2 as medi_in_hospital_cd_2
		, med.in_hospital_cd_3 as medi_in_hospital_cd_3
		, med.in_hospital_cd_4 as medi_in_hospital_cd_4

		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a1
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
			ELSE ''''
		END AS procedure_in_hospital_cd_1
		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS procedure_in_hospital_cd_2,
		save.receipt_value,
		save.receipt_unit
from
  med_info as ord
  inner join mst_medicine as med on ord.cd = med.medicine_cd::text AND ord.facility_cd = med.facility_cd AND med.is_del = ''0'' AND med.is_disp = ''1''
  left join mst_medicine_class as med_cls on med.class_cd = med_cls.class_cd AND ord.facility_cd = med_cls.facility_cd AND med_cls.is_del = ''0'' AND med_cls.is_disp = ''1''
  left join mst_medicate_timing as tim on ord.timing_cd = tim.medicate_timing_cd::text AND ord.facility_cd = tim.facility_cd AND tim.is_del = ''0'' AND tim.is_disp = ''1'' 
  left join mst_procedure as pro on ord.procedure_cd = pro.procedure_cd::text AND ord.facility_cd = pro.facility_cd AND pro.is_del = ''0'' AND pro.is_disp = ''1''
	left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' 
  and save.ind_rst_class =''1'' and save.supplies_class = ''12'' and save.medicine_no ->>''no'' = ord.no::TEXT)
where
	ord.medicine_type = 1

union all

select
     ord_no
   , ord.facility_cd
   , ord.treat_date
   , ord.treat_date as dial_treat_date
	 , ord.no
	 , 1 as medicine_type
	 , med.class_cd as class_cd
   , CASE
      WHEN med.class_cd = -1 THEN ''未分類''
      ELSE med_cls.class_name
     END as class_name
   , CASE
      WHEN med.class_cd = -1 THEN 0
      ELSE med_cls.class_type
     END as class_type
		 
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.medicine_short_name
   , med.unit as medicine_unit
   , CASE
      WHEN mixtemp.solvent = ''1'' THEN mixtemp.amount :: NUMERIC
      ELSE ord.amount * mixtemp.amount :: NUMERIC
    END AS amount

		, ord.timing_cd
		, CASE
      WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
      ELSE ord.timing_name
     END AS medicate_timing_name

		, ord.procedure_cd
		, CASE
      WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
      ELSE ord.procedure_name
     END AS procedure_name

   , ord.init_date
   , ord.date_interval
   , ord.comment
   , ord.ind_user_id
   , ord.upd_user_id
   , concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
   , concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
   , med.in_hospital_cd_1 as medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as medi_in_hospital_cd_4
	 ,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a1
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
			ELSE ''''
		END AS procedure_in_hospital_cd_1
		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS procedure_in_hospital_cd_2,
		save.receipt_value,
		save.receipt_unit
from
  med_info as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= ord.cd)
  left join mst_medicine as med on  med.medicine_cd::text = mixtemp.medi_cd AND ord.facility_cd = med.facility_cd AND med.is_del = ''0'' AND med.is_disp = ''1''
	left join mst_medicine_class as med_cls on med.class_cd = med_cls.class_cd AND ord.facility_cd = med_cls.facility_cd AND med_cls.is_del = ''0'' AND med_cls.is_disp = ''1'' 
	left join mst_medicate_timing as tim on ord.timing_cd = tim.medicate_timing_cd::text AND ord.facility_cd = tim.facility_cd AND tim.is_del = ''0'' AND tim.is_disp = ''1''
	left join mst_procedure as pro on ord.procedure_cd = pro.procedure_cd::text AND ord.facility_cd = pro.facility_cd AND pro.is_del = ''0'' AND pro.is_disp = ''1''
	left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd  = save.supplies_cd and save.supplies_source_class = ''1'' 
  and save.ind_rst_class =''1'' and save.supplies_class = ''20'' and save.medicine_no ->>''no'' = ord.no::TEXT)
where
	ord.medicine_type = 2
)
, med_order_tbl AS (
	select
		m.*,
		dmed_cls.code_order AS class_order,
		dmed.code_order AS code_order,
		0 AS code_mix_order,
		dtim.code_order as timing_order,
		dpro.code_order as proc_order
	from
		med_tbl m
  LEFT JOIN selector_sort AS dmed_cls ON dmed_cls.code = m.class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
  LEFT JOIN selector_sort AS dmed ON dmed.code :: text = m.cd AND dmed.master_physical_name = ''mst_medicine''
  LEFT JOIN selector_sort AS dtim ON dtim.code :: text = m.timing_cd AND dtim.master_physical_name = ''mst_medicate_timing''
  LEFT JOIN selector_sort AS dpro ON dpro.code :: text = m.procedure_cd AND dpro.master_physical_name = ''mst_procedure''
	WHERE
		m.class_cd IN ( @medIds )
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
	
SELECT * FROM med_order_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,        			 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(分解)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "dial_treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "dial_medi_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "dial_ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dial_upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(分解)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬(分解) @patIds @facilityCd @ordNos @medIds', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
