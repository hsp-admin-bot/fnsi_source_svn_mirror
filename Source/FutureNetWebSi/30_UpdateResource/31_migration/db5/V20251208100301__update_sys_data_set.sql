DELETE FROM "ntss"."sys_data_set" where sql_cd in (4, 74, 97, 188, 190, 200);
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
  ord.*
  ,case
    when medicine_type = ''2'' then mix.medicine_mix_name
    else med.medicine_name
  end as medicine_name,
  case
    when medicine_type = ''2'' then mix.unit
    else med.unit
  end as medicine_unit,
  case
    when medicine_type = ''2'' then mix.class_cd
    else med.class_cd
  end as class_cd,
CASE WHEN rst_dialysis_state = ''0'' THEN
	CASE WHEN medicine_type = ''2'' THEN
		CASE WHEN mix.class_cd = ''-1'' THEN ''未分類'' ELSE mix_cls.class_name END 
	ELSE
		CASE WHEN med.class_cd = ''-1'' THEN ''未分類'' ELSE med_cls.class_name END 
	END	
ELSE
		CASE WHEN ( info ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE info ->> ''class_name'' END 
END AS class_name,    
CASE when medicine_type = ''2'' then mix_cls.class_type
    else med_cls.class_type
  end as class_type,
  tim.medicate_timing_name,
  pro.pricedure_name
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
  ,med.unit_second
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
    LEFT JOIN ( select
                         mss.facility_cd, ms.*, row_number() over() as index
                 from
                         mst_selector mss
                 cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
                 (
                         code bigint,
                         name text
                 )
                 where

                         facility_cd = @facilityCd
                 and

                         master_physical_name = ''mst_medicine'' ) as ms
                                                 on med.facility_cd = ms.facility_cd
       and
             med.medicine_cd = ms.code ) a   where a.class_cd IN (@medIds)
          order by
					a.treat_date,
             a.index
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "medicine_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @ordNo 使用', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (74, 'WITH ord_key_tbl AS ( SELECT facility_cd FROM ord_main
WHERE
	ord_no in ( @ordNos )
AND is_del = ''0'' limit 1),
dialyzer_tbl AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		mst_dialyzer.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_dialyzer.is_disp = ''1''
		AND mst_dialyzer.is_del = ''0''
	),
	equipment_tbl AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		mst_equipment.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_equipment.is_disp = ''1''
		AND mst_equipment.is_del = ''0''
	),
	equipment_class_tbl AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		mst_equipment_class.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_equipment_class.is_disp = ''1''
		AND mst_equipment_class.is_del = ''0''
	),
	dialyzer AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_dialyzer''
	),
	equipment AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_equipment''
	),
	equipment_class AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_equipment_class''
	),
	ord_tbl AS (
	SELECT
		facility_cd,
		json_idx,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date_start,
		info ->> ''class_cd'' AS class_cd,
		info ->> ''class_name'' AS class_name,
		info ->> ''class_type'' AS class_type,
		info ->> ''equip_type'' AS equip_type,
		info ->> ''cd'' AS cd,
		info ->> ''amount'' AS amount,
		info ->> ''ind_user_id'' AS ind_user_id,
		info ->> ''ind_user_last_name'' AS ind_user_last_name,
		info ->> ''ind_user_first_name'' AS ind_user_first_name,
		info ->> ''upd_user_id'' AS upd_user_id,
		info ->> ''upd_user_last_name'' AS upd_user_last_name,
		info ->> ''upd_user_first_name'' AS upd_user_first_name,
		info ->> ''input_class'' AS input_class,
		info ->> ''is_editable'' AS is_editable,
		info ->> ''needle_type'' AS needle_type,
		info ->> ''cop_order_no'' AS cop_order_no,
		ord_no,
		rst_dialysis_state
	FROM
		ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( ind_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )
	WHERE
		ord_no in ( @ordNos )
		AND is_del = ''0''
	), b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
	   ord_no in ( @ordNos )
     and
       is_del = ''0''
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
),g as (
select
-- 終了予定
b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
-- 終了予測
CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS ind_end_date_time
-- 透析開始
, b.rst_start_date
-- 透析終了
, b.rst_end_date
, b.ord_no as ordnob
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)
SELECT g.*,
	1 AS dis_order,
	ord.*,
	-1 AS equip_class_cd,
	dia.model_number AS equip_name,
	dia.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	dia.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	dia.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	dia.in_hospital_cd_4 AS equip_in_hospital_cd_4,
	NULL AS equip_unit,
	NULL AS equip_class_name,
	NULL AS equip_class_type,
	diaz.code_order AS code_order,
	NULL AS class_order
