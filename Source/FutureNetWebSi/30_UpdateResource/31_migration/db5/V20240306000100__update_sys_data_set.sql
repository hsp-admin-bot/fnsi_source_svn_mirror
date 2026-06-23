DELETE FROM "ntss"."sys_data_set" where sql_cd in (4,190);
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
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
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
  CASE
			WHEN medicine_type = ''2'' THEN
			case when mix.class_cd = ''-1'' then ''未分類'' else mix_cls.class_name end
			-- mix_cls.class_name
			ELSE
			case when med.class_cd = ''-1'' then ''未分類'' else med_cls.class_name end
			-- med_cls.class_name
		END AS class_name,
  case
    when medicine_type = ''2'' then mix_cls.class_type
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
  left join mst_medicine as  med  on (ord.cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord.facility_cd )
  left join mst_medicine_mix as  mix  on (ord.cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and mix.facility_cd = ord.facility_cd )
  left join mst_medicine_class as med_cls on (med.class_cd = med_cls.class_cd)
  left join mst_medicine_class as mix_cls on (mix.class_cd = mix_cls.class_cd)
  left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
  left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd::text)
  left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1'' and supplies_class != ''20'')
  left join (SELECT
	index_no AS code_order,
	TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
	order_cd ->> ''name'' AS medi_class_code_name
  FROM
	mst_selector
	CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
	facility_cd = @facilityCd
	AND master_physical_name = ''mst_medicine_class'') as dmed_cls on dmed_cls.medi_class_code = med.class_cd
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
             a.index
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_type", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @ordNo 使用', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'WITH DATA AS (

with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info
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
   , info ->> ''cd'' as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , cast(info ->> ''amount'' AS NUMERIC) as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
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
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , (info ->> ''amount'') :: NUMERIC * mixtemp.amount :: NUMERIC  as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
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
and ((save.supplies_class = ''12'' and A.medicine_type = ''1'') or  (save.supplies_class = ''20'' and A.medicine_type = ''2'')))
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
	b.ord_no,
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
	DATA.ord_no_t = time_info.ord_no
	;
	', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
