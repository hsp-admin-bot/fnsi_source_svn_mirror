DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (4, 141, 190);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4, 'with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info ->> ''medicine_type'' as medicine_type
      , info ->> ''cd'' as cd
      , info ->> ''amount'' as amount
      , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
      , info ->> ''date_interval'' as date_interval
      , info ->> ''timing_cd'' as timing_cd
      , info ->> ''procedure_cd'' as procedure_cd
      , info ->> ''comment'' as comment
      , info ->> ''ind_user_id'' as ind_user_id
      , info ->> ''upd_user_id'' as upd_user_id
      , info ->> ''ind_user_last_name'' as ind_user_last_name
      , info ->> ''upd_user_last_name'' as upd_user_last_name
      , info ->> ''ind_user_first_name'' as ind_user_first_name
      , info ->> ''upd_user_first_name'' as upd_user_first_name
      , info ->> ''no'' as no
			, info
			, rst_dialysis_state
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no in ( @ordNos )
)
select a.* from (select
  ord.*,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN
      CASE
        WHEN medicine_type = ''2'' THEN mix.medicine_mix_name
        ELSE med.medicine_name
      END
    ELSE info ->> ''name''
  END AS medicine_name,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN
      CASE
        WHEN medicine_type = ''2'' THEN mix.medicine_mix_short_name
        ELSE med.medicine_short_name
      END
    ELSE info ->> ''short_name''
  END AS medicine_short_name,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN
      CASE
        WHEN medicine_type = ''2'' THEN mix.unit
        ELSE med.unit
      END
    ELSE info ->> ''unit''
  END AS medicine_unit,
  
  CASE
    WHEN rst_dialysis_state = ''0'' THEN
      CASE
        WHEN medicine_type = ''2'' THEN mix.class_cd
        ELSE med.class_cd
      END
    ELSE (info ->> ''class_cd'') :: NUMERIC
  END AS class_cd,
  CASE WHEN rst_dialysis_state = ''0'' THEN
    CASE WHEN medicine_type = ''2'' THEN
      CASE WHEN mix.class_cd = ''-1'' THEN ''未分類'' ELSE mix_cls.class_name END 
    ELSE
      CASE WHEN med.class_cd = ''-1'' THEN ''未分類'' ELSE med_cls.class_name END 
    END	
  ELSE
      CASE WHEN ( info ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE info ->> ''class_name'' END 
  END AS class_name,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN
      CASE
        WHEN medicine_type = ''2'' THEN mix_cls.class_type
        ELSE med_cls.class_type
      END
    ELSE (info ->> ''class_type'') :: NUMERIC
  END AS class_type,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
    ELSE info ->> ''timing_name''
  END AS medicate_timing_name,
  CASE
    WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
    ELSE info ->> ''procedure_name''
  END AS pricedure_name,
  concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name,
  concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
  
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_1 else mix.in_hospital_cd_1 end as medi_in_hospital_cd_1
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_2 else mix.in_hospital_cd_2 end as medi_in_hospital_cd_2
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_3 else mix.in_hospital_cd_3 end as medi_in_hospital_cd_3
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_4 else '''' end as medi_in_hospital_cd_4
	,case 
	   when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a1
	   when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b1
		 when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a1
		 when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b1
		 when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a1
		 when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b1
		 when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a1
		 else ''''
	 end as procedure_in_hospital_cd_1
	,case 
	   when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
	   when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b2
		 when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a2
		 when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b2
		 when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a2
		 when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b2
		 when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a2
		 else ''''
	 end as procedure_in_hospital_cd_2
  ,save.receipt_value
  ,save.receipt_unit
  ,ms.index
  ,dmed_cls.code_order as med_cls_cd
  ,dmed.code_order as med_cd
  ,dmed_mix.code_order as med_mix_cd
  ,dtim.code_order as med_timing_cd
  ,dpro.code_order as med_pro_cd
from
  ord_tbl as ord
  left join mst_medicine as  med  on (ord.cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord.facility_cd and ord.medicine_type = ''1'')
  left join mst_medicine_mix as  mix  on (ord.cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and mix.facility_cd = ord.facility_cd and ord.medicine_type = ''2'')
  left join mst_medicine_class as med_cls on (med.class_cd = med_cls.class_cd)
  left join mst_medicine_class as mix_cls on (mix.class_cd = mix_cls.class_cd)
  left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
  left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd::text)
  left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1'' and supplies_class != ''20'')
  and save.medicine_no ->>''no'' = ord.no
  left join (SELECT
	index_no AS code_order,
	TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
	order_cd ->> ''name'' AS medi_class_code_name
  FROM
	mst_selector
	CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
	facility_cd = @facilityCd
	AND master_physical_name = ''mst_medicine_class'') as dmed_cls on dmed_cls.medi_class_code = med.class_cd or dmed_cls.medi_class_code = mix.class_cd
  left join (SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine'') as dmed on dmed.medi_class_code = med.medicine_cd
  left join (SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix'') as dmed_mix on dmed_mix.medi_class_code = mix.medicine_mix_cd
  left join (SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicate_timing'') as dtim on dtim.medi_class_code = tim.medicate_timing_cd
  left join (	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_procedure'') as dpro on dpro.medi_class_code = pro.procedure_cd
  left join ( SELECT
    mss.facility_cd,
    ms.*,
    ROW_NUMBER ( ) OVER ( ) AS INDEX 
  FROM
    mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset ( mss.order_settings -> ''items'' ) AS ms ( code BIGINT, NAME TEXT ) 
  WHERE
    facility_cd = @facilityCd 
    AND master_physical_name = ''mst_medicine'' ) as ms on med.facility_cd = ms.facility_cd and med.medicine_cd = ms.code
      
   ) a
  where
    a.class_cd IN (@medIds)
  order by
    a.treat_date,
    a.index
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "medicine_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @ordNo 使用', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (141, 'WITH dmed_cls AS(
  SELECT
    index_no AS code_order,
    TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
    order_cd ->> ''name'' AS medi_class_code_name 
  FROM
    mst_selector
    CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no ) 
  WHERE
    facility_cd = ''NKKSBR'' 
    AND master_physical_name = ''mst_medicine_class'' 
)
, dmed AS(
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicine''
)
, dmed_mix AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicine_mix''
)
, dtim AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicate_timing''
)
, dpro AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_procedure''
)
 
SELECT
  A.json_idx,
  A.f_medi_cd,
  A.medicine_name AS f_medi_name,
  A.f_medi_amount,
  A.medicine_unit AS f_medicine_unit,
  A.medicine_type,
  ARRAY_AGG ( A.f_week ) AS f_week,
  A.ord_no,
  A.treat_date,
  A.medi_no as no,
  dmed_cls.code_order AS med_cls_cd,
  dmed.code_order AS med_cd,
  dmed_mix.code_order AS med_mix_cd,
  dtim.code_order as med_timing_cd,
  dpro.code_order as med_pro_cd,
  A.date_interval
FROM
  (
  SELECT
    weekmedi_info.json_idx,
    weekmedi_info.cd AS f_medi_cd,
    mmd.medicine_name AS medicine_name,
    weekmedi_info.amount AS f_medi_amount,
    mmd.unit AS medicine_unit,
    weekmedi_info.medicine_type,
    weekmedi_info.week AS f_week,
    weekmedi_info.ord_no,
    weekmedi_info.treat_date,
    weekmedi_info.medi_no,
    weekmedi_info.timing_cd,
    weekmedi_info.procedure_cd,
    weekmedi_info.date_interval
  FROM
    (
    SELECT DISTINCT
      json_idx,
      ord.ord_no,
      ord.treat_date,
      medi ->> ''cd'' AS cd,
      CAST ( medi ->> ''amount'' AS DECIMAL ) AS amount,
      medi ->> ''medicine_type'' AS medicine_type,
      medi ->> ''unit'' AS unit,
      medi ->> ''no'' AS medi_no,
      CAST ( medi ->> ''timing_cd'' AS DECIMAL ) AS timing_cd,
      CAST ( medi ->> ''procedure_cd'' AS DECIMAL ) AS procedure_cd,
      CAST ( medi ->> ''date_interval'' AS DECIMAL ) AS date_interval,
    CASE
        ord.treat_week 
        WHEN 1 THEN
        ''月'' 
        WHEN 2 THEN
        ''火'' 
        WHEN 3 THEN
        ''水'' 
        WHEN 4 THEN
        ''木'' 
        WHEN 5 THEN
        ''金'' 
        WHEN 6 THEN
        ''土'' 
        WHEN 7 THEN
        ''日'' ELSE''未'' 
      END AS week 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: JSON ) WITH ORDINALITY AS tmp ( medi, json_idx ) 
    WHERE
      ord.facility_cd = @facilityCd 
      AND ord.treat_date BETWEEN to_char( date_trunc( ''day'', ( @fromDate ) :: TIMESTAMP ), ''yyyymmdd'' ) 
      AND to_char( date_trunc( ''day'', ( @toDate ) :: TIMESTAMP ) + ''1 days - 1 milliseconds'', ''yyyymmdd'' ) 
      AND ord.pat_id = @patId 
      AND ord.is_del = ''0'' 
    ORDER BY
      medi_no,
      cd,
      amount,
      unit,
      week
    ) AS weekmedi_info
    INNER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( weekmedi_info.cd, ''999999999999'' ) 
    AND mmd.class_cd IN ( @medIds ) 
  WHERE
    weekmedi_info.medicine_type = ''1''
    
  UNION ALL
  
  SELECT
    weekmedi_info.json_idx,
    weekmedi_info.cd AS f_medi_cd,
    mix.medicine_mix_name AS medicine_name,
    weekmedi_info.amount AS f_medi_amount,
    mix.unit AS medicine_unit,
    weekmedi_info.medicine_type,
    weekmedi_info.week AS f_week,
    weekmedi_info.ord_no,
    weekmedi_info.treat_date,
    weekmedi_info.medi_no,
    weekmedi_info.timing_cd,
    weekmedi_info.procedure_cd,
    weekmedi_info.date_interval
  FROM
    (
    SELECT DISTINCT
      json_idx,
      ord.ord_no,
      ord.treat_date,
      medi ->> ''cd'' AS cd,
      CAST ( medi ->> ''amount'' AS DECIMAL ) AS amount,
      medi ->> ''medicine_type'' AS medicine_type,
      medi ->> ''unit'' AS unit,
      medi ->> ''no'' AS medi_no,
      CAST ( medi ->> ''timing_cd'' AS DECIMAL ) AS timing_cd,
      CAST ( medi ->> ''procedure_cd'' AS DECIMAL ) AS procedure_cd,
      CAST ( medi ->> ''date_interval'' AS DECIMAL ) AS date_interval,
    CASE
        ord.treat_week 
        WHEN 1 THEN
        ''月'' 
        WHEN 2 THEN
        ''火'' 
        WHEN 3 THEN
        ''水'' 
        WHEN 4 THEN
        ''木'' 
        WHEN 5 THEN
        ''金'' 
        WHEN 6 THEN
        ''土'' 
        WHEN 7 THEN
        ''日'' ELSE''未'' 
      END AS week 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: JSON ) WITH ORDINALITY AS tmp ( medi, json_idx ) 
    WHERE
      ord.facility_cd = @facilityCd 
      AND ord.treat_date BETWEEN to_char( date_trunc( ''day'', ( @fromDate ) :: TIMESTAMP ), ''yyyymmdd'' ) 
      AND to_char( date_trunc( ''day'', ( @toDate ) :: TIMESTAMP ) + ''1 days - 1 milliseconds'', ''yyyymmdd'' ) 
      AND ord.pat_id = @patId 
      AND ord.is_del = ''0'' 
    ORDER BY
      medi_no,
      cd,
      amount,
      unit,
      week
    ) AS weekmedi_info
    INNER JOIN mst_medicine_mix AS mix ON mix.medicine_mix_cd = TO_NUMBER( weekmedi_info.cd, ''999999999999'' ) 
    AND mix.class_cd IN ( @medIds ) 
  WHERE
    weekmedi_info.medicine_type = ''2'' 
  ) A
  LEFT JOIN mst_medicine as med on (A.f_medi_cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and A.medicine_type = ''1'')
  LEFT JOIN mst_medicine_mix as mix on (A.f_medi_cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and A.medicine_type = ''2'')
  LEFT JOIN dmed_cls ON dmed_cls.medi_class_code = med.class_cd or dmed_cls.medi_class_code = mix.class_cd
  LEFT JOIN dmed ON dmed.medi_class_code = med.medicine_cd
  LEFT JOIN dmed_mix ON dmed_mix.medi_class_code = mix.medicine_mix_cd
  LEFT JOIN dtim ON dtim.medi_class_code = A.timing_cd
  LEFT JOIN dpro ON dpro.medi_class_code = A.procedure_cd
  GROUP BY
    A.json_idx,
    A.f_medi_cd,
    A.medicine_name,
    A.f_medi_amount,
    A.medicine_unit,
    A.medicine_type,
    A.ord_no,
    A.treat_date,
    A.medi_no,
    dmed_cls.code_order,
    dmed.code_order,
    dmed_mix.code_order,
    dtim.code_order,
    dpro.code_order,
    A.date_interval', 2, '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_cd", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', '指示：投薬(未来有効） @patId 使用', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'WITH  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info
      , rst_dialysis_state
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no =  @ordNo
),
medicine_order AS (

  select
    one_json ->> ''code'' as medicine_cd
    , json_idx as medicine_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_medicine''

),
medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = @facilityCd
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
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
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    facility_cd  = @facilityCd
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    facility_cd  = @facilityCd
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    facility_cd  = @facilityCd
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
, dmed_cls AS(
  SELECT
    index_no AS code_order,
    TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
    order_cd ->> ''name'' AS medi_class_code_name 
  FROM
    mst_selector
    CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no ) 
  WHERE
    facility_cd = ''NKKSBR'' 
    AND master_physical_name = ''mst_medicine_class'' 
)
, dmed AS(
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicine''
)
, dmed_mix AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicine_mix''
)
, dtim AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_medicate_timing''
)
, dpro AS (
  SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
  FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_procedure''
)
select
  A.*,save.receipt_value,
  save.receipt_unit,
  dmed_cls.code_order AS med_cls_cd,
  dmed.code_order AS med_cd,
  dtim.code_order as med_timing_cd,
  dpro.code_order as med_pro_cd
from (
select
   json_idx
   , ord_no
   , ord.facility_cd
   , ord.treat_date
   , ord.treat_date as dial_treat_date
   , info ->> ''cd'' as cd
   , info ->> ''no'' as no
   , info ->> ''timing_cd'' as timing_cd
   , info ->> ''procedure_cd'' as procedure_cd
   
   , CASE
      WHEN rst_dialysis_state = ''0'' THEN med.medicine_name
      ELSE info ->> ''name''
    END AS medicine_name

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN med.medicine_short_name
      ELSE info ->> ''short_name''
     END AS medicine_short_name

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN med.unit
      ELSE info ->> ''unit''
     END AS medicine_unit

   , info ->> ''medicine_type'' as medicine_type
   , cast(info ->> ''amount'' AS NUMERIC) as amount
   
   , CASE
      WHEN rst_dialysis_state = ''0'' THEN med.class_cd
      ELSE ( info ->> ''class_cd'' ) :: NUMERIC
     END AS class_cd
   
	 , CASE WHEN ord.rst_dialysis_state = ''0'' THEN
	        CASE WHEN med.class_cd = ''-1'' THEN ''未分類'' ELSE med_cls.class_name END 
		 ELSE			
	        CASE WHEN ( ord.info ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE ord.info ->> ''class_name'' END
		 END as class_name		

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN med_cls.class_type
      ELSE ( info ->> ''class_type'' ) :: NUMERIC
     END AS class_type

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
      ELSE info ->> ''timing_name''
     END AS medicate_timing_name

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
      ELSE info ->> ''procedure_name''
     END AS procedure_name

   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , concat(info ->> ''ind_user_last_name'', info ->> ''ind_user_first_name'') AS ind_user_name
   , concat(info ->> ''upd_user_last_name'', info ->> ''upd_user_first_name'') AS upd_user_name
   , med.in_hospital_cd_1 as medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as medi_in_hospital_cd_4
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a1
		  else ''''
	  end as procedure_in_hospital_cd_1
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a2
		  else ''''
	  end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  inner join medicine_tbl as med on info ->> ''cd'' = med.medicine_cd::text AND med.class_cd IN ( @medIds )
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''1''

union all

select
     json_idx
   , ord_no
   , ord.facility_cd
   , ord.treat_date
   , ord.treat_date as dial_treat_date
   , mixtemp.medi_cd  :: text  as cd
   , info ->> ''no'' as no
   , info ->> ''timing_cd'' as timing_cd
   , info ->> ''procedure_cd'' as procedure_cd
   , med.medicine_name
   , med.medicine_short_name
   , med.unit as medicine_unit
   , ''1'' as medicine_type
   
   , CASE
      WHEN mixtemp.solvent = ''1'' THEN mixtemp.amount :: NUMERIC
      ELSE (info ->> ''amount'') :: NUMERIC * mixtemp.amount :: NUMERIC
    END AS amount
   
   , med.class_cd as class_cd
   , CASE
      WHEN med.class_cd = ''-1'' THEN ''未分類''
      ELSE med_cls.class_name
     END as class_name

   , CASE
      WHEN med.class_cd = ''-1'' THEN ''0''
      ELSE med_cls.class_type
     END as class_type
     
   , CASE
      WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
      ELSE info ->> ''timing_name''
     END AS medicate_timing_name

   , CASE
      WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
      ELSE info ->> ''procedure_name''
     END AS procedure_name

   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , concat(info ->> ''ind_user_last_name'', info ->> ''ind_user_first_name'') AS ind_user_name
   , concat(info ->> ''upd_user_last_name'', info ->> ''upd_user_first_name'') AS upd_user_name
   , med.in_hospital_cd_1 as medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as medi_in_hospital_cd_4
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b1
		  when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a1
		  else ''''
	  end as procedure_in_hospital_cd_1
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) = date_trunc(''day'', pro.in_hosp_b_startdate) and (ord.treat_date :: TIMESTAMP) >= date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_a2
		  else ''''
	  end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= info ->> ''cd'' AND mixtemp.class_cd IN ( @medIds ))
  left join medicine_tbl as med on  med.medicine_cd::text = mixtemp.medi_cd
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''2''
) A
  left join medicine_order O on (A.cd = O.medicine_cd)
  left join ord_material_save as save on (save.supplies_base_no = A.ord_no and A.facility_cd = save.facility_cd and A.cd  = save.supplies_cd and save.supplies_source_class = ''1'' 
  and save.ind_rst_class =''1'' and (save.supplies_class = ''12'' or save.supplies_class = ''20'') and save.medicine_no ->>''no'' = A.no)
  left join dmed_cls ON dmed_cls.medi_class_code = A.class_cd
  LEFT JOIN dmed ON dmed.medi_class_code :: text = A.cd
  LEFT JOIN dtim ON dtim.medi_class_code :: text = A.timing_cd
  LEFT JOIN dpro ON dpro.medi_class_code :: text = A.procedure_cd
order by
  json_idx asc,
  medicine_cd_order asc
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(分解)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "dial_treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "dial_medi_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "dial_ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dial_upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(分解)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