FROM

	ord_tbl AS ord
	INNER JOIN dialyzer_tbl AS dia ON ord.cd = dia.dialyzer_cd :: TEXT
	AND equip_type = ''1''
	AND dia.dialyzer_cd IN ( @diaIds )
	LEFT JOIN dialyzer diaz ON dia.dialyzer_cd = diaz.dia_code
	LEFT JOIN g
	on ord.ord_no=g.ordnob	UNION ALL

SELECT g.*,
	2 AS dis_order,
	ord.*,
	eqp.class_cd AS equip_class_cd,
	eqp.equipment_name AS equip_name,
	eqp.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	eqp.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	eqp.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	eqp.in_hospital_cd_4 AS equip_in_hospital_cd_4,
	eqp.unit AS equip_unit,
	CASE WHEN ord.rst_dialysis_state = ''0'' THEN
		CASE WHEN eqp.class_cd = ''-1'' THEN ''未分類'' ELSE eqp_cls.class_name END 
	ELSE
		CASE WHEN ord.class_cd = ''-1'' THEN ''未分類'' ELSE ord.class_name END 
	END AS	equip_class_name,
-- 	case when eqp.class_cd = ''-1'' then ''未分類'' else eqp_cls.class_name end as equip_class_name,
	-- eqp_cls.class_name AS equip_class_name,
	eqp_cls.class_type AS equip_class_type,
	eq.code_order AS code_order,
	eqc.code_order AS class_order
FROM
	ord_tbl AS ord

	INNER JOIN equipment_tbl AS eqp ON ord.cd = eqp.equipment_cd :: TEXT
	AND equip_type = ''0''
	AND eqp.class_cd IN (@eqIds)
	LEFT JOIN equipment eq ON eq.equ_code = eqp.equipment_cd
	LEFT JOIN equipment_class_tbl eqp_cls ON eqp.class_cd = eqp_cls.class_cd
	LEFT JOIN equipment_class eqc ON eqp_cls.class_cd = eqc.equ_class_code
	LEFT JOIN g
	on ord.ord_no=g.ordnob', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_start", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_start", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材　@ordNo使用', '2020-03-27 12:59:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (97, 'with dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = @facilityCd
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''
),
equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
),
equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = @facilityCd
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
),
dialyzer AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	),
	equipment AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
	),
	equipment_class AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),
	 ord_tbl as (
  select
    facility_cd,
		json_idx,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no
		,info
    ,ord_no
  from
    ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( rst_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )

  where
    ord_no in ( @ordNos ) and is_del = ''0'' and rst_dialysis_state <> ''0''
)


