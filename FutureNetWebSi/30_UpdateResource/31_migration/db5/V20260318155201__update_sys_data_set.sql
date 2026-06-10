DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (4,5,45,74,190);
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
  ,save.ind_unit
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
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "medicine_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "ind_unit", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @ordNo 使用', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (45, 'with ord_tbl as (
  select
    facility_cd,
    pat_id,
    ind_bed_cd,
		treat_date,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end,
    rst_dialysis_state
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
), next_date as (
  select
     pat_id,
     treat_date
  from
     ord_main
  where
     pat_id =(select pat_id from ord_main
	 where
	 ord_no= @ordNo
	 and is_del = ''0''
	 and rst_dialysis_state = ''0'')
  and
     treat_date > (select treat_date from ord_main
	 where
	 ord_no=@ordNo
	 and is_del = ''0''
	 and rst_dialysis_state = ''0'') and is_del = ''0'' and rst_dialysis_state = ''0'' and facility_cd = @facilityCd ORDER BY treat_date ASC limit 1

), kur_tbl as (
  select
    *
  from
    mst_kur
  where
    mst_kur.facility_cd = @facilityCd
  and
    mst_kur.is_del = ''0''
), va_tbl as (
  select
    *
  from
    mst_va
  where
    mst_va.facility_cd = @facilityCd
  and
    mst_va.is_disp = ''1''
  and
    mst_va.is_del = ''0''
), treatment_tbl as (
  select
    *
  from
    mst_treatment
  where
    mst_treatment.facility_cd = @facilityCd
  and
    mst_treatment.is_disp = ''1''
  and
    mst_treatment.is_del = ''0''
), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    mst_bed.facility_cd = @facilityCd
  and
    mst_bed.is_disp = ''1''
  and
    mst_bed.is_del = ''0''
), machine_tbl as (
  select
    *
  from
    mst_machine
  where
    mst_machine.facility_cd = @facilityCd
  and
    mst_machine.is_disp = ''1''
  and
    mst_machine.is_del = ''0''
), room_bed_group_tbl as (
  select
    facility_cd,
    array_to_string(array_agg(room_bed_group_name), '','') as room_bed_group_name_list
  from
    mst_room_bed_group
  where
    mst_room_bed_group.facility_cd = @facilityCd
  and
    mst_room_bed_group.is_disp = ''1''
  and
    mst_room_bed_group.is_del = ''0''
  and
    mst_room_bed_group.bed_list @> (''['' || (select ind_bed_cd from ord_tbl) || '']'')::jsonb
  group by
    facility_cd
), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = @facilityCd
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0'' and mst_dialyzer.dialyzer_cd IN (@diaIds)
), medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    mst_medicine.facility_cd = @facilityCd
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0'' and mst_medicine.class_cd IN ( @medIds )
), medicine_mix_tbl as (
  select
    *
  from
    mst_medicine_mix
  where
    mst_medicine_mix.facility_cd = @facilityCd
  and
    mst_medicine_mix.is_disp = ''1''
  and
	mst_medicine_mix.is_del = ''0'' and mst_medicine_mix.class_cd IN ( @medIds )
), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0'' and mst_equipment.class_cd IN (@eqIds)
-- 指定患者、基準日以前のDWがある身体情報を取得
), pat_physical_tbl as (
  select
    work_tbl.*
  from
    (
    select
      pat_id,
      info->>''exam_date'' as exam_date,
      info->>''dw'' as dw,
      info->>''pre_scale_upper'' as pre_scale_upper,
      info->>''pre_scale_lower'' as pre_scale_lower
    from
      pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = @patId
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
-- 指定患者の車いす情報を取得
), pat_wheel_chair_tbl as (
  select
    pat_id,
    wheel_chair_name,
    wheel_chair_weight
  from
    mst_wheel_chair,
    (
      select
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
        master_physical_name = ''mst_wheel_chair''
  ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = @patId
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
),oms_puncture_needle_a_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
    AND facility_cd = @facilityCd
		AND supplies_source_class = ''0''
		AND supplies_class = ''06''
		AND ind_rst_class=''1''

),oms_puncture_needle_v_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
    AND facility_cd = @facilityCd
		AND supplies_source_class = ''0''
		AND supplies_class = ''07''
		AND ind_rst_class=''1''

),oms_puncture_needle_sn_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
    AND facility_cd = @facilityCd
		AND supplies_source_class = ''0''
		AND supplies_class = ''05''
		AND ind_rst_class=''1''

),oms_blood_circuit_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND facility_cd = @facilityCd
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''1''

)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ind_kur_cd as kur_cd,
  kur_tbl.kur_name as kur_name,
  COALESCE (
  NULLIF(
  CASE
  WHEN treat_week = ''1'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Mon''->>''user_id''
  WHEN treat_week = ''2'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Tues''->>''user_id''
  WHEN treat_week = ''3'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Wednes''->>''user_id''
  WHEN treat_week = ''4'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Thurs''->>''user_id''
  WHEN treat_week = ''5'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Fri''->>''user_id''
  WHEN treat_week = ''6'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Satur''->>''user_id''
  WHEN treat_week = ''7'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Sun''->>''user_id''
  END,''''), 
  NULLIF(((SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''All''->>''user_id''),''''),
  NULLIF((SELECT "value" FROM mst_facility_setting  WHERE facility_cd = @facilityCd AND facility_setting_no = ''1025''),''0''),'''')
  AS full_time_doctor,
  ord.ind_va_cd as va_cd,
  va_tbl.va_direct as va_direct,
  ord.ind_treatment_cd as treatment_cd,
  treatment_tbl.treatment_name,
-- 	treatment_tbl.treatment_name AS treatment_name1,
  to_char(to_timestamp(ord.ind_treat_start_time, ''HH24MI''), ''HH24:MI'') as treat_start_time,
  ord.ind_bed_cd as bed_cd,
  -- 治療時間
  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  --VA
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN va_tbl.va_name
    ELSE ord.ind_cond_info->''2''->>''value_name_1''
  END AS va_name,
  va_tbl.in_hospital_cd_1 as va_in_hospital_cd_1,
  va_tbl.in_hospital_cd_2 as va_in_hospital_cd_2,
  -- 目標体重
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.ind_cond_info->''3''->>''value''
  end as target_weight,
  -- 除水量制限
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  -- ダイアライザ
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN dialyzer_tbl.model_number
    ELSE ord.ind_cond_info->''5''->>''value_name_1''
  END AS dialyzer_name,
  dialyzer_tbl.in_hospital_cd_1 as dialyzer_in_hospital_cd_1,
  dialyzer_tbl.in_hospital_cd_2 as dialyzer_in_hospital_cd_2,
  dialyzer_tbl.in_hospital_cd_3 as dialyzer_in_hospital_cd_3,
  dialyzer_tbl.in_hospital_cd_4 as dialyzer_in_hospital_cd_4,
  dialyzer_tbl.*,
  -- 吸着カラム
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN adsorption_column_tbl.equipment_name
    ELSE ord.ind_cond_info->''6''->>''value_name_1''
  END AS adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as adsorption_in_hospital_cd_4,
  -- 1次膜
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN primary_film_tbl.equipment_name
    ELSE ord.ind_cond_info->''7''->>''value_name_1''
  END AS primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as primary_film_in_hospital_cd_4,
  -- 2次膜
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN secondary_film_tbl.equipment_name
    ELSE ord.ind_cond_info->''8''->>''value_name_1''
  END AS secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as secondary_film_in_hospital_cd_4,
  -- 穿刺針(A針)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_a_tbl.equipment_name
    ELSE ord.ind_cond_info->''9''->>''value_name_1''
  END AS puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as pn_a_in_hospital_cd_4,
  -- 穿刺針(V針)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_v_tbl.equipment_name
    ELSE ord.ind_cond_info->''10''->>''value_name_1''
  END AS puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as pn_v_in_hospital_cd_4,
  -- 穿刺針(SN)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_sn_tbl.equipment_name
    ELSE ord.ind_cond_info->''11''->>''value_name_1''
  END AS puncture_needle_sn_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as pn_s_in_hospital_cd_4,
  -- シングルニードル使用
  ord.ind_cond_info->''12''->>''value'' as single_needle,
  -- 血液回路
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN blood_circuit_tbl.equipment_name
    ELSE ord.ind_cond_info->''13''->>''value_name_1''
  END AS blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as bc_in_hospital_cd_4,
  -- 血流量
  ord.ind_cond_info->''14''->>''value'' as blood_flow,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''mL/min''
    ELSE ord.ind_cond_info->''14''->>''unit'' 
  END AS blood_flow_unit,
  -- 透析液
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.medicine_name
    ELSE ord.ind_cond_info->''15''->>''value_name_1''
  END AS dialysate_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.unit_second
    ELSE ord.ind_cond_info->''15''->>''unit''
  END AS dialysate_flow_unit,
  med_dialysate_tbl.in_hospital_cd_1 AS rst_dialysate_in_hospital_cd_1,
  med_dialysate_tbl.in_hospital_cd_2 AS rst_dialysate_in_hospital_cd_2,
  med_dialysate_tbl.in_hospital_cd_3 AS rst_dialysate_in_hospital_cd_3,
  med_dialysate_tbl.in_hospital_cd_4 AS rst_dialysate_in_hospital_cd_4,
  -- 透析液流量
  ord.ind_cond_info->''16''->>''value'' as dialysate_flow_rate,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''mL/min''
    ELSE ord.ind_cond_info->''16''->>''unit'' 
  END AS dialysate_flow_rate_unit,
  -- 透析液使用数
  ord.ind_cond_info->''17''->>''value'' as dialysate_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.unit_second
    ELSE ord.ind_cond_info->''17''->>''unit''
  END AS dialysate_amount_unit,
  -- 透析液温度
  ord.ind_cond_info->''18''->>''value'' as dialysate_temperature,
  -- 補液
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.medicine_name
    ELSE ord.ind_cond_info->''19''->>''value_name_1''
  END AS fluid_replacement_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.unit_second
    ELSE ord.ind_cond_info->''19''->>''unit''
  END AS fluid_replacement_unit,
  med_fluid_replacement_tbl.in_hospital_cd_1 AS rst_fluid_in_hospital_cd_1,
  med_fluid_replacement_tbl.in_hospital_cd_2 AS rst_fluid_in_hospital_cd_2,
  med_fluid_replacement_tbl.in_hospital_cd_3 AS rst_fluid_in_hospital_cd_3,
  med_fluid_replacement_tbl.in_hospital_cd_4 AS rst_fluid_in_hospital_cd_4,  
  -- 補液量
	case
		when ord.ind_cond_info->''20''->>''value'' = ''-1'' then ''濾過率から算出''
		else ord.ind_cond_info->''20''->>''value''
		end as fluid_replacement_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''L''
    ELSE ord.ind_cond_info->''20''->>''unit''
  END AS fluid_replacement_amount_unit,
  -- 補液選択
  ord.ind_cond_info->''21''->>''value'' as fluid_replacement_timing,
  -- 補液使用数
  ord.ind_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.unit_second
    ELSE ord.ind_cond_info->''22''->>''unit''
  END AS fluid_replacement_use_count_unit,
  -- 補液温度
  ord.ind_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  -- 補液速度
	case
		when ord.ind_cond_info->''24''->>''value'' = ''-1'' then ''濾過率から算出''
		else ord.ind_cond_info->''24''->>''value''
		end as fluid_replacement_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''L/h''
    ELSE ord.ind_cond_info->''24''->>''unit''
  END AS fluid_replacement_speed_unit,
  -- 抗凝固剤
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.medicine_mix_name
        ELSE med_anti_coagulant_tbl.medicine_name
      END
    ELSE ord.ind_cond_info->''25''->>''value_name_1''
  END AS anti_coagulant_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''25''->>''unit''
  END AS anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_1
    else med_anti_coagulant_tbl.in_hospital_cd_1
  end as rst_anti_in_hospital_cd_1,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_2
    else med_anti_coagulant_tbl.in_hospital_cd_2
  end as rst_anti_in_hospital_cd_2,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_3
    else med_anti_coagulant_tbl.in_hospital_cd_3
  end as rst_anti_in_hospital_cd_3,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then ''''
    else med_anti_coagulant_tbl.in_hospital_cd_4
  end as rst_anti_in_hospital_cd_4,
  -- 抗凝固剤ワンショット量
  ord.ind_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''26''->>''unit''
   END AS anti_coagulant_one_shot_amount_unit,
  -- 抗凝固剤持続速度
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit || ''/h''
        ELSE med_anti_coagulant_tbl.unit || ''/h''
      END
    ELSE ord.ind_cond_info->''27''->>''unit''
  END AS anti_coagulant_sustained_speed_unit,
  -- 抗凝固剤持続総量
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''28''->>''unit''
   END AS anti_coagulant_sustained_amount_unit,
   
   CAST(ord.ind_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.ind_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,
  -- IP使用選択
  ord.ind_cond_info->''29''->>''value'' as ip,
  -- IPスタート
  ord.ind_cond_info->''30''->>''value'' as ip_start,
  -- IPワンショット量
  ord.ind_cond_info->''31''->>''value'' as ip_one_shot_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''31''->>''value'' IS NOT NULL THEN ''mL''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''31''->>''unit''
  END AS ip_one_shot_amount_unit,
  -- IP速度
  ord.ind_cond_info->''32''->>''value'' as ip_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''32''->>''value'' IS NOT NULL THEN ''mL/h''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''32''->>''unit''
  END AS ip_speed_unit,
  -- IP速度最大値
  ord.ind_cond_info->''33''->>''value'' as ip_speed_max,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''33''->>''value'' IS NOT NULL THEN ''mL/h''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''33''->>''unit''
  END AS ip_speed_max_unit,
  -- 自動ワンショット
  ord.ind_cond_info->''34''->>''value'' as auto_one_shot,
  -- IP電源自動切り
  ord.ind_cond_info->''35''->>''value'' as ip_auto_off,
  -- IP電源自動切り時間
  ord.ind_cond_info->''36''->>''value'' as ip_auto_off_time,
  -- IP電源OKモニタ切り
  ord.ind_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  -- IP電源OKモニタ切り時間
  ord.ind_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  ord.ind_tare_info->>''name_1'' as tare_name1,
  ord.ind_tare_info->>''name_2'' as tare_name2,
  ord.ind_tare_info->>''name_3'' as tare_name3,
  ord.ind_tare_info->>''name_4'' as tare_name4,
  ord.ind_tare_info->>''name_5'' as tare_name5,
  ord.ind_tare_info->>''weight_1'' as tare_weight1,
  ord.ind_tare_info->>''weight_2'' as tare_weight2,
  ord.ind_tare_info->>''weight_3'' as tare_weight3,
  ord.ind_tare_info->>''weight_4'' as tare_weight4,
  ord.ind_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.ind_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.ind_off_water_info->>''name_1'' as off_water_name1,
  ord.ind_off_water_info->>''name_2'' as off_water_name2,
  ord.ind_off_water_info->>''name_3'' as off_water_name3,
  ord.ind_off_water_info->>''name_4'' as off_water_name4,
  ord.ind_off_water_info->>''name_5'' as off_water_name5,
  ord.ind_off_water_info->>''weight_1'' as off_water_weight1,
  ord.ind_off_water_info->>''weight_2'' as off_water_weight2,
  ord.ind_off_water_info->>''weight_3'' as off_water_weight3,
  ord.ind_off_water_info->>''weight_4'' as off_water_weight4,
  ord.ind_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.ind_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  pat_physical_tbl.dw,
  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  case 
  	when ord.ind_device_mode is null then treatment_tbl.device_mode
	else ord.ind_device_mode 
  end as device_mode,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a1 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b1 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a1	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b1
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a1
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b1	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a2 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b2 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a2	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b2
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a2
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b2	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a3 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b3 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a3	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b3
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a3
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b3	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a4 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b4 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a4	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b4
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a4
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b4	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,
  bed_tbl.*,
  CASE
    WHEN bed_tbl.is_infection IS NULL THEN ''未登録''
    ELSE bed_tbl.is_infection
  END AS bed_is_infection,
	bed_tbl.in_hospital_cd_1 as bed_in_hospital_cd_1,
	bed_tbl.in_hospital_cd_2 as bed_in_hospital_cd_2,
  machine_tbl.*,
  room_bed_group_tbl.room_bed_group_name_list,
  nt.treat_date as next_treat_date,
  ord.ord_no
from
  ord_main as ord

  left join ord_tbl on ord.pat_id = ord_tbl.pat_id
  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join kur_tbl on ord.ind_kur_cd = kur_tbl.kur_cd
  left join va_tbl on ord.ind_va_cd = va_tbl.va_cd
  left join treatment_tbl on ord.ind_treatment_cd = treatment_tbl.treatment_cd
  left join bed_tbl on ord.ind_bed_cd = bed_tbl.bed_cd
  left join machine_tbl on bed_tbl.machine_no = machine_tbl.machine_no
  left join room_bed_group_tbl on bed_tbl.facility_cd = room_bed_group_tbl.facility_cd

  left join dialyzer_tbl on ord.ind_cond_info->''5''->>''value'' = dialyzer_tbl.dialyzer_cd::text

  left join equipment_tbl as adsorption_column_tbl on ord.ind_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text
  left join equipment_tbl as primary_film_tbl on ord.ind_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text
  left join equipment_tbl as secondary_film_tbl on ord.ind_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text

	left join oms_puncture_needle_a_tbl as opnat  on opnat.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_v_tbl as opnvt on opnvt.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_sn_tbl as opnsnt on opnsnt.supplies_base_no=ord.ord_no
	left join oms_blood_circuit_tbl as obct on obct.supplies_base_no=ord.ord_no

	left join equipment_tbl as puncture_needle_a_tbl on opnat.supplies_cd= puncture_needle_a_tbl.equipment_cd::text
	left join equipment_tbl as puncture_needle_v_tbl on opnvt.supplies_cd = puncture_needle_v_tbl.equipment_cd::text
	left join equipment_tbl as puncture_needle_sn_tbl on opnsnt.supplies_cd = puncture_needle_sn_tbl.equipment_cd::text
  left join equipment_tbl as blood_circuit_tbl on obct.supplies_cd= blood_circuit_tbl.equipment_cd::text

  left join medicine_tbl as med_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text
  left join medicine_tbl as med_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text
  left join medicine_tbl as med_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text

  left join medicine_mix_tbl as mix_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text
  left join next_date as nt on nt.pat_id = ord.pat_id
where
	ord.ord_no = @ordNo
  ', 2, '[{"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "常勤医", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "full_time_doctor", "data_name": "常勤医", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "full_time_doctor", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:00", "can_calc": "0", "data_code": "treat_start_time", "data_name": "治療開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "next_treat_date", "data_name": "次回透析予定日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "next_treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕内シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dw", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD＋補液", "item": "HD＋補液"}, {"code": "5", "disp": "ECUM＋補液", "item": "ECUM＋補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "0", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A針", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_sn_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "blood_flow_unit", "data_name": "血流量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_flow_rate_unit", "data_name": "透析液流量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レ袋", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液使用数単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_amount_unit", "data_name": "補液量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ml", "can_calc": "0", "data_code": "fluid_replacement_use_count_unit", "data_name": "補液使用数単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L/h", "can_calc": "0", "data_code": "fluid_replacement_speed_unit", "data_name": "補液速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "フサン", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_one_shot_amount_unit", "data_name": "抗凝固剤ワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_sustained_amount_unit", "data_name": "抗凝固剤持続総量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount_unit", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "0", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "自動ワンショット単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スリッパ", "can_calc": "0", "data_code": "tare_name1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "tare_weight1", "data_name": "風袋重量１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "tare_name2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "tare_weight2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "1", "data_code": "tare_name3", "data_name": "風袋名称３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "tare_weight3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "tare_name4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "tare_name5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "tare_weight_total", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_weight1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "off_water_weight2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "off_water_weight5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "off_water_weight_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_upper", "data_name": "前体重許容割合（上限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_upper", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_lower", "data_name": "前体重許容割合（下限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_lower", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "room_bed_group_name_list", "data_name": "透析室・ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_bed_group_name_list", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED001", "can_calc": "0", "data_code": "bed_in_hospital_cd_1", "data_name": "ベッド連携コード1", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED002", "can_calc": "0", "data_code": "bed_in_hospital_cd_2", "data_name": "ベッド連携コード2", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "中空糸", "can_calc": "0", "data_code": "dialyzer_type", "data_name": "ダイアライザ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "中空糸", "item": "中空糸"}, {"code": "1", "disp": "積層", "item": "積層"}], "data_class": "ダイアライザ情報", "field_name": "dialyzer_type", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "ufr_warning_max", "data_name": "UFR警告点上限", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_max", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "ufr_warning_min", "data_name": "UFR警告点下限", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_min", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ufr_warning_reduction", "data_name": "UFR低下警報点", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_reduction", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "0", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "in_number", "data_name": "入り数", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "in_number", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/01/01", "can_calc": "0", "data_code": "use_start_date", "data_name": "使用開始日", "data_type": "DateTime", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "use_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/12/31", "can_calc": "0", "data_code": "use_end_date", "data_name": "使用終了日", "data_type": "DateTime", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "use_end_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件/ベッド情報/ダイアライザ情報　@ordNo使用', '2020-03-26 17:10:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (74, 'WITH dialyzer_tbl AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		mst_dialyzer.facility_cd = @facilityCd
		AND mst_dialyzer.is_disp = ''1''
		AND mst_dialyzer.is_del = ''0''
	),
	equipment_tbl AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		mst_equipment.facility_cd = @facilityCd
		AND mst_equipment.is_disp = ''1''
		AND mst_equipment.is_del = ''0''
	),
	equipment_class_tbl AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		mst_equipment_class.facility_cd = @facilityCd
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
	ord_tbl AS (
	SELECT
		facility_cd,
		json_idx,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date,
		info ->> ''class_cd'' AS class_cd,
		info ->> ''class_name'' AS class_name,
		info ->> ''class_type'' AS class_type,
		info ->> ''equip_type'' AS equip_type,
		info ->> ''cd'' AS cd,
		info ->> ''name'' AS name,
		info ->> ''short_name'' AS short_name,
		info ->> ''amount'' AS amount,
		info ->> ''unit'' AS unit,
		info ->> ''ind_user_id'' AS ind_user_id,
		info ->> ''ind_user_last_name'' AS ind_user_last_name,
		info ->> ''ind_user_first_name'' AS ind_user_first_name,
		info ->> ''upd_user_id'' AS upd_user_id,
		info ->> ''upd_user_last_name'' AS upd_user_last_name,
		info ->> ''upd_user_first_name'' AS upd_user_first_name,
		info ->> ''input_class'' AS input_class,
		info ->> ''is_editable'' AS is_editable,
		info ->> ''cop_order_no'' AS cop_order_no,
		ord_no,
		rst_dialysis_state
	FROM
		ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( ind_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )
	WHERE
		ord_no in ( @ordNos )
		AND is_del = ''0''
	)
SELECT
	1 AS dis_order,
	ord.*,
	-1 AS equip_class_cd,
	dia.model_number AS equip_name,
	NULL AS equipment_short_name,
	dia.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	dia.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	dia.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	dia.in_hospital_cd_4 AS equip_in_hospital_cd_4,
	NULL AS equip_unit,
	concat(ind_user_last_name, ind_user_first_name) AS ind_user_name,
	concat(upd_user_last_name, upd_user_first_name) AS upd_user_name,
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
	UNION ALL

SELECT
	2 AS dis_order,
	ord.*,
  
  CASE
    WHEN rst_dialysis_state = ''0'' THEN eqp.class_cd
    ELSE ord.class_cd :: NUMERIC
  END AS equip_class_cd,
  
  CASE
    WHEN rst_dialysis_state = ''0'' THEN eqp.equipment_name
    ELSE ord.name
  END AS equip_name,

  CASE
    WHEN rst_dialysis_state = ''0'' THEN eqp.equipment_short_name
    ELSE ord.short_name
  END AS equipment_short_name,

	eqp.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	eqp.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	eqp.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	eqp.in_hospital_cd_4 AS equip_in_hospital_cd_4,
  
  CASE
    WHEN rst_dialysis_state = ''0'' THEN eqp.unit
    ELSE ord.unit
  END AS equip_unit,
  
	concat(ind_user_last_name, ind_user_first_name) AS ind_user_name,
	concat(upd_user_last_name, upd_user_first_name) AS upd_user_name,
	CASE WHEN ord.rst_dialysis_state = ''0'' THEN
		CASE WHEN eqp.class_cd = ''-1'' THEN ''未分類'' ELSE eqp_cls.class_name END 
	ELSE
		CASE WHEN ord.class_cd = ''-1'' THEN ''未分類'' ELSE ord.class_name END 
	END AS	equip_class_name,
  
  CASE
    WHEN rst_dialysis_state = ''0'' THEN eqp_cls.class_type
    ELSE ord.class_type :: NUMERIC
  END AS equip_class_type,
  
	eq.code_order AS code_order,
	eqc.code_order AS class_order
FROM
	ord_tbl AS ord

	INNER JOIN equipment_tbl AS eqp ON ord.cd = eqp.equipment_cd :: TEXT
	AND equip_type = ''0''
	AND eqp.class_cd IN (@eqIds)
	LEFT JOIN equipment eq ON eq.equ_code = eqp.equipment_cd
	LEFT JOIN equipment_class_tbl eqp_cls ON eqp.class_cd = eqp_cls.class_cd
	LEFT JOIN equipment_class eqc ON eqp_cls.class_cd = eqc.equ_class_code', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ針", "can_calc": "0", "data_code": "equipment_short_name", "data_name": "省略医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equipment_short_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "医療材料", "can_calc": "0", "data_code": "equip_type", "data_name": "医療材料区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "医療材料", "item": "医療材料"}, {"code": "1", "disp": "ダイアライザ", "item": "ダイアライザ"}], "data_class": "医材", "field_name": "equip_type", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材　@ordNo使用', '2020-03-27 12:59:00', CURRENT_TIMESTAMP, NULL);
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
select A.*,save.receipt_value,save.ind_unit from (
select
   json_idx
   ,ord_no
   ,ord.facility_cd
	 ,ord.treat_date
	 ,ord.treat_date as dial_treat_date
   , info ->> ''cd'' as cd
   , info ->> ''no'' as no
   
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
  order by json_idx asc ,medicine_cd_order asc
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "dial_treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "dial_medi_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "ind_unit", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "dial_ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dial_upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