(select
	1 AS dis_order,
  ord.*,
  dia.model_number as equip_name,
	-1 AS equip_class_cd,
  dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  null as equip_unit,
  null as equip_class_name,
  null as equip_class_type,
	diaz.code_order as code_order,
	null as class_order

from
  ord_tbl as ord
  inner join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
	LEFT JOIN dialyzer diaz ON dia.dialyzer_cd = diaz.dia_code
where equip_type = ''1''   and dia.dialyzer_cd IN (@diaIds)
order by class_cd, cd)
UNION all
(select
	2 AS dis_order,
  ord.*,
  eqp.equipment_name as equip_name,
	eqp.class_cd AS equip_class_cd,
  eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  eqp.unit as equip_unit,
	case when  (info ->> ''class_cd''):: TEXT = ''-1'' then ''未分類'' else info ->> ''class_name'' end as equip_class_name,
	-- eqp_cls.class_name AS equip_class_name,
  eqp_cls.class_type as equip_class_type,
	eq.code_order as code_order,
	eqc.code_order as class_order

from
  ord_tbl as ord
  inner join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
	LEFT JOIN equipment eq ON eq.equ_code = eqp.equipment_cd
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
	LEFT JOIN equipment_class eqc ON eqp_cls.class_cd = eqc.equ_class_code
	where equip_type <> ''1'' and eqp.class_cd IN (@eqIds) order by class_cd, cd)
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (188, 'WITH DATA AS (

WITH ord AS (
    SELECT
        ord_no,
        facility_cd,
				treat_date,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
    AND rst_dialysis_state <> ''0''
),
medicine_order AS (

  select
    one_json ->> ''code'' as medicine_cd
    , json_idx as medicine_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from ord limit 1)
    and master_physical_name = ''mst_medicine''

),
medicine_mix_temp AS (

select
    mix.facility_cd
    , mix.medicine_mix_cd
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount
from
    mst_medicine_mix mix
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
where
    mix.facility_cd  = (select facility_cd from ord limit 1)
    and mix.is_del = ''0''
    and mix.is_disp = ''1''
)
select A.*, @ordNo as ord_no_t from (
    select
      json_idx,
      ord_no,
      treat_date,
      ord.facility_cd,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''unit'' as medi_unit,
      cast(medi ->> ''amount'' AS NUMERIC) as medi_amount,
      medi ->> ''class_cd'' :: text as medi_class_cd,
			CASE WHEN ( medi ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE medi ->> ''class_name'' END as medi_class_name,
--       medi ->> ''class_name'' as medi_class_name,
      medi ->> ''class_type'' :: text as medi_class_type,
            medi->>''medicine_type'' as medicine_type,
      medi ->> ''effect_flg'' as effect_flg,
      medi ->> ''short_name'' as short_name,
      CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
        to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
      END as effect_date,
      medi ->> ''effect_user_id'' as effect_user_id,
      medi ->> ''timing_name'' as medi_timing_name,
      medi ->> ''procedure_name'' as procedure_name,
			COALESCE(medi ->> ''effect_user_last_name''::text, '''') || '' '' || COALESCE(medi ->> ''effect_user_first_name''::text, '''') as effect_user_name,
      medi->>''comment'' as comment
      ,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
      ,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
      ,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
      ,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
			,case 
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b1
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b1
				 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
				 else ''''
			 end as rst_procedure_in_hospital_cd_1
			,case 
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b2
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b2
				 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
				 else ''''
			 end as rst_procedure_in_hospital_cd_2
      ,mstMedic.unit_second as   unit_second
      ,save.receipt_value as receipt_value
      from
        ord
        left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and medi ->> ''cd'' :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class != ''20'')
        and save.medicine_no ->>''no'' = ord.medi ->>''no''
      where
      ord.medi->>''medicine_type'' = ''1''
    union
    select
      json_idx,
      ord_no,
      treat_date,
      ord.facility_cd,
      mixtemp.medi_cd  :: text  as medi_cd,
      mstMedic.medicine_name as medi_name,
      mstMedic.unit  as medi_unit,
      (medi ->> ''amount'') :: NUMERIC *  mixtemp.amount :: NUMERIC as medi_amount,
      mstMedic.class_cd :: text as  medi_class_cd,
			CASE WHEN ( medi ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE medi ->> ''class_name'' END as medi_class_name,
--       classtemp.class_name as medi_class_name,
      classtemp.class_type :: text as medi_class_type,
            medi->>''medicine_type'' as medicine_type,
      medi ->> ''effect_flg'' :: text as effect_flg,
      mstMedic.medicine_short_name as short_name,
      CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
        to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
      END as effect_date,
      medi ->> ''effect_user_id'' as effect_user_id,
      medi ->> ''timing_name'' as medi_timing_name,
      medi ->> ''procedure_name'' as procedure_name,
      (medi ->> ''effect_user_last_name''::text) || '' '' || (medi ->> ''effect_user_first_name''::text) as effect_user_name,
      medi->>''comment'' as comment
      ,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
      ,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
      ,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
      ,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
      ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
        then  mstP.in_hospital_cd_a1 else mstP.in_hospital_cd_b1 end as rst_procedure_in_hospital_cd_1
      ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
        then  mstP.in_hospital_cd_a2 else mstP.in_hospital_cd_b2 end as rst_procedure_in_hospital_cd_2
      ,mstMedic.unit_second as   unit_second
      ,save.receipt_value as receipt_value
      from
        ord
        inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= medi ->> ''cd'' )
        left join mst_medicine as  mstMedic  on (mstMedic.medicine_cd :: text = mixtemp.medi_cd and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join  mst_medicine_class  classtemp on (classtemp.class_cd :: text = mstMedic.class_cd :: text  and classtemp.facility_cd = mstMedic.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd  :: text :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class = ''20'' )
      where
      ord.medi->>''medicine_type'' = ''2''
) A
left join medicine_order O on (A.medi_cd = O.medicine_cd)
order by json_idx asc ,medicine_cd_order asc


	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
             ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dia_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "dia_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dia_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dia_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dia_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dia_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dia_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dia_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dia_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dia_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "dia_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬（分解）", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'WITH DATA AS (

with  ord_tbl AS (
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
    facility_cd = (select facility_cd from ord_tbl limit 1)
    and master_physical_name = ''mst_medicine''

),
medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
select
     mix.*
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount
from
    mst_medicine_mix mix
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
  where
    mix.facility_cd  = (select facility_cd from ord_tbl limit 1)
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
    facility_cd  = (select facility_cd from ord_tbl limit 1)
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
    facility_cd  = (select facility_cd from ord_tbl limit 1)
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
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
select A.*,save.receipt_value,@ordNo as ord_no_t from (
select
   json_idx
   ,ord_no
   ,ord.facility_cd
	 ,ord.treat_date
	 ,ord.treat_date as dial_treat_date
   , info ->> ''cd'' as cd
   , info ->> ''no'' as no
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , cast(info ->> ''amount'' AS NUMERIC) as amount
   , med.class_cd as class_cd
	 , CASE WHEN ord.rst_dialysis_state = ''0'' THEN
	        CASE WHEN med.class_cd = ''-1'' THEN ''未分類'' ELSE med_cls.class_name END 
		 ELSE			
	        CASE WHEN ( ord.info ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE ord.info ->> ''class_name'' END
		 END as class_name		
--    , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
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
		  when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a1
		  else ''''
	  end as procedure_in_hospital_cd_1
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b2
		  when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  else ''''
	  end as procedure_in_hospital_cd_2
    ,med.unit_second as   unit_second
from
  ord_tbl as ord
  inner join medicine_tbl as med on info ->> ''cd'' = med.medicine_cd::text AND med.class_cd IN ( @medIds )
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''1''

union

select
     json_idx
   ,ord_no
   ,ord.facility_cd
	 ,ord.treat_date
	 ,ord.treat_date as dial_treat_date
   , mixtemp.medi_cd  :: text  as cd
   , info ->> ''no'' as no
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , (info ->> ''amount'') :: NUMERIC * mixtemp.amount :: NUMERIC  as amount
   , med.class_cd as class_cd
	 , CASE WHEN ord.rst_dialysis_state = ''0'' THEN
	        CASE WHEN med.class_cd = ''-1'' THEN ''未分類'' ELSE med_cls.class_name END 
		 ELSE			
	        CASE WHEN ( ord.info ->> ''class_cd'' ) :: TEXT = ''-1'' THEN ''未分類'' ELSE ord.info ->> ''class_name'' END
		 END as class_name			 
--    , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
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
		  when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a1
		  else ''''
	  end as procedure_in_hospital_cd_1
	 ,case 
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', pro.in_hosp_a_startdate) then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_b_startdate) is null then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', pro.in_hosp_a_startdate) is null then pro.in_hospital_cd_b2
		  when date_trunc(''day'', pro.in_hosp_b_startdate) < date_trunc(''day'', pro.in_hosp_a_startdate) and date_trunc(''day'', pro.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_a2
		  when date_trunc(''day'', pro.in_hosp_a_startdate) < date_trunc(''day'', pro.in_hosp_b_startdate) and date_trunc(''day'', pro.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then pro.in_hospital_cd_b2
		  when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', pro.in_hosp_b_startdate) then pro.in_hospital_cd_a2
		  else ''''
	  end as procedure_in_hospital_cd_2 
   ,med.unit_second as   unit_second
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
left join ord_material_save as save on (save.supplies_base_no = A.ord_no and A.facility_cd = save.facility_cd and A.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1''
and ((save.supplies_class = ''12'' and A.medicine_type = ''1'') or  (save.supplies_class = ''20'' and A.medicine_type = ''2''))and save.medicine_no ->>''no'' = A.no)
  order by json_idx asc ,medicine_cd_order asc

	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
             ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "dial_treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "dial_medi_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (200, 'WITH DATA AS (

	with ord_tbl AS (
--     SELECT
--         ord_no
--         , facility_cd
--     FROM
--         ord_main
        SELECT
        ord_no
                , medi
                , json_idx
        , facility_cd
    FROM
        ord_main
                CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
        AND ord_no = @ordNo
)
, medicine_order AS (
    select
        one_json ->> ''code'' as medicine_cd
        , json_idx as medicine_cd_order
    from
        mst_selector
        cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
    where
        facility_cd = (select facility_cd from ord_tbl limit 1)
        and master_physical_name = ''mst_medicine''
),
medicine_mix_temp AS (

select
    mix.facility_cd
    , mix.medicine_mix_cd
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount
from
    mst_medicine_mix mix
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
where mix.is_del = ''0''
    and mix.is_disp = ''1''
)
SELECT A.* from (select
    @ordNo as ord_no_t
    , supplies_base_date as treat_date
		,sv.supplies_cd
    , med.medicine_name as medicine_name
    , md.medicine_cd_order
		, CASE WHEN ( medi ->> ''class_cd'' ) :: TEXT = ''-1'' or (medi ->> ''class_cd'') IS NULL THEN ''未分類'' ELSE medi ->> ''class_name'' END as medi_class_name
-- 		,medi ->> ''class_name'' as medi_class_name
    , sum(sv.ind_rst_value :: NUMERIC) as amount
    , med.unit
    ,sum(sv.receipt_value :: NUMERIC) as receipt_value
    ,med.unit_second as unit_second
--     , med.in_hospital_cd_1 as med_in_hospital_cd_1
--     , med.in_hospital_cd_2 as med_in_hospital_cd_2
--     , med.in_hospital_cd_3 as med_in_hospital_cd_3
--
-- from
--     ord_material_save sv
        , med_clss.class_cd as medi_class_cd
        , case when ord_tbl.medi ->> ''medicine_type'' is null then ''0'' else ord_tbl.medi ->> ''medicine_type'' end as medicine_type
    , med.in_hospital_cd_1 as med_in_hospital_cd_1
    , med.in_hospital_cd_2 as med_in_hospital_cd_2
    , med.in_hospital_cd_3 as med_in_hospital_cd_3

from
   ord_tbl
	 inner join mst_medicine as  med  on (ord_tbl.medi ->> ''cd'' = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord_tbl.facility_cd )
    left join mst_medicine_class as med_clss
        on (med_clss.class_cd = med.class_cd)
		left join ord_material_save as sv on (sv.supplies_base_no = ord_tbl.ord_no and ord_tbl.facility_cd = sv.facility_cd and  medi ->> ''cd'' :: text  = sv.supplies_cd and sv.supplies_source_class in (''1'', ''3'') and sv.ind_rst_class =''2'' and sv.supplies_class not in (''13'',''15'') )
		left join medicine_order md
        on (
            sv.supplies_base_no = sv.supplies_base_no
            and sv.supplies_cd = md.medicine_cd
        )
		
where
    ord_tbl.medi->>''medicine_type'' = ''1''
group by
    sv.supplies_cd
    , medicine_name
    , medicine_cd_order
    , class_name
		,medi_class_name
    , unit
    ,unit_second
        , medi_class_cd--
        , medicine_type--
    , med_in_hospital_cd_1
    , med_in_hospital_cd_2
    , med_in_hospital_cd_3
    , treat_date
	UNION
	select
    @ordNo as ord_no_t
    , supplies_base_date as treat_date
		,sv.supplies_cd
    , med.medicine_name as medicine_name
    , md.medicine_cd_order
		, CASE WHEN ( medi ->> ''class_cd'' ) :: TEXT = ''-1'' or (medi ->> ''class_cd'') IS NULL THEN ''未分類'' ELSE medi ->> ''class_name'' END as medi_class_name
    , sum(sv.ind_rst_value :: NUMERIC) as amount
    , med.unit
    ,sum(sv.receipt_value :: NUMERIC) as receipt_value
    ,med.unit_second as unit_second
        , med_clss.class_cd as medi_class_cd
        , case when ord_tbl.medi ->> ''medicine_type'' is null then ''0'' else ord_tbl.medi ->> ''medicine_type'' end as medicine_type
    , med.in_hospital_cd_1 as med_in_hospital_cd_1
    , med.in_hospital_cd_2 as med_in_hospital_cd_2
    , med.in_hospital_cd_3 as med_in_hospital_cd_3

from
    ord_tbl
		inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= medi ->> ''cd'' )
	 left join mst_medicine as  med  on (med.medicine_cd :: text = mixtemp.medi_cd and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord_tbl.facility_cd )
    left join mst_medicine_class as med_clss
        on (med_clss.class_cd = med.class_cd)
		left join ord_material_save as sv on (sv.supplies_base_no = ord_tbl.ord_no and ord_tbl.facility_cd = sv.facility_cd and mixtemp.medi_cd  :: text :: text  = sv.supplies_cd and sv.supplies_source_class in (''1'', ''3'') and sv.ind_rst_class =''2'' and sv.supplies_class not in (''13'',''15'') )
		left join medicine_order md
        on (
            sv.supplies_base_no = sv.supplies_base_no
            and sv.supplies_cd = md.medicine_cd
        )
		
where
    ord_tbl.medi->>''medicine_type'' = ''2''
group by
    sv.supplies_cd
    , medicine_name
    , medicine_cd_order
    , class_name
		,medi_class_name
    , unit
    ,unit_second
        , medi_class_cd--
        , medicine_type--
    , med_in_hospital_cd_1
    , med_in_hospital_cd_2
    , med_in_hospital_cd_3
    , treat_date	) A
order by
    A.medicine_cd_order asc

	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "実施薬剤１", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "錠", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_1", "data_name": "実施薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_2", "data_name": "実施薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_3", "data_name": "実施薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_4", "data_name": "実施薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：実施薬剤（分解） @ordNo 使用', '2021-11-05 11:30:03', CURRENT_TIMESTAMP, NULL);
