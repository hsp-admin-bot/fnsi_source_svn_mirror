DELETE FROM ntss.sys_data_set WHERE sql_cd in (2,3,4,7,9,10,11,16,29,35,36,37,45,52,68,69,82,95,103,105,111,116,117,133,141,161,162,166,169,173,176,190,206,207);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2, 'select
  om.rst_start_date
  , om.rst_end_date
  , regexp_replace(date_part(''day'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)) * 24 + date_part(''hour'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)) || '':'' || to_char(date_part(''minute'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)), ''09''), '' '', '''') as rst_date
from
  ord_main om
where
  ord_no = @ordNo
and is_del = ''0''
and rst_dialysis_state <>''0''
', 2, '[{"preview": "2011/3/12  08:21", "can_calc": "0", "data_code": "rst_start_date", "data_name": "透析開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_start_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_end_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:45", "can_calc": "0", "data_code": "rst_date", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', NULL, '2019-05-29 17:24:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3, 'WITH monitorData AS (
    SELECT
        rst_weight_info,
        monitor_data,
        bio_moni_ctl_no,
        occur_date,
        data_type,
				a.ord_no
    FROM
        ord_main A
        LEFT JOIN mni_monitor B ON A.ord_no = B.ord_no
		AND B.facility_cd = @facilityCd
        AND A.facility_cd = B.facility_cd
        AND B.is_del = ''0''
    WHERE
		A.facility_cd = @facilityCd
        AND A.ord_no = @ordNo
		AND A.is_del = ''0''
        AND A.rst_dialysis_state <> ''0''
    ),
    tmp AS (
    SELECT
        CAST( monitorData.rst_weight_info ->> ''weight_before''  AS DECIMAL ) AS weight_before,
        ( monitorData.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP AS weight_before_date,
        CAST( monitorData.rst_weight_info ->> ''weight_after'' AS DECIMAL ) AS weight_after,
        ( monitorData.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP AS weight_after_date,
        CAST( monitorData.rst_weight_info ->> ''ctr'' AS DECIMAL  ) AS ctr,
        ( monitorData.rst_weight_info ->> ''ctr_measure_date'' ) :: TIMESTAMP AS ctr_measure_date,
        CAST( monitorData.rst_weight_info ->> ''ctr_weight'' AS DECIMAL ) AS ctr_weight,
        CAST( monitorData.rst_weight_info ->> ''kt_v_measure'' AS DECIMAL ) AS kt_v_measure,
        CAST( monitorData.rst_weight_info ->> ''urr'' AS DECIMAL  ) AS urr,
        CAST( monitorData.rst_weight_info ->> ''sttc_vns_prssr'' AS DECIMAL ) AS sttc_vns_prssr,
        CAST( monitorData.rst_weight_info ->> ''iap_rt'' AS DECIMAL  ) AS iap_rt,
        to_number( monitorData.rst_weight_info -> ''recrcl_rt'' -> ( monitorData.rst_weight_info -> ''recrcl_rt'' ->> ''valid_no'' ) ->> ''rate'', ''999'' ) AS re_loop_rate,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''90'', ''999'' ) AS before_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''91'', ''999'' ) AS before_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''92'', ''999'' ) AS before_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''93'', ''999'' ) AS before_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 5 ) AS before_vital_measure_date,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''90'', ''999'' ) AS after_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''91'', ''999'' ) AS after_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''92'', ''999'' ) AS after_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''93'', ''999'' ) AS after_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 6 ) AS after_vital_measure_date,
				monitorData.ord_no
    FROM
        monitorData
        LIMIT 1
    ),
	b AS (
    select ord_main.* from ord_main
     where 	rst_dialysis_state between ''1'' and ''5''
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
, b.ord_no
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)
		   SELECT
    g.*,tmp.*,
    before_bp_high :: TEXT || ''/'' || before_bp_low :: TEXT || ''/'' || before_bp_ave || ''('' || before_pulse :: TEXT || '')'' AS before_bp_summary,
    after_bp_high :: TEXT || ''/'' || after_bp_low :: TEXT || ''/'' || after_bp_ave || ''('' || after_pulse :: TEXT || '')'' AS after_bp_summary
FROM
    tmp
left join
	g
on tmp.ord_no=g.ord_no', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "iap_rt", "data_name": "IAP ratio", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "iap_rt", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "sttc_vns_prssr", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "sttc_vns_prssr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報/血圧情報 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
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
  case
    when medicine_type = ''2'' then mix_cls.class_name
    else med_cls.class_name
  end as class_name,
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
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
   then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
  then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
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
  left join mst_medicine_class as mix_cls on (mix.class_cd = med_cls.class_cd)
  left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
  left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd::text)
  left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1'')
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
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "strnig", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @ordNo 使用', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7, 'SELECT
	rst_treatment_name,
	rst_kur_name,
	rst_bed_name,
	rst_dw,
CASE

	WHEN abs(
	to_number (
REPLACE (
( date_trunc ( ''day'', to_timestamp ( ord.treat_date, ''yyyyMMdd hh24:mi:ss'' ) ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text,
	''days'',
	''''
	),
	''99999''
	)
	) < abs(
		to_number (
			REPLACE ( ( date_trunc ( ''day'',to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
			''99999''
		)
		) THEN
		mst.in_hospital_cd_a1 ELSE mst.in_hospital_cd_b1
	END AS rst_trea_in_hospital_cd_1,
CASE

		WHEN abs(
			to_number (
				REPLACE (
					( date_trunc ( ''day'', to_timestamp ( ord.treat_date, ''yyyyMMdd hh24:mi:ss'' ) ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text,
					''days'',
					''''
				),
				''99999''
			)
			) < abs(
			to_number (
				REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
				''99999''
			)
			) THEN
			mst.in_hospital_cd_a2 ELSE mst.in_hospital_cd_b2
		END AS rst_trea_in_hospital_cd_2,
	CASE

			WHEN abs(
				to_number (
					REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text, ''days'', '''' ),
					''99999''
				)
				) < abs(
				to_number (
					REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
					''99999''
				)
				) THEN
				mst.in_hospital_cd_a3 ELSE mst.in_hospital_cd_b3
			END AS rst_trea_in_hospital_cd_3,
		CASE

				WHEN abs(
					to_number (
						REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text, ''days'', '''' ),
						''99999''
					)
					) < abs(
					to_number (
						REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
						''99999''
					)
					) THEN
					mst.in_hospital_cd_a4 ELSE mst.in_hospital_cd_b4
				END AS rst_trea_in_hospital_cd_4,
				msk.in_hospital_cd_1 AS rst_kur_in_hospital_cd_1,
				msb.in_hospital_cd_1 AS rst_bed_in_hospital_cd_1,
				msb.in_hospital_cd_2 AS rst_bed_in_hospital_cd_2
			FROM
				ord_main ord
				LEFT JOIN mst_treatment mst ON ( ord.rst_treatment_cd = mst.treatment_cd AND mst.is_del = ''0'' AND mst.is_disp = ''1'' )
				LEFT JOIN mst_kur msk ON ( ord.rst_kur_cd = msk.kur_cd AND msk.is_del = ''0'' )
				LEFT JOIN mst_bed msb ON ( ord.rst_bed_cd = msb.bed_cd AND msb.is_disp = ''1'' AND msb.is_del = ''0'' )
			WHERE
				ord.pat_id = @patId
				AND ord.ord_no = @ordNo
			AND ord.is_del = ''0''
AND ord.rst_dialysis_state <> ''0'';', 2, '[{"preview":"テスト治療方法","can_calc":"0","data_code":"rst_treatment_name","data_name":"治療方法名","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_treatment_name","disp_format":"","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_trea_in_hospital_cd_1","data_name":"治療方法連携コード１","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_trea_in_hospital_cd_1","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_trea_in_hospital_cd_2","data_name":"治療方法連携コード２","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_trea_in_hospital_cd_2","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_trea_in_hospital_cd_3","data_name":"治療方法連携コード３","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_trea_in_hospital_cd_3","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_trea_in_hospital_cd_4","data_name":"治療方法連携コード４","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_trea_in_hospital_cd_4","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"テストクール","can_calc":"0","data_code":"rst_kur_name","data_name":"クール名","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_kur_name","disp_format":"","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_kur_in_hospital_cd_1","data_name":"クール連携コード","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_kur_in_hospital_cd_1","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"テストベッド","can_calc":"0","data_code":"rst_bed_name","data_name":"ベッド名","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_bed_name","disp_format":"","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_bed_in_hospital_cd_1","data_name":"ベッド連携コード１","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_bed_in_hospital_cd_1","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"1","data_code":"rst_bed_in_hospital_cd_2","data_name":"ベッド連携コード２","data_type":"string","conv_table":[],"data_class":"実績情報","field_name":"rst_bed_in_hospital_cd_2","data_category":"実績","facility_table":"","facility_filter_type":"0"},{"preview":"55.00","can_calc":"1","data_code":"rst_dw","data_name":"DW","data_type":"decimal","conv_table":[],"data_class":"実績情報","field_name":"rst_dw","disp_format":"0.00","data_category":"実績","facility_table":"","facility_filter_type":"0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', NULL, '2019-09-17 11:32:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9, 'WITH dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	kr AS (
	SELECT
		*
	FROM
		mst_kur
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
	),
	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	dmcc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_class''
	),
	meqc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment_class''
	),
	dmccc AS (
	SELECT
		index_no AS medi_code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine''
	),
	meqcc AS (
	SELECT
		index_no AS meq_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_code,
		order_cd ->> ''name'' AS meq_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment''
	) SELECT
	disp_order,
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	class_cd,
	cd,
	pk_order,
	do_action
FROM
	(
	SELECT
		om.ord_no AS ord_no,
		1 AS disp_order,
		om.treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		1 AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		''0'' AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action
	FROM
		ord_main om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
		AND om.is_del = ''0'' UNION ALL
		(
		SELECT
			emq.ord_no,
			emq.disp_order,
			emq.treat_date,
			emq.kind,
			emq.NAME,
			emq.Amount,
			emq.Unit,
			emq.in_hospital_cd_1,
			emq.in_hospital_cd_2,
			emq.in_hospital_cd_3,
			emq.in_hospital_cd_4,
			emq.class_cd,
			emq.cd,
			meqc.code_order,
			meqcc.meq_order AS order_cd,
		  emq.pk_order AS pk_order,
			emq.do_action
		FROM
			(
				SELECT--吸着カラム
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--1次膜
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--2次膜
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(A針)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(V針)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(SN)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--血液回路
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--医材登録
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				CAST( save.ind_rst_value AS DECIMAL) AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main AS om
				LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''2''
										and save.ind_rst_class = ''1''
				LEFT OUTER JOIN eq ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0''
				AND eq.class_cd <> - 1
			) emq
			LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
			LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
		ORDER BY
			meqc.code_order,meqcc.meq_order
		) UNION ALL--医材未登録
								(
								SELECT
									om.ord_no AS ord_no,
									3 AS disp_order,
									om.treat_date,
									COALESCE ( eqc.class_name, '''' ) AS kind,
									eq.equipment_name AS NAME,
									CAST( save.ind_rst_value AS DECIMAL) AS Amount,
									COALESCE ( eq.unit, '''' ) AS Unit,
									eq.in_hospital_cd_1,
									eq.in_hospital_cd_2,
									eq.in_hospital_cd_3,
									eq.in_hospital_cd_4,
									eq.class_cd :: INTEGER AS class_cd,
									eq.equipment_cd :: TEXT AS cd,
									0 AS code_order,
									0 AS order_cd,
		              eq.equipment_cd AS pk_order,
									''医材'' AS do_action
								FROM
									ord_main AS om
									LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''2''
										and save.ind_rst_class = ''1''
									LEFT OUTER JOIN eq ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = eq.equipment_cd
									LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
									LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
								WHERE
									om.ord_no IN ( @ordNos )
									AND eq.class_cd IN ( @eqIds )
									AND om.is_del = ''0''
									AND eq.class_cd = - 1
								) UNION ALL--投薬登録
								(
								SELECT
									mdcc.ord_no AS ord_no,
									mdcc.disp_order,
									mdcc.treat_date,
									mdcc.kind AS kind,
									mdcc.NAME AS NAME,
									mdcc.Amount AS Amount,
									mdcc.unit AS Unit,
									mdcc.in_hospital_cd_1,
									mdcc.in_hospital_cd_2,
									mdcc.in_hospital_cd_3,
									mdcc.in_hospital_cd_4,
									mdcc.class_cd,
									mdcc.cd,
									dmcc.code_order,
									dmccc.medi_code_order AS order_cd,
		              mdcc.pk_order,
									mdcc.do_action
								FROM
									(
									SELECT
										om.ord_no AS ord_no,
										4 AS disp_order,
										om.treat_date,
										COALESCE ( mdc.class_name, '''' ) AS kind,
										md.medicine_name AS NAME,
										CAST( save.ind_rst_value AS DECIMAL) AS Amount,
										COALESCE ( md.unit, '''' ) AS Unit,
										md.in_hospital_cd_1,
										md.in_hospital_cd_2,
										md.in_hospital_cd_3,
										md.in_hospital_cd_4,
										md.class_cd AS class_cd,
										''0'' AS cd,
										md.medicine_cd AS pk_order,
										''投薬'' AS do_action
									FROM
										ord_main AS om
										LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''1''
										and save.supplies_class = ''12'' and save.ind_rst_class = ''1''
										LEFT OUTER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
										LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
										LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
									WHERE
										om.ord_no IN ( @ordNos )
										AND md.class_cd IN ( @medIds )
										AND om.is_del = ''0''
										AND md.class_cd <> - 1 UNION ALL
										SELECT--投与薬剤情報(調製)
										om.ord_no AS ord_no,
										4 AS disp_order,
										om.treat_date,
										COALESCE ( mdc.class_name, '''' ) AS kind,
										md.medicine_name AS NAME,
										CAST( save.ind_rst_value AS DECIMAL)  AS Amount,
										COALESCE ( md.unit, '''' ) AS Unit,
										md.in_hospital_cd_1,
										md.in_hospital_cd_2,
										md.in_hospital_cd_3,
										md.in_hospital_cd_4,
										md.class_cd AS class_cd,
										''0'' AS cd,
										md.medicine_cd AS pk_order,
										''投薬'' AS do_action
									FROM
										ord_main AS om
										LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
										and om.facility_cd = save.facility_cd and save.supplies_source_class = ''1''
										and save.supplies_class = ''20'' and save.ind_rst_class = ''1''
				            LEFT OUTER JOIN md ON md.medicine_cd = TO_NUMBER( save.supplies_cd, ''999999999999'' )
										LEFT OUTER JOIN mdc ON mdc.class_cd = md.class_cd
									WHERE
										om.ord_no IN ( @ordNos )
										AND md.class_cd IN ( @medIds )
										AND om.is_del = ''0''
										AND md.class_cd <> - 1
										UNION ALL--透析液
						(
						SELECT
							om.ord_no AS ord_no,
							4 AS disp_order,
							om.treat_date,
							COALESCE ( mdc.class_name, '''' ) AS kind,
							md.medicine_name AS NAME,
							CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
							COALESCE ( md.unit, '''' ) AS Unit,
							md.in_hospital_cd_1,
							md.in_hospital_cd_2,
							md.in_hospital_cd_3,
							md.in_hospital_cd_4,
							md.class_cd :: INTEGER AS class_cd,
							''0'' AS cd,
							md.medicine_cd AS pk_order,
							''投薬'' AS do_action
						FROM
							ord_main om
							LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
							LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
							LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						WHERE
							om.ord_no IN ( @ordNos )
							AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
							AND md.class_cd IN ( @medIds )
							AND om.is_del = ''0''
						) UNION ALL--補液
					SELECT
						om.ord_no AS ord_no,
						4 AS disp_order,
						om.treat_date,
						COALESCE ( mdc.class_name, '''' ) AS kind,
						md.medicine_name AS NAME,
						CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
						md.class_cd :: INTEGER AS class_cd,
						''0'' AS cd,
						md.medicine_cd AS pk_order,
						''投薬'' AS do_action
					FROM
						ord_main om
						LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
						AND md.class_cd IN ( @medIds )
						AND om.is_del = ''0'' UNION ALL--抗凝固剤
					SELECT
						om.ord_no AS ord_no,
						4 AS disp_order,
						om.treat_date,
						COALESCE ( mdc.class_name, '''' ) AS kind,
						md.medicine_name AS NAME,
						COALESCE (
							CEIL (
								(
									( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) /
								CASE

										WHEN md.unit_converted_amount IS NULL
										OR md.unit_converted_amount = 0 THEN
											1 ELSE md.unit_converted_amount
										END
											) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
										),
										( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) )
									) AS Amount,
					COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					md.in_hospital_cd_3,
					md.in_hospital_cd_4,
					md.class_cd :: INTEGER AS class_cd,
					''0'' AS cd,
					md.medicine_cd AS pk_order,
					''投薬'' AS do_action
				FROM
					ord_main om
					LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
					LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
					LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				WHERE
					om.ord_no IN ( @ordNos )
					AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
					AND md.class_cd IN ( @medIds )
					AND om.is_del = ''0'' UNION ALL--抗凝固剤(調製)
				SELECT
					om.ord_no AS ord_no,
					4 AS disp_order,
					om.treat_date,
					COALESCE ( mdc.class_name, '''' ) AS kind,
					md.medicine_name AS NAME,
					(
						COALESCE (
							CEIL (
								(
									( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) /
								CASE

										WHEN md.unit_converted_amount IS NULL
										OR md.unit_converted_amount = 0 THEN
											1 ELSE md.unit_converted_amount
										END
											) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
										),
										( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) )
									) * CAST( mmxd ->> ''amount'' AS DECIMAL)
								) AS Amount,
								COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
								md.in_hospital_cd_1,
								md.in_hospital_cd_2,
								md.in_hospital_cd_3,
								md.in_hospital_cd_4,
								md.class_cd :: INTEGER AS class_cd,
								''0'' AS cd,
					    	md.medicine_cd AS pk_order,
								''投薬'' AS do_action
							FROM
								ord_main om
								LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
								CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
								LEFT OUTER JOIN md ON md.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
								LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
								LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
							WHERE
								om.ord_no IN ( @ordNos )
								AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
								AND md.class_cd IN ( @medIds )
								AND om.is_del = ''0''
									) mdcc
									LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
									LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
								ORDER BY
									dmcc.code_order,dmccc.medi_code_order ASC
								) UNION ALL--投薬未登録
								(
								SELECT
									om.ord_no AS ord_no,
									5 AS disp_order,
									om.treat_date,
									COALESCE ( mdc.class_name, '''' ) AS kind,
									md.medicine_name AS NAME,
									CAST( save.ind_rst_value AS DECIMAL) AS Amount,
									COALESCE ( md.unit, '''' ) AS Unit,
									md.in_hospital_cd_1,
									md.in_hospital_cd_2,
									md.in_hospital_cd_3,
									md.in_hospital_cd_4,
									- 1 AS class_cd,
									''0'' AS cd,
									0 AS code_order,
									0 AS order_cd,
					      	md.medicine_cd AS pk_order,
									''投薬'' AS do_action
								FROM
									ord_main AS om
									LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.ind_rst_class = ''1''
									LEFT OUTER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
									LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
									LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
								WHERE
									om.ord_no IN ( @ordNos )
									AND md.class_cd IN ( @medIds )
									AND om.is_del = ''0''
									AND md.class_cd = - 1
								)
							) AS EquipmentList
						GROUP BY
							disp_order,
							treat_date,
							kind,
							NAME,
							Unit,
							in_hospital_cd_1,
							in_hospital_cd_2,
							in_hospital_cd_3,
							in_hospital_cd_4,
							class_cd,
							cd,
							code_order,
							order_cd,
							pk_order,
							do_action
						HAVING
							SUM ( Amount ) > 0
						ORDER BY
							disp_order,
						code_order,
						order_cd,
						pk_order,
	kind;', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (11, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
fncd AS ( SELECT facility_cd FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) LIMIT 1 ),
dz AS ( SELECT * FROM mst_dialyzer mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ) SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
NAME,
code,
kur_cd,
kur_name,
SUM ( Amount ) AS amount,
unit,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		COALESCE ( eqc.class_name, '''' ) AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4
			FROM
				om
				INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
				AND md.class_cd IN ( @medIds )
				LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL  UNION ALL--抗凝固剤調製薬剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		mdx.medicine_mix_name AS NAME,
		mdx.medicine_mix_cd AS code,
		( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) AS Amount,
				COALESCE ( mdx.unit, '''' ) AS Unit,
				mdx.in_hospital_cd_1,
				mdx.in_hospital_cd_2,
				mdx.in_hospital_cd_3,
				null as in_hospital_cd_4
			FROM
				om
				INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
				LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CAST(save.ind_rst_value AS DECIMAL)  AS Amount,
						COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''12''
									and save.ind_rst_class = ''1''
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				mdx.medicine_mix_name AS NAME,
				mdx.medicine_mix_cd AS code,
				CAST(save.ind_rst_value AS DECIMAL)  AS Amount,
						 COALESCE ( mdx.unit, '''' )  AS Unit,
						mdx.in_hospital_cd_1,
						mdx.in_hospital_cd_2,
						mdx.in_hospital_cd_3,
						null as in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''13''
									and save.ind_rst_class = ''1''
						INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
						AND mdx.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--医材
					SELECT
						12 AS disp_order,
						om.treat_date,
						kr.kur_cd,
						COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
						COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
						om.pat_id,
					CASE

							WHEN eqc.class_name IS NULL THEN
							''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
						END AS kind,
						eq.equipment_name AS NAME,
						eq.equipment_cd AS code,
						CAST(save.ind_rst_value AS DECIMAL)  AS Amount,
						COALESCE ( eq.unit, '''' ) AS Unit,
						eq.in_hospital_cd_1,
						eq.in_hospital_cd_2,
						eq.in_hospital_cd_3,
						eq.in_hospital_cd_4
					FROM
						om
            LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
						INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
						AND eq.class_cd IN ( @eqIds )
						LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
					) AS EquipmentList
				GROUP BY
					treat_date,
					kind,
					NAME,
					code,
					kur_cd,
					kur_name,
					Unit,
					bed_name,
					pat_id,
					pat_id1,
					disp_order,
					in_hospital_cd_1,
					in_hospital_cd_2,
					in_hospital_cd_3,
					in_hospital_cd_4
				ORDER BY
					disp_order,
					kind,
					code,
					NAME,
					kur_cd,
					kur_name,
				bed_name,
	pat_id;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(器材)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (16, 'WITH plan_time AS (
	SELECT
		om.ord_no,
		om.ind_cond_info :: json #>> ''{1, value}'' AS plan_time,
		( pat_unique.physical_info :: json ->> 0 ) :: json ->> ''dw'' || '' Kg'' AS cond_dw,
		om.ind_cond_info :: json #>> ''{3, value}'' || '' Kg'' AS cond_tg_wei,
		om.ind_treatment_name AS cond_tre_nm,
		om.ind_cond_info :: json #>> ''{14, value}'' || '' mL/min'' AS cond_bld_fl
	FROM
		ord_main om
		INNER JOIN pat_unique ON om.pat_id = pat_unique.pat_id
		AND pat_unique.is_del = ''0''
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
	mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 ),
	mst_room_bed_group_2 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 2 ),
	medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_class''
	),
	medic_mix AS (
	SELECT
		index_no AS medic_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_class''
	),
	equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment_class''
	),
	medi AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine''
	),
	equi AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment''
	),
	dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_dialyzer''
	),
	medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_mix''
	),
  spi AS (
	SELECT
		index_no AS spitz_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS spitz_code,
		order_cd ->> ''name'' AS spitz_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_spitz''
	),
	bed AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_bed''
	),
	kur AS (
	SELECT
		index_no AS kur_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS kur_code,
		order_cd ->> ''name'' AS kur_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_kur''
	),
	room_bed AS (
	SELECT
		index_no AS room_bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS room_bed_code,
		order_cd ->> ''name'' AS room_bed_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_room_bed_group''
	),
	EquipmentList_Tmp AS (
	SELECT
		to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
		medicine_cd,
		medicine_class_cd,
		equipment_cd,
		equipment_class_cd,
		dialyzer_cd,
		kur_cd,
		kur_name,
		bed_name,
		bed_cd,
		pat_id,
		kind,
		NAME,
		amount,
		unit,
		function_class,
		area,
		ufr,
		koa,
		material,
		wetdry,
		disp_order,
		class_name,
		class_ename,
		anticoagulant_name,
		plan_time.plan_time,
		plan_time.cond_dw,
		plan_time.cond_tg_wei,
		plan_time.cond_tre_nm,
		plan_time.cond_bld_fl,
		in_hospital_cd_1,
		in_hospital_cd_2,
		equip_circuit,
		cond_ac_shot,
		cond_ac_spd,
		cond_ac_dur_total,
		cond_ip_use,
		cond_ip_start,
		cond_ip_spd,
		cond_ip_shot_st,
		cond_ip_shot,
		cond_ip_off,
		cond_ip_off_tm,
		cond_ip_ok,
		cond_ip_ok_tm,
		cond_dl_fl,
		cond_dl_am,
		cond_dl_temp,
		cond_rl_am,
		cond_rl_sel,
		cond_rl_use,
		cond_rl_temp,
		cond_rl_spd,
		medi_timing,
		medi_proc,
		num_unit,
		cond_va_dir,
		cond_va,
		equip_pnc_cls
	FROM
		(
			WITH Anticoagulant AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1'' THEN
					md.medicine_name ELSE mdx.medicine_mix_name
				END AS medicine_name,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1'' THEN
					md.unit ELSE mdx.unit
				END AS unit,
				om.ind_cond_info :: json #>> ''{25, medicine_type}'' AS medicine_type,
				to_number( om.ind_cond_info :: json #>> ''{25,value}'', ''9999999999'' ) AS medicine_cd
			FROM
				ord_main om
				LEFT OUTER JOIN mst_medicine md ON (
					om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1''
					AND TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
					AND md.is_del = ''0''
					AND md.is_disp = ''1''
				)
				LEFT OUTER JOIN mst_medicine_mix mdx ON (
					om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''2''
					AND TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
					AND mdx.is_del = ''0''
					AND mdx.is_disp = ''1''
				)
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_dialysisLiquid AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
				to_number( om.ind_cond_info :: json #>> ''{15,value}'', ''9999999999'' ) AS medicine_cd,
				om.ind_cond_info :: json #>> ''{15, medicine_type}'' AS medicine_type,
				om.ind_cond_info :: json #>> ''{16, value}'' AS cond_dl_fl,
				om.ind_cond_info :: json #>> ''{17, value}'' AS cond_dl_am,
				om.ind_cond_info :: json #>> ''{18, value}'' AS cond_dl_temp
			FROM
				ord_main om
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_replenishLiquid AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
				to_number( om.ind_cond_info :: json #>> ''{19,value}'', ''9999999999'' ) AS medicine_cd,
				om.ind_cond_info :: json #>> ''{19, medicine_type}'' AS medicine_type
			FROM
				ord_main om
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_medi AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				medi,
				to_number( medi ->> ''cd'', ''9999999999'' ) AS cd,
				medi ->> ''medicine_type'' AS medicine_type,
				medi ->> ''amount'' AS amount
			FROM
				ord_main AS om
				CROSS JOIN LATERAL json_array_elements ( om.ind_medi_info :: json ) medi
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.is_del = ''0''
			) SELECT
			1 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			dz.dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			1 AS Amount,
			COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
			function_class,
			area || ''㎡'' AS area,
			ufr,
			koa,
			material,
			wetdry,
			''ダイアライザ'' AS class_name,
			Anticoagulant.medicine_name AS Anticoagulant_name,
			om.ord_no,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			eq.equipment_name AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			''1本'' AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Dialyser'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_dialyzer dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''9999999999'' ) = dz.dialyzer_cd
			AND dz.is_del = ''0''
			AND dz.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
			LEFT OUTER JOIN Anticoagulant ON om.ord_no = Anticoagulant.ord_no
			LEFT OUTER JOIN mst_equipment eq ON to_number( om.ind_cond_info :: json #>> ''{13,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND 0 NOT IN ( @diaIds ) UNION ALL--吸着カラム
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''吸着カラム'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Adsorption'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--1次膜
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''1次膜'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Film1'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--2次膜
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''2次膜'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Film2'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(A針)
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(A針)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			va.va_direct AS cond_va_dir,
			va.va_name AS cond_va,
			''A針'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
			LEFT OUTER JOIN mst_va va ON to_number( om.ind_cond_info :: json #>> ''{2, value}'', ''9999999999'' ) = va.va_cd
			AND va.is_del = ''0''
			AND va.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(V針)
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(V針)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			''V針'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(SN)
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(SN)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			''SN'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--血液回路
		SELECT
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''血液回路'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''BloodRoad'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--透析液
		SELECT
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CAST( cond_dl_am AS DECIMAL) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''透析液'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			om.cond_dl_fl || ''mL/min'' AS cond_dl_fl,
			concat ( cond_dl_am, md.unit) AS cond_dl_am,
			om.cond_dl_temp || ''℃'' AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( cond_dl_am, md.unit_second ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''DialysisLiquid'' AS class_ename
		FROM
			ord_dialysisLiquid om
			LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
			LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
			AND mdc.is_del = ''0''
			AND mdc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--補液
		SELECT
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''補液'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			om.ind_cond_info :: json #>> ''{20, value}'' || ''L'' AS cond_rl_am,
		CASE

				WHEN om.ind_cond_info :: json #>> ''{21, value}'' = ''0'' THEN
				''後補液'' ELSE''前補液''
			END AS cond_rl_sel,
			om.ind_cond_info :: json #>> ''{22, value}'' ||
			md.unit AS cond_rl_use,
			om.ind_cond_info :: json #>> ''{23, value}'' || ''℃'' AS cond_rl_temp,
			om.ind_cond_info :: json #>> ''{24, value}'' || ''L/min'' AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			om.ind_cond_info :: json #>> ''{22,value}'' ||
			COALESCE ( md.unit_second, '''' ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''ReplenishLiquid'' AS class_ename
		FROM
			ord_replenishLiquid om
			LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
			LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
			AND mdc.is_del = ''0''
			AND mdc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--抗凝固剤
		SELECT
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CEIL (
				(
					( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) /
				CASE

						WHEN md.unit_converted_amount = 0 THEN
						1 ELSE md.unit_converted_amount
					END
					) * md.unit_converted_amount_second
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				NULL AS function_class,
				NULL AS area,
				NULL AS ufr,
				NULL AS koa,
				NULL AS material,
				NULL AS wetdry,
				''抗凝固剤'' AS class_name,
				NULL AS Anticoagulant_name,
				om.ord_no,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				NULL AS equip_circuit,
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL ) || om.unit AS cond_ac_shot,
				CAST( om.ind_cond_info :: json #>> ''{27,value}'' AS DECIMAL) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS cond_ac_dur_total,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{29,value}'' = ''1'' THEN
					''使用する'' ELSE''使用しない''
				END AS cond_ip_use,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{30,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_start,
				om.ind_cond_info :: json #>> ''{32,value}'' || ''mL/h'' AS cond_ip_spd,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{34,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_shot_st,
				om.ind_cond_info :: json #>> ''{31,value}'' || ''mL'' AS cond_ip_shot,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{35,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_off,
				om.ind_cond_info :: json #>> ''{36,value}'' || ''分'' AS cond_ip_off_tm,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{37,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_ok,
				om.ind_cond_info :: json #>> ''{38,value}'' || ''分'' AS cond_ip_ok_tm,
				NULL AS cond_dl_fl,
				NULL AS cond_dl_am,
				NULL AS cond_dl_temp,
				NULL AS cond_rl_am,
				NULL AS cond_rl_sel,
				NULL AS cond_rl_use,
				NULL AS cond_rl_temp,
				NULL AS cond_rl_spd,
				NULL AS medi_timing,
				NULL AS medi_proc,
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS num_unit,
				NULL AS cond_va_dir,
				NULL AS cond_va,
				NULL AS equip_pnc_cls,
				''AntiCoagulan'' AS class_ename
			FROM
				Anticoagulant om
				LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
				LEFT OUTER JOIN mst_medicine_mix mdx ON ( om.medicine_type = ''2'' AND om.medicine_cd = mdx.medicine_mix_cd AND mdx.is_del = ''0'' AND mdx.is_disp = ''1'' )
				LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
				AND mdc.is_del = ''0''
				AND mdc.is_disp = ''1''
				LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
				AND kr.is_del = ''0''
				LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
				AND bd.is_del = ''0''
				AND bd.is_disp = ''1''
			WHERE
				( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--抗凝固剤(調製薬剤)
			SELECT
				4 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mmx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				mmx.medicine_mix_name AS NAME,
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) AS Amount,
				COALESCE ( mmx.unit, '''' ) AS Unit,
				NULL AS function_class,
				NULL AS area,
				NULL AS ufr,
				NULL AS koa,
				NULL AS material,
				NULL AS wetdry,
				''抗凝固剤'' AS class_name,
				NULL AS Anticoagulant_name,
				om.ord_no,
				mmx.in_hospital_cd_1,
				mmx.in_hospital_cd_2,
				NULL AS equip_circuit,
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) || om.unit AS cond_ac_shot,
				CAST( om.ind_cond_info :: json #>> ''{27,value}'' AS DECIMAL) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS cond_ac_dur_total,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{29,value}'' = ''1'' THEN
					''使用する'' ELSE''使用しない''
				END AS cond_ip_use,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{30,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_start,
				om.ind_cond_info :: json #>> ''{32,value}'' || ''mL/h'' AS cond_ip_spd,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{34,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_shot_st,
				om.ind_cond_info :: json #>> ''{31,value}'' || ''mL'' AS cond_ip_shot,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{35,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_off,
				om.ind_cond_info :: json #>> ''{36,value}'' || ''分'' AS cond_ip_off_tm,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{37,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_ok,
				om.ind_cond_info :: json #>> ''{38,value}'' || ''分'' AS cond_ip_ok_tm,
				NULL AS cond_dl_fl,
				NULL AS cond_dl_am,
				NULL AS cond_dl_temp,
				NULL AS cond_rl_am,
				NULL AS cond_rl_sel,
				NULL AS cond_rl_use,
				NULL AS cond_rl_temp,
				NULL AS cond_rl_spd,
				NULL AS medi_timing,
				NULL AS medi_proc,
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) || COALESCE ( mmx.unit, '''' ) AS num_unit,
				NULL AS cond_va_dir,
				NULL AS cond_va,
				NULL AS equip_pnc_cls,
				''AntiCoagulan'' AS class_ename
			FROM
				Anticoagulant om
				LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
				CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
				LEFT OUTER JOIN mst_medicine_class mdc ON mmx.class_cd = mdc.class_cd
				AND mdc.is_del = ''0''
				AND mdc.is_disp = ''1''
				LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
				AND kr.is_del = ''0''
				LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
				AND bd.is_del = ''0''
				AND bd.is_disp = ''1''
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
				AND mmx.class_cd IN ( @medIds ) UNION ALL--投薬(薬剤)
			SELECT
				3 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				md.medicine_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CEIL (
					( ( CAST( medi ->> ''amount'' AS DECIMAL) ) / CASE WHEN md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END ) /
				CASE

						WHEN md.unit_converted_amount_second = 0 THEN
						1 ELSE md.unit_converted_amount_second
					END
					) AS Amount,
					COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''投与薬剤'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					mt.medicate_timing_name AS medi_timing,
					mp.pricedure_name AS medi_proc,
					om.amount || COALESCE ( md.unit, '''' ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Medicine'' AS class_ename
				FROM
					ord_medi AS om
					LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
					LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
					AND mdc.is_del = ''0''
					AND mdc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
					LEFT OUTER JOIN mst_medicate_timing mt ON to_number( medi ->> ''timing_cd'', ''9999999999'' ) = mt.medicate_timing_cd
					AND mt.is_del = ''0''
					AND mt.is_disp = ''1''
					LEFT OUTER JOIN mst_procedure mp ON to_number( medi ->> ''procedure_cd'', ''9999999999'' ) = mp.procedure_cd
					AND mp.is_del = ''0''
					AND mp.is_disp = ''1''
				WHERE
					( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--投薬(調製薬剤)
				SELECT
					4 AS disp_order,
					NULL AS equipment_cd,
					NULL AS equipment_class_cd,
					mdx.medicine_mix_cd :: TEXT AS medicine_cd,
					mdc.class_cd :: TEXT AS medicine_class_cd,
			    NULL AS dialyzer_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( mdc.class_name, '''' ) AS kind,
					mdx.medicine_mix_name AS NAME,
					CAST( om.amount AS DECIMAL) AS Amount,
					COALESCE ( mdx.unit, '''' ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''投与薬剤'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					mdx.in_hospital_cd_1,
					mdx.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					mt.medicate_timing_name AS medi_timing,
					mp.pricedure_name AS medi_proc,
					CAST( om.amount AS DECIMAL) || COALESCE ( mdx.unit, '''' ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Medicine'' AS class_ename
				FROM
					ord_medi AS om
					LEFT OUTER JOIN (
					SELECT
						medicine_mix_cd,
						unit AS unit,
						class_cd,
						medicine_mix_name,
						in_hospital_cd_1,
						in_hospital_cd_2
					FROM
						mst_medicine_mix
					WHERE
						mst_medicine_mix.is_del = ''0''
						AND mst_medicine_mix.is_disp = ''1''
						AND mst_medicine_mix.class_cd IN ( @medIds )
					) mdx ON om.cd = mdx.medicine_mix_cd
					LEFT OUTER JOIN mst_medicine_class mdc ON mdx.class_cd = mdc.class_cd
					AND mdc.is_del = ''0''
					AND mdc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
					LEFT OUTER JOIN mst_medicate_timing mt ON to_number( medi ->> ''timing_cd'', ''9999999999'' ) = mt.medicate_timing_cd
					AND mt.is_del = ''0''
					AND mt.is_disp = ''1''
					LEFT OUTER JOIN mst_procedure mp ON to_number( medi ->> ''procedure_cd'', ''9999999999'' ) = mp.procedure_cd
					AND mp.is_del = ''0''
					AND mp.is_disp = ''1''
				WHERE
					om.medicine_type = ''2'' UNION ALL--医材
				SELECT
					2 AS disp_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS medicine_cd,
					NULL AS medicine_class_cd,
			    NULL AS dialyzer_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( eqc.class_name, '''' ) AS kind,
					eq.equipment_name AS NAME,
					( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
					COALESCE ( eq.unit, '''' ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''Equip'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					NULL AS medi_timing,
					NULL AS medi_proc,
					concat ( eqi ->> ''amount'', eq.unit ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Equip'' AS class_ename
				FROM
					ord_main AS om
					CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: json ) eqi
					LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( eqi ->> ''cd'', ''9999999999'' ) = eq.equipment_cd
					AND eq.is_del = ''0''
					AND eq.is_disp = ''1''
					LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
					AND eqc.is_del = ''0''
					AND eqc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
				WHERE
					om.ord_no IN ( @ordNos )
					AND om.is_del = ''0''
					AND eq.class_cd IN ( @eqIds )
				) AS EquipmentList
				INNER JOIN plan_time ON EquipmentList.ord_no = plan_time.ord_no
			) (SELECT
			bd.treat_date,
			bd.equipment_cd,
			bd.equipment_class_cd,
			bd.medicine_cd,
			bd.medicine_class_cd,
			bd.kur_cd,
			bd.kur_name,
			bd.bed_name,
			bd.bed_cd,
			bd.pat_id,
			bd.kind,
			bd.NAME,
			bd.amount,
			bd.unit,
			bd.function_class,
			bd.area,
			bd.ufr,
			bd.koa,
			bd.material,
			bd.wetdry,
			bd.disp_order,
			bd.class_name,
			bd.class_ename,
			bd.anticoagulant_name,
			bd.plan_time,
			bd.cond_dw,
			bd.cond_tg_wei,
			bd.cond_tre_nm,
			bd.cond_bld_fl,
			bd.in_hospital_cd_1,
			bd.in_hospital_cd_2,
			bd.equip_circuit,
			bd.cond_ac_shot,
			bd.cond_ac_spd,
			bd.cond_ac_dur_total,
			bd.cond_ip_use,
			bd.cond_ip_start,
			bd.cond_ip_spd,
			bd.cond_ip_shot_st,
			bd.cond_ip_shot,
			bd.cond_ip_off,
			bd.cond_ip_off_tm,
			bd.cond_ip_ok,
			bd.cond_ip_ok_tm,
			bd.cond_dl_fl,
			bd.cond_dl_am,
			bd.cond_dl_temp,
			bd.cond_rl_am,
			bd.cond_rl_sel,
			bd.cond_rl_use,
			bd.cond_rl_temp,
			bd.cond_rl_spd,
			bd.medi_timing,
			bd.medi_proc,
			bd.num_unit,
			bd.cond_va_dir,
			bd.cond_va,
			bd.equip_pnc_cls,
		CASE

				WHEN COUNT ( DISTINCT rbg1.room_bed_group_name ) = 0 THEN
				''グループ未登録''
				WHEN COUNT ( DISTINCT rbg1.room_bed_group_name ) = 1 THEN
				( MAX ( rbg1.room_bed_group_name ) ) ELSE''グループ複数選択''
			END AS room_bed_group_name_1,
		CASE

				WHEN COUNT ( DISTINCT rbg2.room_bed_group_name ) = 0 THEN
				''グループ未登録''
				WHEN COUNT ( DISTINCT rbg2.room_bed_group_name ) = 1 THEN
				( MAX ( rbg2.room_bed_group_name ) ) ELSE''グループ複数選択''
			END AS room_bed_group_name_2,
			NULL AS label_print,
			NULL AS is_in_hospital,
		medi.medi_order,
		medi_mix.medi_mix_order,
		equi.equi_order,
		bed.bed_order,
		medic.medic_order,
		equic.equic_order,
		medic_mix.medic_mix_order,
		dia.dia_order,
		MIN(rb1.room_bed_order) AS room_bed_group,
		MIN(rb2.room_bed_order) AS dialysis_room_group,
		NULL AS spitz_order
		FROM
			EquipmentList_Tmp AS bd
			LEFT OUTER JOIN medi ON medi.medi_code :: TEXT = bd.medicine_cd
			LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = bd.medicine_class_cd
			LEFT OUTER JOIN equi ON equi.equi_code = bd.equipment_cd
			LEFT OUTER JOIN equic ON equic.equic_code = bd.equipment_class_cd
			LEFT OUTER JOIN bed ON bed.bed_code = bd.bed_cd
			LEFT OUTER JOIN dia ON dia.dia_code = bd.dialyzer_cd
      LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = bd.medicine_cd
			LEFT OUTER JOIN medic_mix ON medic_mix.medic_mix_code :: TEXT = bd.medicine_class_cd
			-- ベッドグループ
			LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || bd.bed_cd) :: jsonb
			LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
			-- 透析室
			LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || bd.bed_cd) :: jsonb
			LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
		GROUP BY
			bd.equipment_cd,
			bd.equipment_class_cd,
			bd.medicine_cd,
			bd.medicine_class_cd,
			bd.treat_date,
			bd.kur_cd,
			bd.kur_name,
			bd.bed_name,
			bd.bed_cd,
			bd.pat_id,
			bd.kind,
			bd.NAME,
			bd.amount,
			bd.unit,
			bd.function_class,
			bd.area,
			bd.ufr,
			bd.koa,
			bd.material,
			bd.wetdry,
			bd.disp_order,
			bd.class_name,
			bd.class_ename,
			bd.anticoagulant_name,
			bd.plan_time,
			bd.cond_dw,
			bd.cond_tg_wei,
			bd.cond_tre_nm,
			bd.cond_bld_fl,
			bd.in_hospital_cd_1,
			bd.in_hospital_cd_2,
			bd.equip_circuit,
			bd.cond_ac_shot,
			bd.cond_ac_spd,
			bd.cond_ac_dur_total,
			bd.cond_ip_use,
			bd.cond_ip_start,
			bd.cond_ip_spd,
			bd.cond_ip_shot_st,
			bd.cond_ip_shot,
			bd.cond_ip_off,
			bd.cond_ip_off_tm,
			bd.cond_ip_ok,
			bd.cond_ip_ok_tm,
			bd.cond_dl_fl,
			bd.cond_dl_am,
			bd.cond_dl_temp,
			bd.cond_rl_am,
			bd.cond_rl_sel,
			bd.cond_rl_use,
			bd.cond_rl_temp,
			bd.cond_rl_spd,
			bd.medi_timing,
			bd.medi_proc,
			bd.num_unit,
			bd.cond_va_dir,
			bd.cond_va,
			bd.equip_pnc_cls,
			medi.medi_order,
			medi_mix.medi_mix_order,
			equi.equi_order,
			bed.bed_order,
			medic.medic_order,
			equic.equic_order,
			medic_mix.medic_mix_order,
			dia.dia_order
		ORDER BY
			disp_order,
			dia.dia_order NULLS LAST,
			medic.medic_order NULLS LAST ,
			equic.equic_order NULLS LAST ,
			medi.medi_order,
			medi_mix.medi_mix_order,
			equi.equi_order,
			bd.kur_cd NULLS LAST,
			bd.bed_cd NULLS LAST)
			UNION ALL--採血管
		(SELECT NULL AS
			treat_date,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS kur_cd,
			NULL AS kur_name,
			NULL AS bed_name,
			NULL AS bed_cd,
			P.pat_id,
			NULL AS kind,
			spitz.spitz_name AS NAME,
			NULL AS amount,
			NULL AS unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			5 AS disp_order,
			P.reg_order_class AS class_name,
			NULL AS class_ename,
			NULL AS anticoagulant_name,
			NULL AS plan_time,
			NULL AS cond_dw,
			NULL AS cond_tg_wei,
			NULL AS cond_tre_nm,
			NULL AS cond_bld_fl,
			NULL AS in_hospital_cd_1,
			NULL AS in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			NULL AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			NULL AS room_bed_group_name_1,
			NULL AS room_bed_group_name_2,
			spitz.label_print AS label_print,
			spitz.is_in_hospital AS is_in_hospital ,
			NULL AS medi_order,
			NULL AS medi_mix_order,
			NULL AS equi_order,
			NULL AS bed_order,
			NULL AS medic_order,
			NULL AS equic_order,
			NULL AS medic_mix_order,
			NULL AS dia_order,
		  NULL AS room_bed_order1,
		  NULL AS room_bed_order2,
			spi.spitz_order
		FROM
			(
			SELECT M
				.*
			FROM
				pat_exam_main AS M
			WHERE
				M.is_del = ''0''
				AND jsonb_array_length ( M.order_exam_set_info ) > 0
				AND M.pat_id IN ( @patIds )
				AND M.reg_exam_date BETWEEN date_trunc( ''day'',  @treatDate :: TIMESTAMP )
				AND date_trunc( ''day'',  @treatDate :: TIMESTAMP ) + ''1 days - 1 milliseconds''
			ORDER BY
				M.reg_exam_date
			)
			P CROSS JOIN LATERAL json_array_elements ( P.order_label_info :: json ) info
			LEFT OUTER JOIN mst_spitz AS spitz ON info ->> ''spitz_cd'' = spitz.spitz_cd :: TEXT
			AND spitz.is_del = ''0''
			AND spitz.is_disp = ''1''
			LEFT OUTER JOIN spi ON spi.spitz_code = spitz.spitz_cd
		WHERE
			spitz.spitz_name IS NOT NULL
		ORDER BY
		  spi.spitz_order)', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "名称/採血管名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "disp_order", "data_name": "分類", "data_type": "Integer", "conv_table": [], "data_class": "", "field_name": "disp_order", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "class_name", "data_name": "分類/検査区分", "data_type": "String", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "物品情報", "field_name": "class_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "plan_time", "data_name": "透析時間", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "plan_time", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dw", "data_name": "DW", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_dw", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tg_wei", "data_name": "目標体重", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tg_wei", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tre_nm", "data_name": "治療項目", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tre_nm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_bld_fl", "data_name": "血流量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_bld_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "function_class", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "area", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "ufr", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "koa", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "material", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "wetdry", "data_name": "DRYWET", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "wetdry", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "anticoagulant_name", "data_name": "抗凝固剤", "data_type": "String", "conv_table": [], "data_class": "", "field_name": "anticoagulant_name", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "equip_circuit", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_shot", "data_name": "ワンショット量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_spd", "data_name": "持続速度", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_dur_total", "data_name": "持続総量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_dur_total", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_use", "data_name": "IP使用選択", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ip_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_start", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_spd", "data_name": "IP速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot_st", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot_st", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot", "data_name": "IPワンショット量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off_tm", "data_name": "IP電源自動切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok_tm", "data_name": "IP電源OKモニタ切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_fl", "data_name": "透析液流量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_am", "data_name": "透析液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_temp", "data_name": "透析温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_am", "data_name": "補液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_sel", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_sel", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_use", "data_name": "補液使用数", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_temp", "data_name": "補液温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_spd", "data_name": "補液速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_timing", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_timing", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_proc", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_proc", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "1", "can_calc": "0", "data_code": "num_unit", "data_name": "数量・単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "num_unit", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va_dir", "data_name": "VA方向", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va_dir", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_pnc_cls", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "equip_pnc_cls", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "ベッドグループ1", "can_calc": "", "data_code": "room_bed_group_name_1", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_1", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "透析室名１", "can_calc": "", "data_code": "room_bed_group_name_2", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_2", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "ラベル印字項目", "can_calc": "0", "data_code": "label_print", "data_name": "ラベル印字項目(採血管)", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "label_print", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "院内・院外", "can_calc": "0", "data_code": "is_in_hospital", "data_name": "院内・院外(採血管)", "data_type": "string", "conv_table": [{"code": "0", "disp": "院内", "item": "院内"}, {"code": "1", "disp": "院外", "item": "院外"}], "data_class": "物品情報", "field_name": "is_in_hospital", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (29, 'with  pat_facility as (
   select facility_cd
   from
    pat_exam_main
   where
     pat_id =  @patId limit 1
),
infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
),


result_table as (
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  case p.reg_order_class
	when ''0'' then ''9''
	else p.reg_order_class
  end as reg_order_class_sort,
  info->>''upper'' as upper,
  info->>''lower'' as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	  left join   infection_order as inf   on info->>''item_cd''::text=inf.infection_cd
ORDER BY
  result_exam_date,infection_cd_order )

	SELECT rt.*, lower || ''~'' || upper as normal_value FROM result_table AS rt;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "normal_value", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査結果(指定日) @patId @date 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (35, 'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''')  and item.is_del =''0'' and item.is_disp =''1''
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(セット・指定日) @patId @date 使用', '2020-03-25 22:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (36, 'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on  info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・日付範囲)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・日付範囲)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2, 3]}', '検査予定(セット・日付範囲) @patId @fromDate @toDate 使用', '2020-03-25 22:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (37, 'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''')  where item.is_del =''0'' and item.is_disp =''1''
  limit 100
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(セット・指定日以降) @patId @date 使用', '2020-03-25 22:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (45, 'with ord_tbl as (
  select
    facility_cd,
    pat_id,
    ind_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
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
	 and rst_dialysis_state = ''0'') and is_del = ''0'' and rst_dialysis_state = ''0'' ORDER BY treat_date ASC limit 1

), kur_tbl as (
  select
    *
  from
    mst_kur
  where
    mst_kur.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_kur.is_del = ''0''
), va_tbl as (
  select
    *
  from
    mst_va
  where
    mst_va.facility_cd = (select facility_cd from ord_tbl)
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
    mst_treatment.facility_cd = (select facility_cd from ord_tbl)
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
    mst_bed.facility_cd = (select facility_cd from ord_tbl)
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
    mst_machine.facility_cd = (select facility_cd from ord_tbl)
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
    mst_room_bed_group.facility_cd = (select facility_cd from ord_tbl)
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
    mst_dialyzer.facility_cd = (select facility_cd from ord_tbl)
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
    mst_medicine.facility_cd = (select facility_cd from ord_tbl)
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
    mst_medicine_mix.facility_cd = (select facility_cd from ord_tbl)
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
    mst_equipment.facility_cd = (select facility_cd from ord_tbl)
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
      pat_unique.pat_id = (select pat_id from ord_tbl)
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
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
  ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
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
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''1''

),
 b AS (
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
select g.*,
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ind_kur_cd as kur_cd,
  ord.ind_va_cd as va_cd,
  ord.ind_treatment_cd as treatment_cd,
	treatment_tbl.treatment_name AS treatment_name1,
  to_char(to_date(ord.ind_treat_start_time, ''HH24MI''), ''HH24:MI'') as treat_start_time,
  ord.ind_bed_cd as bed_cd,

  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  --ord.ind_cond_info->''2''->>''value_name_1'' as va,
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.ind_cond_info->''12''->>''value'' as single_needle,
  ord.ind_cond_info->''14''->>''value'' as blood_flow,
  ord.ind_cond_info->''15''->>''unit'' as dialysate_flow_unit,
  ord.ind_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.ind_cond_info->''17''->>''value'' as dialysate_amount,
  ord.ind_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.ind_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.ind_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.ind_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.ind_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.ind_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.ind_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.ind_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.ind_cond_info->''29''->>''value'' as ip,
  ord.ind_cond_info->''30''->>''value'' as ip_start,
  ord.ind_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.ind_cond_info->''32''->>''value'' as ip_speed,
  ord.ind_cond_info->''33''->>''value'' as ip_speed_max,
  ord.ind_cond_info->''34''->>''value'' as auto_one_shot,
  ord.ind_cond_info->''35''->>''value'' as ip_auto_off,
  ord.ind_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.ind_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.ind_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  CAST(ord.ind_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.ind_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.ind_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.ind_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.ind_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

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

  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.ind_cond_info->''3''->>''value''
  end as target_weight,
  pat_physical_tbl.dw,
  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  kur_tbl.kur_name as kur_name,
  va_tbl.va_name as va_name,
  va_tbl.in_hospital_cd_1 as va_in_hospital_cd_1,
  va_tbl.in_hospital_cd_2  as va_in_hospital_cd_2,

  va_tbl.va_direct as va_direct,
  treatment_tbl.treatment_name,
  treatment_tbl.device_mode,
	treatment_tbl.in_hospital_cd_a1 as treatment_in_hospital_cd_a1,
	treatment_tbl.in_hospital_cd_a2 as treatment_in_hospital_cd_a2,
	treatment_tbl.in_hospital_cd_a3 as treatment_in_hospital_cd_a3,
	treatment_tbl.in_hospital_cd_a4 as treatment_in_hospital_cd_a4,
	treatment_tbl.in_hospital_cd_b1 as treatment_in_hospital_cd_b1,
	treatment_tbl.in_hospital_cd_b2 as treatment_in_hospital_cd_b2,
	treatment_tbl.in_hospital_cd_b3 as treatment_in_hospital_cd_b3,
	treatment_tbl.in_hospital_cd_b4 as treatment_in_hospital_cd_b4,
  bed_tbl.*,
	bed_tbl.in_hospital_cd_1 as bed_in_hospital_cd_1,
	bed_tbl.in_hospital_cd_2 as bed_in_hospital_cd_2,
  machine_tbl.*,
  room_bed_group_tbl.room_bed_group_name_list,

  dialyzer_tbl.model_number as dialyzer_name,
  dialyzer_tbl.in_hospital_cd_1 as dialyzer_in_hospital_cd_1,
  dialyzer_tbl.in_hospital_cd_2 as dialyzer_in_hospital_cd_2,
  dialyzer_tbl.in_hospital_cd_3 as dialyzer_in_hospital_cd_3,
  dialyzer_tbl.in_hospital_cd_4 as dialyzer_in_hospital_cd_4,
  dialyzer_tbl.*,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,

  primary_film_tbl.in_hospital_cd_1 as primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_sn_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_4,


  case
    when ord.ind_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,

  case
    when ord.ind_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,

  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,

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

  case
    when ord.ind_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.ind_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit,
  nt.treat_date as next_treat_date
  ,ord.ord_no
from
  ord_main as ord

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
  -- left join equipment_tbl as puncture_needle_a_tbl on ord.ind_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text
  -- left join equipment_tbl as puncture_needle_v_tbl on ord.ind_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text
  -- left join equipment_tbl as puncture_needle_sn_tbl on ord.ind_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text
  -- left join equipment_tbl as blood_circuit_tbl on ord.ind_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text

  left join medicine_tbl as med_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text
  left join medicine_tbl as med_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text
  left join medicine_tbl as med_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text

  left join medicine_mix_tbl as mix_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text
  left join next_date as nt on nt.pat_id = ord.pat_id
	left join g
	on ord.ord_no=g.ordnob
where

	ord.ord_no = @ordNo
  ', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:00", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "next_treat_date", "data_name": "次回透析予定日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "next_treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕内シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "strnig", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00000000000000000002", "can_calc": "0", "data_code": "treatment_cd", "data_name": "治療方法コード", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_cd", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00000000000000000003", "can_calc": "0", "data_code": "treatment_name1", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD＋補液", "item": "HD＋補液"}, {"code": "5", "disp": "ECUM＋補液", "item": "ECUM＋補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "0", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "0", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "0", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "0", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "strnig", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "ip_speed_max", "data_name": "HD+IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "1", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A針", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_sn_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スリッパ", "can_calc": "0", "data_code": "tare_name1", "data_name": "風袋名称１", "data_type": "strnig", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "tare_weight1", "data_name": "風袋重量１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "tare_name2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "tare_weight2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "1", "data_code": "tare_name3", "data_name": "風袋名称３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "tare_weight3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "tare_name4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "tare_name5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "tare_weight_total", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name1", "data_name": "除水補正名称１", "data_type": "strnig", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_weight1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "off_water_weight2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "off_water_weight5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "off_water_weight_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_upper", "data_name": "前体重許容割合（上限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_upper", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_lower", "data_name": "前体重許容割合（下限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_lower", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "room_bed_group_name_list", "data_name": "透析室・ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_bed_group_name_list", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "GDF-21M", "can_calc": "0", "data_code": "model_number", "data_name": "ダイアライザ名", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "model_number", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "0", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a1", "data_name": "治療方法連携コードa1", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a2", "data_name": "治療方法連携コードa2", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a3", "data_name": "治療方法連携コードa3", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a4", "data_name": "治療方法連携コードa4", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b1", "data_name": "治療方法連携コードb1", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b2", "data_name": "治療方法連携コードb2", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b3", "data_name": "治療方法連携コードb3", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b4", "data_name": "治療方法連携コードb4", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_1", "data_name": "ベッド携コード1", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_2", "data_name": "ベッド携コード2", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件/ベッド情報/ダイアライザ情報　@ordNo使用', '2020-03-26 17:10:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (52, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
    --and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', ( @fromDate )::timestamp) and date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
    --and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', ( @fromDate )::timestamp) and date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
    --and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', ( @fromDate )::timestamp) and  date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''0''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,event_start_date
  ,event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name
  ,picked_result_params[1]->>''result_value'' as data1
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
  ,picked_result_params[11]->>''result_value'' as data11
  ,picked_result_params[12]->>''result_value'' as data12
  ,picked_result_params[13]->>''result_value'' as data13
  ,picked_result_params[14]->>''result_value'' as data14
  ,picked_result_params[15]->>''result_value'' as data15
  ,picked_result_params[16]->>''result_value'' as data16
  ,picked_result_params[17]->>''result_value'' as data17
  ,picked_result_params[18]->>''result_value'' as data18
  ,picked_result_params[19]->>''result_value'' as data19
  ,picked_result_params[20]->>''result_value'' as data20
  ,picked_result_params[21]->>''result_value'' as data21
  ,picked_result_params[22]->>''result_value'' as data22
  ,picked_result_params[23]->>''result_value'' as data23
  ,picked_result_params[24]->>''result_value'' as data24
  ,picked_result_params[25]->>''result_value'' as data25
  ,picked_result_params[26]->>''result_value'' as data26
  ,picked_result_params[27]->>''result_value'' as data27
  ,picked_result_params[28]->>''result_value'' as data28
  ,picked_result_params[29]->>''result_value'' as data29
  ,picked_result_params[30]->>''result_value'' as data30
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "テキスト", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "テキスト", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "テキスト", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "テキスト", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data11_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data12_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data13_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data14_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data15_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data16_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data17_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data18_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data19_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data20_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data21_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data22_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data23_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data24_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data25_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data26_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data27_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data28_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data29_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data30_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data11", "data_name": "データ11", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data11", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data12", "data_name": "データ12", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data12", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data13", "data_name": "データ13", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data13", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data14", "data_name": "データ14", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data14", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data15", "data_name": "データ15", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data15", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data16", "data_name": "データ16", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data16", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data17", "data_name": "データ17", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data17", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data18", "data_name": "データ18", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data18", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data19", "data_name": "データ19", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data19", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data20", "data_name": "データ20", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data20", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data21", "data_name": "データ21", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data21", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data22", "data_name": "データ22", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data22", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data23", "data_name": "データ23", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data23", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data24", "data_name": "データ24", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data24", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data25", "data_name": "データ25", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data25", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data26", "data_name": "データ26", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data26", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data27", "data_name": "データ27", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data27", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data28", "data_name": "データ28", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data28", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data29", "data_name": "データ29", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data29", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data30", "data_name": "データ30", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data30", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート テキスト @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (68, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''5''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name

  ,to_date(picked_result_params[1]->>''result_value'', ''YYYYMMDD'') as data1
  ,to_date(picked_result_params[2]->>''result_value'', ''YYYYMMDD'') as data2
  ,to_date(picked_result_params[3]->>''result_value'', ''YYYYMMDD'') as data3
  ,to_date(picked_result_params[4]->>''result_value'', ''YYYYMMDD'') as data4
  ,to_date(picked_result_params[5]->>''result_value'', ''YYYYMMDD'') as data5
  ,to_date(picked_result_params[6]->>''result_value'', ''YYYYMMDD'') as data6
  ,to_date(picked_result_params[7]->>''result_value'', ''YYYYMMDD'') as data7
  ,to_date(picked_result_params[8]->>''result_value'', ''YYYYMMDD'') as data8
  ,to_date(picked_result_params[9]->>''result_value'', ''YYYYMMDD'') as data9
  ,to_date(picked_result_params[10]->>''result_value'', ''YYYYMMDD'') as data10

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data1", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data2", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data3", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data4", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data5", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data6", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data7", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data8", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data9", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data10", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 日付 @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (69, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''5''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name

  ,to_date(picked_result_params[1]->>''result_value'', ''YYYYMMDD'') as data1
  ,to_date(picked_result_params[2]->>''result_value'', ''YYYYMMDD'') as data2
  ,to_date(picked_result_params[3]->>''result_value'', ''YYYYMMDD'') as data3
  ,to_date(picked_result_params[4]->>''result_value'', ''YYYYMMDD'') as data4
  ,to_date(picked_result_params[5]->>''result_value'', ''YYYYMMDD'') as data5
  ,to_date(picked_result_params[6]->>''result_value'', ''YYYYMMDD'') as data6
  ,to_date(picked_result_params[7]->>''result_value'', ''YYYYMMDD'') as data7
  ,to_date(picked_result_params[8]->>''result_value'', ''YYYYMMDD'') as data8
  ,to_date(picked_result_params[9]->>''result_value'', ''YYYYMMDD'') as data9
  ,to_date(picked_result_params[10]->>''result_value'', ''YYYYMMDD'') as data10

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data1", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data2", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data3", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data4", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data5", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data6", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data7", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data8", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data9", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data10", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  日付 @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (82, 'WITH DATA AS (
	with ord_key_tbl as (
  select
    ord_no,
    treat_date
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
), ord_hist_tbl as (
  select
    ord_no,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    rst_dw,
    rst_cond_info->''3''->>''value'' as target_weight
  from
    ord_main
  where
  pat_id = @patId
  and  ord_no <> (select ord_no from ord_key_tbl)
  and
    treat_date <= (select treat_date from ord_key_tbl)
  and
     rst_dialysis_state = ''0''
  and is_del = ''0''
  order by
    treat_date desc
  limit 2
), ord_array_tbl as (
  select
    array_agg(ord_no) as array_ord_no,
    array_agg(treat_date) as array_treat_date,
    array_agg(rst_dw) as array_dw,
    array_agg(target_weight) as array_target_weight
  from
    ord_hist_tbl
)
select
	ord_no as ord_no_t,
  array_ord_no[1] as ord_no1,
  array_ord_no[2] as ord_no2,
  array_treat_date[1] as treat_date1,
  array_treat_date[2] as treat_date2,
  array_dw[1] as dw1,
  array_dw[2] as dw2,
  array_target_weight[1] as target_weight1,
  array_target_weight[2] as target_weight2
from
  ord_array_tbl,ord_key_tbl
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

	', 2, '[{"preview": "55.00", "can_calc": "0", "data_code": "dw1", "data_name": "DW（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight1", "data_name": "目標体重（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date1", "data_name": "透析予定日(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date1", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw2", "data_name": "DW（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight2", "data_name": "目標体重（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date2", "data_name": "透析予定日(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date2", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：体重情報(過去指示)　@ordNo使用', '2020-03-27 15:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (95, 'WITH DATA AS (


	with ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where ord_no = @ordNo
  and is_del = ''0''
), bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
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
      (select * from pat_unique where is_del = ''0'') as pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
), pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
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
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
    ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
),equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
-- 指定患者、基準日以前のDWがある身体情報を取得
),oms_puncture_needle_a_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''06''
		AND ind_rst_class=''2''

),oms_puncture_needle_v_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''07''
		AND ind_rst_class=''2''

),oms_puncture_needle_sn_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''05''
		AND ind_rst_class=''2''

),oms_blood_circuit_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''2''

)
select
	ord.ord_no as ord_no_t,
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.rst_kur_cd as kur_cd,

  ord.rst_treatment_cd as treatment_cd,
  to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,

  to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,

  ord.rst_bed_cd as bed_cd,

  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  --ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''12''->>''value'' as single_needle,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''29''->>''value'' as ip,
  ord.rst_cond_info->''30''->>''value'' as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
  ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  CAST(ord.rst_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.rst_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.rst_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.rst_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,


  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,
  mst_va.va_direct as va_direct,


  (select nlist.name
   from (
     select nl.comb->>''value'' as nid, nl.comb->>''text'' as name
     from (
       select jsonb_array_elements(combo_data->''combos''->0->''values'') as comb from sys_master_define where master_physical_name = ''mst_treatment''
     ) as nl
   ) as nlist
   where nlist.nid = mst_treatment.device_mode::text
  ) as device_mode,
  mst_bed.shunt_position,
  mst_bed.is_infection,
  mst_bed.emergency_class,
  mst_machine.machine_name,

  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.maker,
  mst_dialyzer.function_class,
  mst_dialyzer.area,
  mst_dialyzer.ufr,
  mst_dialyzer.koa,
  mst_dialyzer.material,
  mst_dialyzer.wetdry,
  mst_dialyzer.sterilization,
  mst_dialyzer.bloodamt,
  mst_dialyzer.alqd_flood_vol,
  mst_dialyzer.urea_clearance,
  mst_dialyzer.gas_purge_time,
  mst_dialyzer.substituent_wash_amt,
  mst_dialyzer.membrane_wash,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,


  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,

   case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,

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

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit

  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_1'', ''''), '' '') as rst_charge_user_name1
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_2'', ''''), '' '') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_1'', ''''), '' '') as rst_puncture_user_name1
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_2'', ''''), '' '') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,trim(coalesce(rst_return_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_1'', ''''), '' '') as rst_return_user_name1
  ,trim(coalesce(rst_return_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_2'', ''''), '' '') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,pull_leave_amount
  ,ord.rst_dw
  ,ord.rst_treatment_name
  ,ord_no
  ,ord.pat_id as pat_id
  ,ord.pat_id AS pat_name
from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1''  -- 実績

  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1''
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1''
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1''

  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1''AND mst_dialyzer.dialyzer_cd IN (@diaIds)

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1'' AND adsorption_column_tbl.class_cd IN (@eqIds)
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' AND primary_film_tbl.class_cd IN (@eqIds)
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' AND secondary_film_tbl.class_cd IN (@eqIds)

	left join oms_puncture_needle_a_tbl as opnat  on opnat.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_v_tbl as opnvt on opnvt.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_sn_tbl as opnsnt on opnsnt.supplies_base_no=ord.ord_no
	left join oms_blood_circuit_tbl as obct on obct.supplies_base_no=ord.ord_no

	left join equipment_tbl as puncture_needle_a_tbl on opnat.supplies_cd= puncture_needle_a_tbl.equipment_cd::text  and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' AND puncture_needle_a_tbl.class_cd IN (@eqIds)
	left join equipment_tbl as puncture_needle_v_tbl on opnvt.supplies_cd = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' AND puncture_needle_v_tbl.class_cd IN (@eqIds)
	left join equipment_tbl as puncture_needle_sn_tbl on opnsnt.supplies_cd = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' AND puncture_needle_sn_tbl.class_cd IN (@eqIds)
  left join equipment_tbl as blood_circuit_tbl on obct.supplies_cd= blood_circuit_tbl.equipment_cd::text  and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' AND blood_circuit_tbl.class_cd IN (@eqIds)


  -- left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1''
  --left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1''
  -- left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1''
  -- left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1''

  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1'' AND med_dialysate_tbl.class_cd IN (@medIds)
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1'' and med_fluid_replacement_tbl.class_cd in  (@medIds)
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''and med_anti_coagulant_tbl.class_cd in  (@medIds)

  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1'' and mix_dialysate_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1'' and mix_fluid_replacement_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1'' and mix_anti_coagulant_tbl.class_cd in (@medIds)
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''    )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   )
where
  ord.ord_no = @ordNo
 and ord.rst_dialysis_state > ''0''
 and ord.is_del = ''0''


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

	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "decimal", "conv_table": [], "data_class": "", "field_name": "treatment_time", "disp_format": "0", "data_category": "", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者ID（集計項目用）", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "pat_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名（集計項目用）", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "pat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "pull_leave_amount", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "pull_leave_amount", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo 使用', '2021-08-16 10:09:39', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (103, 'SELECT
	occur_date,
	CAST ( monitor_data ->> ''90'' AS DECIMAL) AS bp_high,
	CAST ( monitor_data ->> ''91'' AS DECIMAL) AS bp_low,
	CAST ( monitor_data ->> ''92'' AS DECIMAL) AS bp_ave,
	CAST ( monitor_data ->> ''93'' AS DECIMAL) AS pulse,
	CAST ( monitor_data ->> ''94'' AS DECIMAL) AS body_temperature,
	CAST ( monitor_data ->> ''-1'' AS DECIMAL) AS blood_glucose_level
FROM
	mni_monitor
WHERE
	ord_no = @ordNo
	AND data_type IN ( 0, 2, 4, 5, 6)
	AND is_del = ''0''
ORDER BY
	occur_date;', 2, '[{"preview": "130", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "0", "data_code": "occur_date", "data_name": "測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "バイタル情報", "field_name": "occur_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "body_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "110.0", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "blood_glucose_level", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：バイタル情報 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (105, 'WITH DATA AS (


	with tmp as
(
  select
  CAST(rst_weight_info->>''water_removal_target'' AS DECIMAL) as water_removal_target
  ,CAST(rst_weight_info->>''water_removal_rst'' AS DECIMAL) as water_removal_rst
  ,CAST(rst_weight_info->>''add_water_total'' AS DECIMAL) as add_water_total

  ,rst_tare_info->''before''->>''name_1'' as before_tare_name_1
  ,rst_tare_info->''before''->>''name_2'' as before_tare_name_2
  ,rst_tare_info->''before''->>''name_3'' as before_tare_name_3
  ,rst_tare_info->''before''->>''name_4'' as before_tare_name_4
  ,rst_tare_info->''before''->>''name_5'' as before_tare_name_5
  ,to_number(rst_tare_info->''before''->>''weight_1'' AS DECIMAL) as before_tare_weight_1
  ,to_number(rst_tare_info->''before''->>''weight_2'' AS DECIMAL) as before_tare_weight_2
  ,to_number(rst_tare_info->''before''->>''weight_3'' AS DECIMAL) as before_tare_weight_3
  ,to_number(rst_tare_info->''before''->>''weight_4'' AS DECIMAL) as before_tare_weight_4
  ,to_number(rst_tare_info->''before''->>''weight_5'' AS DECIMAL) as before_tare_weight_5
  ,rst_tare_info->''before''->>''wheel_chair_name'' as before_wheel_chair_name
  ,to_number(rst_tare_info->''before''->>''wheel_chair_weight'' AS DECIMAL) as before_wheel_chair_weight

  ,rst_tare_info->''after''->>''name_1'' as after_tare_name_1
  ,rst_tare_info->''after''->>''name_2'' as after_tare_name_2
  ,rst_tare_info->''after''->>''name_3'' as after_tare_name_3
  ,rst_tare_info->''after''->>''name_4'' as after_tare_name_4
  ,rst_tare_info->''after''->>''name_5'' as after_tare_name_5
  ,CAST(rst_tare_info->''after''->>''weight_1'' AS DECIMAL) as after_tare_weight_1
  ,CAST(rst_tare_info->''after''->>''weight_2'' AS DECIMAL) as after_tare_weight_2
  ,CAST(rst_tare_info->''after''->>''weight_3'' AS DECIMAL) as after_tare_weight_3
  ,CAST(rst_tare_info->''after''->>''weight_4'' AS DECIMAL) as after_tare_weight_4
  ,CAST(rst_tare_info->''after''->>''weight_5'' AS DECIMAL) as after_tare_weight_5
  ,rst_tare_info->''after''->>''wheel_chair_name'' as after_wheel_chair_name
  ,CAST(rst_tare_info->''after''->>''wheel_chair_weight'' AS DECIMAL) as after_wheel_chair_weight

  ,rst_off_water_info->>''name_1'' as off_water_name_1
  ,rst_off_water_info->>''name_2'' as off_water_name_2
  ,rst_off_water_info->>''name_3'' as off_water_name_3
  ,rst_off_water_info->>''name_4'' as off_water_name_4
  ,rst_off_water_info->>''name_5'' as off_water_name_5
  ,CAST(rst_off_water_info->>''weight_1'' AS DECIMAL) as off_water_weight_1
  ,CAST(rst_off_water_info->>''weight_2'' AS DECIMAL) as off_water_weight_2
  ,CAST(rst_off_water_info->>''weight_3'' AS DECIMAL) as off_water_weight_3
  ,CAST(rst_off_water_info->>''weight_4'' AS DECIMAL) as off_water_weight_4
  ,CAST(rst_off_water_info->>''weight_5'' AS DECIMAL) as off_water_weight_5
	,ord_no
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
)

select
  *,
	ord_no as ord_no_t
  ,coalesce(before_tare_weight_1, 0) + coalesce(before_tare_weight_2, 0)
    + coalesce(before_tare_weight_3, 0) + coalesce(before_tare_weight_4, 0)
    + coalesce(before_tare_weight_5, 0) + coalesce(before_wheel_chair_weight, 0) as before_tare_total
  ,coalesce(after_tare_weight_1, 0) + coalesce(after_tare_weight_2, 0)
    + coalesce(after_tare_weight_3, 0) + coalesce(after_tare_weight_4, 0)
    + coalesce(after_tare_weight_5, 0) + coalesce(after_wheel_chair_weight, 0) as after_tare_total
  ,coalesce(off_water_weight_1, 0) + coalesce(off_water_weight_2, 0)
    + coalesce(off_water_weight_3, 0) + coalesce(off_water_weight_4, 0) + coalesce(off_water_weight_5, 0) as off_water_total
from
  tmp



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
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：除水情報/風袋・除水補正 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (111, 'with machine_tbl as (
select
mm.*,
mmt.machine_type
from
mst_machine as mm
left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
where
machine_no = @machineNo

and
is_disp =''1''
and
is_del = ''0''

-- 予定
), mainte_layout_group_tbl as (
select
*
from
mst_mainte_layout_group
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_tbl as (
select
*
from
mst_mainte_layout
where
facility_cd = (select facility_cd from machine_tbl)
and
layout_class = ''2''
and
( SELECT machine_type_cd FROM machine_tbl ) :: TEXT IN ( SELECT json_array_elements_text ( ( SELECT to_json ( type_info ) ) ) :: TEXT )
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_work1 as (
select
''1''::text as tabIndex,
mainte_category_idx,
mainte_category_cd,
mainte_layout_cd,
edition_no
from
mainte_layout_tbl
cross join lateral jsonb_array_elements_text(detail_info_1)
with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_layout_work2 as (
select
''2''::text as tabIndex,
mainte_category_idx,
mainte_category_cd,
mainte_layout_cd,
edition_no
from
mainte_layout_tbl
cross join lateral jsonb_array_elements_text(detail_info_2)
with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_layout_work as (
select
*
from
mainte_layout_work1
union all
select
*
from
mainte_layout_work2

), mainte_category_tbl as (
select
*
from
mst_mainte_category
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_category_work as (
select
mainte_detail_idx,
mainte_detail_cd,
mainte_category_tbl.mainte_category_cd,
mainte_category_tbl.edition_no,
mainte_category_tbl.category_name
from
mainte_category_tbl
cross join lateral jsonb_array_elements_text(detail)
with ordinality as tmp(mainte_detail_cd, mainte_detail_idx)

),mainte_detail_tbl as (
select
mmd.*,

mlw.tabIndex,

mct.edition_no as mainte_category_edition,
mct.category_name,

mlw.mainte_category_idx,
mct.mainte_detail_idx,
mlw.mainte_layout_cd,
mlw.edition_no as mainte_layout_edition
from
mst_mainte_detail as mmd
inner join mainte_category_work as mct on (mct.mainte_detail_cd::json->>''code'')::text = mmd.mainte_detail_cd::text
and (mct.mainte_detail_cd::json->>''isDisp'')::text = ''1''
inner join mainte_layout_work as mlw
on (mlw.mainte_category_cd::json->>''cd'')::text = mct.mainte_category_cd::text
and (mlw.mainte_category_cd::json->>''isDisp'')::text = ''true''
where
mmd.facility_cd = (select facility_cd from machine_tbl)
and
mmd.is_disp = ''1''
and
mmd.is_del = ''0''

), mainte_work as (
select
*

from
mnt_mainte_main
where
machine_no = @machineNo

and
mainte_date between date_trunc(''day'', @fromDate
::timestamp ) and date_trunc(''day'', @toDate
::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
is_disp = ''1''
and
is_del = ''0''

), mainte_tbl as (
select
mw.mainte_no,
mw.facility_cd,
''2''::text as mainte_class,
mw.rec_no,
mw.mainte_date,
mg.group_name,
mw.mainte_layout_group_cd,
mw.mainte_layout_group_edition,
mw.mainte_layout_cd,
mw.mainte_layout_edition,
mw.checker_id_1,
mw.checker_id_2,
mw.mainte_ans_1,
mw.mainte_ans_2,
mw.up_date,
mt.com_format_cd,
mt.machine_serial,
mt.machine_type,
mt.machine_name,
mlgt.group_name,

mlt.layout_name,
mdt.mainte_detail_cd::bigint as mainte_detail_cd,
mdt.edition_no::integer as mainte_detail_edition,
null::text as judge,
null::text as comment,
null::text as user_id,
null::text as date,
mdt.tabIndex,
mdt.mainte_category_cd,
mdt.mainte_content_1,
mdt.mainte_content_2,
mdt.mainte_content_3,
mdt.mainte_category_edition::text as mainte_category_edition,
mdt.category_name,
mdt.mainte_detail_idx

from
mainte_work as mw
left join mst_mainte_layout_group as mg
     on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
     and mg.facility_cd = mw.facility_cd
, machine_tbl as mt
, mainte_layout_group_tbl as mlgt
, mainte_layout_tbl as mlt
, mainte_detail_tbl as mdt

where
mlt.edition_no = mdt.mainte_layout_edition and
mlt.mainte_layout_cd = mdt.mainte_layout_cd
-- 実績
), mainte_layout_group_hst as (
select
*
from
mst_mainte_layout_group_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_hst as (
select
*
from
mst_mainte_layout_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_category_hst as (
select
*
from
mst_mainte_category_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_detail_hst as (
select
*
from
mst_mainte_detail_hst as mmdh
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst_work as (
select
*
from
mnt_mainte_main
where

facility_cd = (select facility_cd from machine_tbl)
and
machine_no = @machineNo

and
mainte_date between date_trunc(''day'', @fromDate
::timestamp ) and date_trunc(''day'', @toDate
::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
is_disp = ''1''
and
is_del = ''0''

), mainte_main_detail_hst_1 as (
select
mainte_no,
details
from
mainte_hst_work as mhw
cross join lateral jsonb_array_elements(detail)
with ordinality as tmp(details, json_idx)

), mainte_main_detail_hst as (
select
mainte_no,
json_idx as mainte_detail_idx,
info->>''detail_cd'' as detail_cd,
info->>''edition'' as edition,
info->>''judge'' as judge,
info->>''comment'' as comment,
info->>''user_id'' as user_id,
info->>''date'' as date,
info->>''cate_cd'' as cate_cd,
info->>''cate_edi'' as cate_edi,
info->>''tableIndex'' as tabIndex
from
mainte_main_detail_hst_1 as mhw
cross join lateral jsonb_array_elements(mhw.details)
with ordinality as tmp(info, json_idx)

)
, mainte_hst as
(
select
mhw.mainte_no,
mhw.facility_cd,
mhw.mainte_class::text as mainte_class,
mhw.rec_no,
mhw.mainte_date,
mg.group_name,
mhw.mainte_layout_group_cd,
mhw.mainte_layout_group_edition,
mhw.mainte_layout_cd,
mhw.mainte_layout_edition,
mhw.checker_id_1,
mhw.checker_id_2,
mhw.mainte_ans_1,
mhw.mainte_ans_2,
mhw.up_date,
mt.com_format_cd,
mt.machine_serial,
mt.machine_type,
mt.machine_name,
mlgh.group_name,

mlh.layout_name,

mmdh.detail_cd::bigint as mainte_detail_cd,
mmdh.edition::integer as mainte_detail_edition,
mmdh.judge::text as judge,
mmdh.comment::text as mainte_comment_1,
mmdh.user_id::text as user_id,
mmdh.date::text as date,
mmdh.tabIndex,
mdh.mainte_category_cd,
mdh.mainte_content_1 as ment_content_1,
mdh.mainte_content_2,
mdh.mainte_content_3,
mmdh.cate_edi as mainte_category_edition,
mch.category_name,
mmdh.mainte_detail_idx


from
mainte_hst_work mhw
inner join machine_tbl as mt
on mhw.machine_no = mt.machine_no
inner join mainte_layout_group_hst as mlgh
on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
inner join mainte_layout_hst as mlh
on mhw.mainte_layout_cd = mlh.mainte_layout_cd and mhw.mainte_layout_edition = mlh.edition_no
inner join mainte_main_detail_hst as mmdh
on mhw.mainte_no = mmdh.mainte_no
inner join mainte_detail_hst as mdh
on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text

inner join mainte_category_hst as mch
on mmdh.cate_cd = mch.mainte_category_cd::text and mmdh.cate_edi = mch.edition_no::text
left join mst_mainte_layout_group as mg
     on mg.mainte_layout_group_cd = mhw.mainte_layout_group_cd
     and mg.facility_cd = mhw.facility_cd
)

select
*
from
mainte_hst
union all
select
*
from
mainte_tbl

where
mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)

order by
mainte_date, layout_name,tabindex ,mainte_detail_idx', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検詳細記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_2", "data_name": "定期交換部品記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "確認", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "レ", "item": "レ"}, {"code": "2", "disp": "〇", "item": "〇"}, {"code": "3", "disp": "?", "item": "?"}, {"code": "4", "disp": "A", "item": "A"}, {"code": "5", "disp": "T", "item": "T"}, {"code": "6", "disp": "C", "item": "C"}], "data_class": "定期点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "ment_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "ment_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準/交換部品", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準/交換部品", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "交換推奨時間", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：定期点検詳細　@machineNo @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (116, 'WITH DATA AS (
with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state <>''0''
)
, oxygen_tbl as
(
  select
    *
    ,(rti->>''occur_date'')::timestamp as occur_date
    ,date_trunc(''minute'', (rti->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp1
  where
    rti->>''treat_class'' = ''3''
)

select
	@ordNo as ord_no_t,
  sum(CAST(rti->>''oxygen_amount'' AS DECIMAL)) as total_amount
from
  oxygen_tbl
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
	', 2, '[{"preview": "16", "can_calc": "1", "data_code": "total_amount", "data_name": "吸入総量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入総量", "field_name": "total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：酸素吸入総量 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (117, 'WITH DATA AS (




with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
    ,to_date(treat_date, ''yyyymmdd'') as treat_date
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state <>''0''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
   ,treat_date
  from
    addition_info_expand
)

select
  ord_no as ord_no_t
	,ord_no
  ,treat_date
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,case
	  when addition_class =''1'' then ''施設''
		when addition_class =''2'' then ''患者（困）''
		when addition_class =''3'' then ''患者（病）''
		when addition_class =''4'' then ''ろ過''
		when addition_class =''5'' then ''長時間''
		when addition_class =''6'' then ''薬剤''
		when addition_class =''7'' then ''処置（イベント）''
		when addition_class =''8'' then ''処置（検査）''
		when addition_class =''9'' then ''導入期''
		when addition_class =''10'' then ''休日''
		when addition_class =''11'' then ''時間外''
		when addition_class =''12'' then ''汎用''
	 else  ''''
	end as addition_class,
	mst_addition.addition_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx




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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "加算", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "addition_name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "addition_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：加算 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (133, 'WITH b AS (
select ord_main.* from ord_main
     where facility_cd = @facilityCd
 and rst_dialysis_state between ''1'' and ''5''
     and
       pat_id is not null
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate
 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate
 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
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
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 予測時間_除水
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 予測時間_透析
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
    where d.data_type = 1
), f AS (
    select e.*
--     to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
--     , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
--     , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
--     inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
), BpBefore AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 5
), BpCurrent AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 2
), BpAfter AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 6
),j as(select pat_obs_rec.pat_id,count(*) as 観察記録件数 from  pat_obs_rec INNER  JOIN b on (pat_obs_rec.pat_id = b.pat_id) GROUP BY pat_obs_rec.pat_id)
,k as(select mnt_machine_state.ord_no,machine_status as 警報・報知 from  mnt_machine_state  INNER  JOIN b on mnt_machine_state.ord_no = b.ord_no)
,l as (select pat_ind_approve.ord_no,pat_ind_approve.is_content_changed_for_map as 指示変更 from  pat_ind_approve  INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as 投与状況
from
(
select b.ord_no,
count(1) as effect
from b,jsonb_array_elements(b.rst_medi_info) as a1
where a1->''effect_flg''=''"1"''
GROUP BY b.ord_no
) as b2,
(
select b.ord_no,
count(1) as effect_count
from b,jsonb_array_elements(b.rst_medi_info) as a1
  GROUP BY b.ord_no
) as a2 where a2.ord_no=b2.ord_no
)
,n as  (
 select b.ord_no,
case when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''1'' then
((rst_weight_info->''recrcl_rt'') -> ''1'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''2'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''3'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''4'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''5'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
else ''0'' end  as rate
 from b
 )
 ,o as (
 select b.ord_no,
max(info ->> ''treat_cd'')|| ''　'' || max(info ->> ''treat_name'')  AS treatment
 from b
   CROSS JOIN LATERAL json_array_elements(b.rst_treatment_info ::json) info
 GROUP BY b.ord_no
 )
select b.ord_no, b.treat_date
, b.pat_id AS pat_id
, b.pat_id AS pat_name
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw as DW
, CASE mnt_machine_state.process_state WHEN ''01'' THEN ''プリセット''
                                       WHEN ''02'' THEN ''洗浄''
                                       WHEN ''03'' THEN ''酸洗''
                                       WHEN ''04'' THEN ''消毒''
                                       WHEN ''05'' THEN ''滞留''
                                       WHEN ''06'' THEN ''液置換''
                                       WHEN ''07'' THEN ''準備回収''
                                       WHEN ''08'' THEN ''ガスパージ''
                                       WHEN ''09'' THEN ''排液''
                                       WHEN ''10'' THEN ''停止''
                                       WHEN ''11'' THEN ''運転''
                                       WHEN ''99'' THEN ''通信異常、電源OFF、異常''
                                       ELSE mnt_machine_state.process_state
  END
, b.rst_cond_info::json#>>''{3, value}'' AS 目標体重
, CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.ind_cond_info::json#>>''{3, value}'' AS DECIMAL) AS 目標体重から
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS 終了予測_除水完了
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS 終了予測_透析完了
, b.rst_end_date
, b.ind_cond_info#>''{1, value}'' AS 治療時間
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN f.予測時間_除水
       ELSE f.予測時間_透析
  END - to_number(b.ind_cond_info#>>''{1, value}'', ''9999'') AS 遅れ時間
, CASE WHEN (f.予測時間_除水 > COALESCE(null,f.予測時間_透析,0)) and (f.予測時間_除水 >0) THEN round((f.経過時間 / f.予測時間_除水)*100,0)
       WHEN f.予測時間_透析 >0 THEN round((f.経過時間 / f.予測時間_透析)*100,0)
       ELSE null
  END AS 進捗率
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->''90'' AS 前血圧_最高
, BpBefore.monitor_data->''91'' AS 前血圧_最低
, BpBefore.monitor_data->''92'' AS 前血圧_平均
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS 前血圧
, BpBefore.monitor_data->''93'' AS 前脈拍
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS 現在血圧
, b.rst_charge_user_info->>''user_id_1'' AS charge_user_id_1
, b.rst_charge_user_info->>''date_1'' AS charge_date_1
, b.rst_charge_user_info->>''user_id_2'' AS charge_user_id_2
, b.rst_charge_user_info->>''date_2'' AS charge_date_2
, b.rst_puncture_user_info->>''date'' AS puncture_date
, b.rst_puncture_user_info->>''user_id_1'' AS puncture_user_id_1
, b.rst_puncture_user_info->>''date_1'' AS puncture_date_1
, b.rst_puncture_user_info->>''user_id_2'' AS puncture_user_id_2
, b.rst_puncture_user_info->>''date_2'' AS puncture_date_2
, b.rst_return_user_info->>''date'' AS return_date
, b.rst_return_user_info->>''user_id_1'' AS return_user_id_1
, b.rst_return_user_info->>''date_1'' AS return_date_1
, b.rst_return_user_info->>''user_id_2'' AS return_user_id_2
, b.rst_return_user_info->>''date_2'' AS return_date_2
, b.rst_weight_info->>''weight_after'' AS weight_after
, to_number(b.rst_weight_info::json->>''weight_before'', ''999.99'') - to_number(b.rst_weight_info::json->>''weight_after'', ''999.99'') AS weight_diff
, BpAfter.monitor_data->''90'' AS 後血圧_最高
, BpAfter.monitor_data->''91'' AS 後血圧_最低
, BpAfter.monitor_data->''92'' AS 後血圧_平均
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS 後血圧
, BpAfter.monitor_data->''93'' AS 後脈拍
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS 患者確認
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.ind_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS 終了予定
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS 回診状態
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS 回診データ
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS 除水量制限
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS ダイアライザ
, b.rst_cond_info#>>''{6, value_name_1}'' AS 吸着カラム
, b.rst_cond_info#>>''{7, value_name_1}'' AS 一次膜
, b.rst_cond_info#>>''{8, value_name_1}'' AS 二次膜
, b.rst_cond_info#>>''{9, value_name_1}'' AS 穿刺針_a針
, b.rst_cond_info#>>''{10, value_name_1}'' AS 穿刺針_v針
, b.rst_cond_info#>>''{11, value_name_1}'' AS 穿刺針_sn
, CASE WHEN b.rst_cond_info#>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS シングルニードル使用
, b.rst_cond_info#>>''{13, value_name_1}'' AS 血液回路
, b.rst_cond_info#>''{14, value}'' AS 血流量
, b.rst_cond_info#>>''{15, value_name_1}'' AS 透析液
, b.rst_cond_info#>''{16, value}'' AS 透析液流量
, b.rst_cond_info#>''{17, value}'' AS 透析液量
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS 透析液温度
, b.rst_cond_info#>>''{19, value_name_1}'' AS 補液
, b.rst_cond_info#>''{20, value}'' AS 補液量
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS 補液選択
, b.rst_cond_info#>''{22, value}'' AS 補液使用数
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS 補液温度
, b.rst_cond_info#>''{24, value}'' AS 補液速度
, b.rst_cond_info#>>''{25, value_name_1}'' AS 抗凝固剤
, b.rst_cond_info#>''{26, value}'' AS 抗凝固剤ワンショット量
, b.rst_cond_info#>''{27, value}'' AS 抗凝固剤持続速度
, b.rst_cond_info#>''{28, value}'' AS 抗凝固剤持続総量
-- , CASE WHEN b.rst_cond_info#>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip使用選択
, b.rst_cond_info#>''{29, value}'' AS ip使用選択
-- , null AS ipスタート
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ipスタート
, b.rst_cond_info#>''{30, value}'' AS ipスタート
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ipワンショット量
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip速度
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip速度最大値
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ipワンショット量
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip速度
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip速度最大値
-- , CASE WHEN b.rst_cond_info#>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS 自動ワンショット
, b.rst_cond_info#>''{34, value}'' AS 自動ワンショット
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip電源自動切り
, b.rst_cond_info#>''{35, value}'' AS ip電源自動切り
, b.rst_cond_info#>''{36, value}'' AS ip電源自動切り時間
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip電源okモニタ切り
, b.rst_cond_info#>''{37, value}'' AS ip電源okモニタ切り
, b.rst_cond_info#>''{38, value}'' AS ip電源okモニタ切り時間
, f.monitor_data->''0'' AS m000
, f.monitor_data->''1'' AS m001
, f.monitor_data->''2'' AS m002
, f.monitor_data->''3'' AS m003
, f.monitor_data->''4'' AS m004
, f.monitor_data->''5'' AS m005
, f.monitor_data->''6'' AS m006
, f.monitor_data->''7'' AS m007
, f.monitor_data->''8'' AS m008
, f.monitor_data->''9'' AS m009
, f.monitor_data->''10'' AS m010
, f.monitor_data->''11'' AS m011
, f.monitor_data->''12'' AS m012
, f.monitor_data->''13'' AS m013
, f.monitor_data->''14'' AS m014
, f.monitor_data->''15'' AS m015
, f.monitor_data->''16'' AS m016
, f.monitor_data->''17'' AS m017
, f.monitor_data->''18'' AS m018
, f.monitor_data->''19'' AS m019
, f.monitor_data->''20'' AS m020
, f.monitor_data->''21'' AS m021
, f.monitor_data->''22'' AS m022
, f.monitor_data->''23'' AS m023
, f.monitor_data->''24'' AS m024
, f.monitor_data->''25'' AS m025
, f.monitor_data->''26'' AS m026
, f.monitor_data->''27'' AS m027
, f.monitor_data->''28'' AS m028
, f.monitor_data->''29'' AS m029
, f.monitor_data->''30'' AS m030
, f.monitor_data->''31'' AS m031
, f.monitor_data->''32'' AS m032
, f.monitor_data->''33'' AS m033
, f.monitor_data->''34'' AS m034
, f.monitor_data->''35'' AS m035
, f.monitor_data->''36'' AS m036
, f.monitor_data->''37'' AS m037
, f.monitor_data->''38'' AS m038
, f.monitor_data->''39'' AS m039
, f.monitor_data->''40'' AS m040
, f.monitor_data->''41'' AS m041
, f.monitor_data->''42'' AS m042
, f.monitor_data->''43'' AS m043
, f.monitor_data->''44'' AS m044
, f.monitor_data->''45'' AS m045
, f.monitor_data->''46'' AS m046
, f.monitor_data->''47'' AS m047
, f.monitor_data->''48'' AS m048
, f.monitor_data->''49'' AS m049
, f.monitor_data->''50'' AS m050
, f.monitor_data->''51'' AS m051
, f.monitor_data->''52'' AS m052
, f.monitor_data->''53'' AS m053
, f.monitor_data->''54'' AS m054
, f.monitor_data->''55'' AS m055
, f.monitor_data->''56'' AS m056
, f.monitor_data->''57'' AS m057
, f.monitor_data->''58'' AS m058
, f.monitor_data->''59'' AS m059
, f.monitor_data->''60'' AS m060
, f.monitor_data->''61'' AS m061
, f.monitor_data->''62'' AS m062
, f.monitor_data->''63'' AS m063
, f.monitor_data->''64'' AS m064
, f.monitor_data->''65'' AS m065
, f.monitor_data->''66'' AS m066
, f.monitor_data->''67'' AS m067
, f.monitor_data->''68'' AS m068
, f.monitor_data->''69'' AS m069
, f.monitor_data->''70'' AS m070
, f.monitor_data->''71'' AS m071
, f.monitor_data->''72'' AS m072
, f.monitor_data->''73'' AS m073
, f.monitor_data->''74'' AS m074
, f.monitor_data->''75'' AS m075
, f.monitor_data->''76'' AS m076
, f.monitor_data->''77'' AS m077
, f.monitor_data->''78'' AS m078
, f.monitor_data->''79'' AS m079
, f.monitor_data->''80'' AS m080
, f.monitor_data->''81'' AS m081
, f.monitor_data->''82'' AS m082
, f.monitor_data->''83'' AS m083
, f.monitor_data->''84'' AS m084
, f.monitor_data->''85'' AS m085
, f.monitor_data->''86'' AS m086
, f.monitor_data->''87'' AS m087
, f.monitor_data->''88'' AS m088
, f.monitor_data->''89'' AS m089
, f.monitor_data->''95'' AS m095
, f.monitor_data->''96'' AS m096
, f.monitor_data->''97'' AS m097
, f.monitor_data->''98'' AS m098
, f.monitor_data->''100'' AS m100
, f.monitor_data->''101'' AS m101
, f.monitor_data->''102'' AS m102
, f.monitor_data->''Z11'' AS mz11
, f.monitor_data->''Z21'' AS mz21
, f.monitor_data->''Z31'' AS mz31
, f.monitor_data->''Z41'' AS mz41
, f.monitor_data->''Z51'' AS mz51
, f.monitor_data->''Z61'' AS mz61
, f.monitor_data->''Z71'' AS mz71
, f.monitor_data->''Z81'' AS mz81
, f.monitor_data->''Z91'' AS mz91
, f.monitor_data->''Z101'' AS mz101
, f.monitor_data->''Z111'' AS mz111
, f.monitor_data->''Z121'' AS mz121
, f.monitor_data->''Z131'' AS mz131
, f.monitor_data->''Z141'' AS mz141
, f.monitor_data->''Z151'' AS mz151
, f.monitor_data->''Z161'' AS mz161
, f.monitor_data->''Z171'' AS mz171
, f.monitor_data->''Z181'' AS mz181
, f.monitor_data->''Z191'' AS mz191
, f.monitor_data->''Z201'' AS mz201
, f.monitor_data->''Z211'' AS mz211
, f.monitor_data->''Z221'' AS mz221
, f.monitor_data->''Z231'' AS mz231
, f.monitor_data->''Z241'' AS mz241
, f.monitor_data->''Z251'' AS mz251
, f.monitor_data->''Z261'' AS mz261
, f.monitor_data->''Z271'' AS mz271
, f.monitor_data->''Z281'' AS mz281
, f.monitor_data->''Z291'' AS mz291
, f.monitor_data->''Z301'' AS mz301
, f.monitor_data->''Z311'' AS mz311
, f.monitor_data->''Z321'' AS mz321
, f.monitor_data->''Z331'' AS mz331
, f.monitor_data->''Z341'' AS mz341
, f.monitor_data->''Z351'' AS mz351
, f.monitor_data->''Z361'' AS mz361
, f.monitor_data->''Z371'' AS mz371
, f.monitor_data->''Z381'' AS mz381
, f.monitor_data->''Z391'' AS mz391
, f.monitor_data->''Z401'' AS mz401
, f.monitor_data->''Z411'' AS mz411
, f.monitor_data->''Z421'' AS mz421
, f.monitor_data->''Z431'' AS mz431
, f.monitor_data->''Z441'' AS mz441
, f.monitor_data->''Z451'' AS mz451
, f.monitor_data->''Z12'' AS mz12
, f.monitor_data->''Z22'' AS mz22
, f.monitor_data->''Z32'' AS mz32
, f.monitor_data->''Z42'' AS mz42
, f.monitor_data->''Z52'' AS mz52
, f.monitor_data->''Z62'' AS mz62
, f.monitor_data->''Z72'' AS mz72
, f.monitor_data->''Z82'' AS mz82
, f.monitor_data->''Z92'' AS mz92
, f.monitor_data->''Z102'' AS mz102
, f.monitor_data->''Z112'' AS mz112
, f.monitor_data->''Z122'' AS mz122
, f.monitor_data->''Z132'' AS mz132
, f.monitor_data->''Z142'' AS mz142
, f.monitor_data->''Z152'' AS mz152
, f.monitor_data->''Z162'' AS mz162
, f.monitor_data->''Z172'' AS mz172
, f.monitor_data->''Z182'' AS mz182
, f.monitor_data->''Z192'' AS mz192
, f.monitor_data->''Z202'' AS mz202
, f.monitor_data->''Z212'' AS mz212
, f.monitor_data->''Z222'' AS mz222
, f.monitor_data->''Z232'' AS mz232
, f.monitor_data->''Z13'' AS mz13
, f.monitor_data->''Z23'' AS mz23
, f.monitor_data->''Z33'' AS mz33
, f.monitor_data->''Z43'' AS mz43
, f.monitor_data->''Z53'' AS mz53
, f.monitor_data->''Z63'' AS mz63
, f.monitor_data->''Z73'' AS mz73
, f.monitor_data->''Z83'' AS mz83
, f.monitor_data->''Z93'' AS mz93
, f.monitor_data->''Z103'' AS mZ103
, f.monitor_data->''Z113'' AS mZ113
, f.monitor_data->''Z123'' AS mZ123
, f.monitor_data->''Z133'' AS mZ133
, f.monitor_data->''Z143'' AS mZ143
, f.monitor_data->''Z153'' AS mZ153
, f.monitor_data->''Z163'' AS mZ163
, f.monitor_data->''Z173'' AS mZ173
, f.monitor_data->''Z183'' AS mZ183
, f.monitor_data->''Z193'' AS mZ193
, f.monitor_data->''Z203'' AS mZ203
, f.monitor_data->''Z213'' AS mZ213
, f.monitor_data->''Z223'' AS mZ223
, f.monitor_data->''Z233'' AS mZ233
, f.monitor_data->''Z243'' AS mZ243
, f.monitor_data->''Z253'' AS mZ253
, f.monitor_data->''Z263'' AS mZ263
, f.monitor_data->''Z14'' AS mz14
, f.monitor_data->''Z24'' AS mz24
, f.monitor_data->''Z34'' AS mz34
, f.monitor_data->''Z44'' AS mz44
, f.monitor_data->''Z54'' AS mz54
, f.monitor_data->''Z64'' AS mz64
, f.monitor_data->''Z74'' AS mz74
, f.monitor_data->''Z84'' AS mz84
, f.monitor_data->''Z94'' AS mz94
, f.monitor_data->''Z104'' AS mz104
, f.monitor_data->''Z114'' AS mz114
, f.monitor_data->''Z124'' AS mz124
, f.monitor_data->''Z134'' AS mz134
, f.monitor_data->''Z144'' AS mz144
, f.monitor_data->''Z154'' AS mz154
, f.monitor_data->''Z164'' AS mz164
, f.monitor_data->''Z174'' AS mz174
, f.monitor_data->''Z184'' AS mz184
, f.monitor_data->''Z194'' AS mz194
, f.monitor_data->''Z204'' AS mz204
, f.monitor_data->''Z214'' AS mz214
, f.monitor_data->''Z224'' AS mz224
, f.monitor_data->''Z234'' AS mz234
, f.monitor_data->''Z244'' AS mz244
, f.monitor_data->''Z254'' AS mz254
, f.monitor_data->''Z264'' AS mz264
, f.monitor_data->''Z274'' AS mz274
, f.monitor_data->''Z284'' AS mz284
, f.monitor_data->''Z294'' AS mz294
, f.monitor_data->''Z304'' AS mz304
, f.monitor_data->''Z314'' AS mz314
, f.monitor_data->''Z324'' AS mz324
, f.monitor_data->''Z334'' AS mz334
, f.monitor_data->''Z344'' AS mz344
, f.monitor_data->''Z354'' AS mz354
, f.monitor_data->''Z364'' AS mz364
, f.monitor_data->''Z374'' AS mz374
, BpBefore.*
, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS 引き残し
, b.pat_id AS hosp_pat_id
, to_char(b.rst_end_date, ''yyyy/mm/dd hh24:mi:ss'') as 治療終了
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS 終了予測補液完了
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS 静的静脈圧
, b.rst_dw AS 前回後体重
, b.rst_weight_info ->> ''weight_before'' AS 前体重
, b.rst_weight_info #>> ''{ihdf_pll}'' AS IHDF引き残し量
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS 除水補正合計
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,f.monitor_data->''Z212'' AS 装置自己診断
,b.rst_bed_name AS ベッド名
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS 前体重風袋合計
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS 後体重風袋合計
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS 最新愁訴
, o.treatment AS 最新処置
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as 透析液使用数
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS 前体重DW
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS 前体重目標体重
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS 前体重後体重
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 AS 増加率
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as 増加量
,round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  as 達成率
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as 予想引き残し
,COALESCE(j.観察記録件数,0) as 観察記録件数
,k.警報・報知
,l.指示変更
,m.投与状況
,n.rate as 再循環率有効値
from b
LEFT outer JOIN j on (b.pat_id = j.pat_id)
LEFT JOIN k on (b.ord_no = k.ord_no)
LEFT JOIN l ON (b.ord_no = l.ord_no)
LEFT JOIN m ON (b.ord_no = m.ord_no)
LEFT JOIN n ON (b.ord_no = n.ord_no)
LEFT JOIN o on (b.ord_no = o.ord_no)
left outer join f on (b.ord_no = f.ord_no)
left outer join mnt_machine_state on (b.facility_cd = mnt_machine_state.facility_cd and b.ind_bed_cd = mnt_machine_state.bed_cd)
left outer join pat_unique on (b.pat_id = pat_unique.pat_id)
left outer join BpBefore on (b.ord_no = BpBefore.ord_no)
left outer join BpCurrent on (b.ord_no = BpCurrent.ord_no)
left outer join BpAfter on (b.ord_no = BpAfter.ord_no)
order by b.treat_date, b.ord_no, f.bio_moni_ctl_no', 2, '[{"preview": "2020/06/15", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "treat_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午後", "can_calc": "0", "data_code": "ind_kur_name", "data_name": "クール", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ind_kur_name", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "運転", "can_calc": "0", "data_code": "process_state", "data_name": "状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "process_state", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "目標体重", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "目標体重から", "data_name": "目標体重から", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重から", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_start_date", "data_name": "治療開始", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_start_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測", "data_name": "終了予測", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測_除水完了", "data_name": "終了予測(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_除水完了", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測_透析完了", "data_name": "終了予測(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_透析完了", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_end_date", "data_name": "rst_end_date", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_end_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "治療時間", "data_name": "治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "遅れ時間", "data_name": "遅れ時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "遅れ時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "進捗率", "data_name": "進捗率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "進捗率", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "weight_before", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_最高", "data_name": "前血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_最低", "data_name": "前血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_平均", "data_name": "前血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "前血圧", "data_name": "前血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "前脈拍", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "現在血圧", "data_name": "現在血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "現在血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_1", "data_name": "担当者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_1", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_2", "data_name": "担当者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_2", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date", "data_name": "穿刺日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_1", "data_name": "穿刺者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_1", "data_name": "穿刺1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_2", "data_name": "穿刺者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_2", "data_name": "穿刺2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date", "data_name": "返血日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_1", "data_name": "返血者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_1", "data_name": "返血1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_2", "data_name": "返血者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_2", "data_name": "返血2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_after", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_最高", "data_name": "後血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_最低", "data_name": "後血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_平均", "data_name": "後血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "後血圧", "data_name": "後血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "後脈拍", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_target", "data_name": "除水目標", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "water_removal_target", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "患者確認", "data_name": "患者確認", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "患者確認", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-03-25T09:20:30.000+09:00", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-12-10 01:56:01", "can_calc": "0", "data_code": "終了予定", "data_name": "終了予定", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予定", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "回診状態", "data_name": "回診状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診状態", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未回診", "can_calc": "0", "data_code": "回診データ", "data_name": "回診データ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診データ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ctr", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "右", "can_calc": "0", "data_code": "va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "va", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "除水量制限", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "除水量制限", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装[FDY-21GW]", "can_calc": "0", "data_code": "ダイアライザ", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ダイアライザ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト吸着カラム１", "can_calc": "0", "data_code": "吸着カラム", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "吸着カラム", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "一次膜", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "一次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "二次膜", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "二次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針１", "can_calc": "0", "data_code": "穿刺針_a針", "data_name": "穿刺針(A針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_a針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針２", "can_calc": "0", "data_code": "穿刺針_v針", "data_name": "穿刺針(V針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_v針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針3", "can_calc": "0", "data_code": "穿刺針_sn", "data_name": "穿刺針(SN)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_sn", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "シングルニードル使用", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "シングルニードル使用", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト血液回路１", "can_calc": "0", "data_code": "血液回路", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "血液回路", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "血流量", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "血流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト透析液１", "can_calc": "0", "data_code": "透析液", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "透析液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "透析液流量", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "349", "can_calc": "0", "data_code": "透析液量", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.0", "can_calc": "0", "data_code": "透析液温度", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液１", "can_calc": "0", "data_code": "補液", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "補液量", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "補液選択", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "補液使用数", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液使用数", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.9", "can_calc": "0", "data_code": "補液温度", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "補液速度", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤１", "can_calc": "0", "data_code": "抗凝固剤", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "抗凝固剤ワンショット量", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤ワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "抗凝固剤持続速度", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip使用選択", "data_name": "ip使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "ip使用選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ipスタート", "data_name": "ipスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "治療状況", "field_name": "ipスタート", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "ipワンショット量", "data_name": "ipワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ipワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip速度", "data_name": "ip速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip速度最大値", "data_name": "ip速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip速度最大値", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "自動ワンショット", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "自動ワンショット", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip電源自動切り", "data_name": "ip電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "ip電源自動切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip電源okモニタ切り", "data_name": "ip電源okモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "ip電源okモニタ切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "ip電源okモニタ切り時間", "data_name": "ip電源okモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源okモニタ切り時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m000", "data_name": "工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m000", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "m001", "data_name": "経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m001", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "m002", "data_name": "経過時間(ECUM)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m002", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m003", "data_name": "残り時間(除水完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m003", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "m004", "data_name": "残り時間(透析完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m004", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m005", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m005", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.55", "can_calc": "0", "data_code": "m006", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m006", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3.0", "can_calc": "0", "data_code": "m007", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m007", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "0", "data_code": "m009", "data_name": "IP総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m009", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.0", "can_calc": "0", "data_code": "m010", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m010", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "m011", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m011", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "m012", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m012", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m013", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m013", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m014", "data_name": "ダイアライザー入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m014", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "m015", "data_name": "ダイアライザー差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m015", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "m016", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m016", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.0", "can_calc": "0", "data_code": "m017", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m017", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.40", "can_calc": "0", "data_code": "m018", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m018", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "m019", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m019", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16", "can_calc": "0", "data_code": "m020", "data_name": "Na濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m020", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.0", "can_calc": "0", "data_code": "m021", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m021", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "18", "can_calc": "0", "data_code": "m022", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m022", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.9", "can_calc": "0", "data_code": "m023", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m023", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m024", "data_name": "給液圧(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m024", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m025", "data_name": "給液圧(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m025", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22.00", "can_calc": "0", "data_code": "m026", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m026", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "m027", "data_name": "UFR低下率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m027", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "24.00", "can_calc": "0", "data_code": "m028", "data_name": "初期UFR測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m028", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25.0", "can_calc": "0", "data_code": "m029", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m029", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "26", "can_calc": "0", "data_code": "m030", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m030", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m031", "data_name": "治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m031", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "28.00", "can_calc": "0", "data_code": "m032", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m032", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "0", "data_code": "m033", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m033", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m034", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m034", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "31", "can_calc": "0", "data_code": "m035", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m035", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "32", "can_calc": "0", "data_code": "m036", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m036", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m037", "data_name": "IP速度設定", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m037", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.34", "can_calc": "0", "data_code": "m038", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m038", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "0", "data_code": "m039", "data_name": "静脈圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m039", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36", "can_calc": "0", "data_code": "m040", "data_name": "静脈圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m040", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37", "can_calc": "0", "data_code": "m041", "data_name": "透析液圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m041", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "m042", "data_name": "透析液圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m042", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m043", "data_name": "TMP警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m043", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m044", "data_name": "TMP警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m044", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m045", "data_name": "ダイアライザー入口圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m045", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "0", "data_code": "m046", "data_name": "ダイアライザー入口圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m046", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "43", "can_calc": "0", "data_code": "m047", "data_name": "ダイアライザー差圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m047", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "44", "can_calc": "0", "data_code": "m048", "data_name": "ダイアライザー差圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m048", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-45.0", "can_calc": "0", "data_code": "m049", "data_name": "⊿BV低下警報点１", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m049", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-46.0", "can_calc": "0", "data_code": "m050", "data_name": "⊿BV低下警報点２", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m050", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-17.0", "can_calc": "0", "data_code": "m051", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m051", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "48", "can_calc": "0", "data_code": "m052", "data_name": "BPM関連データ9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m052", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-49", "can_calc": "0", "data_code": "m053", "data_name": "BPM関連データ10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m053", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "m054", "data_name": "バイカーボ濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m054", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.10", "can_calc": "0", "data_code": "m055", "data_name": "バイカーボ濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m055", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "m056", "data_name": "透析液濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m056", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "53.0", "can_calc": "0", "data_code": "m057", "data_name": "透析液濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m057", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "54", "can_calc": "0", "data_code": "m058", "data_name": "Na濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m058", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55", "can_calc": "0", "data_code": "m059", "data_name": "Na濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m059", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.0", "can_calc": "0", "data_code": "m060", "data_name": "透析液温度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m060", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.0", "can_calc": "0", "data_code": "m061", "data_name": "透析液温度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m061", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.8", "can_calc": "0", "data_code": "m062", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m062", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "59", "can_calc": "0", "data_code": "m063", "data_name": "給水圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m063", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "m064", "data_name": "給水圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m064", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.10", "can_calc": "0", "data_code": "m065", "data_name": "初期UFR警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m065", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "62.00", "can_calc": "0", "data_code": "m066", "data_name": "初期UFR警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m066", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "63", "can_calc": "0", "data_code": "m067", "data_name": "UFR低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m067", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.60", "can_calc": "0", "data_code": "m068", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m068", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.50", "can_calc": "0", "data_code": "m069", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m069", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.5", "can_calc": "0", "data_code": "m070", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m070", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.68", "can_calc": "0", "data_code": "m071", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m071", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "69.00", "can_calc": "0", "data_code": "m072", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m072", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.70", "can_calc": "0", "data_code": "m073", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m073", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.7", "can_calc": "0", "data_code": "m074", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m074", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30.0", "can_calc": "0", "data_code": "m075", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m075", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.30", "can_calc": "0", "data_code": "m076", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m076", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "74.00", "can_calc": "0", "data_code": "m077", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m077", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m078", "data_name": "残り時間(補液完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m078", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m079", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m079", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "77.0", "can_calc": "0", "data_code": "m080", "data_name": "⊿BV変化率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m080", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "78.00", "can_calc": "0", "data_code": "m081", "data_name": "PWI", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m081", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "79", "can_calc": "0", "data_code": "m082", "data_name": "BPM関連データ1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m082", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "0", "data_code": "m083", "data_name": "BPM関連データ2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m083", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m084", "data_name": "BPM関連データ3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m084", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82.0", "can_calc": "0", "data_code": "m085", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m085", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "83.0", "can_calc": "0", "data_code": "m086", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m086", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "84", "can_calc": "0", "data_code": "m087", "data_name": "BPM関連データ6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m087", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "0", "data_code": "m088", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m088", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m089", "data_name": "再循環率測定結果(BVMS連携用)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m089", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "m095", "data_name": "⊿BV5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m095", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "0", "data_code": "m096", "data_name": "⊿BV最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m096", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "m097", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m097", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m098", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m098", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m100", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz11", "data_name": "[ACHΣ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz11", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz21", "data_name": "[ACHΣ]工程状態", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz21", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz31", "data_name": "[ACHΣ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz31", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz41", "data_name": "[ACHΣ]血液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz41", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz51", "data_name": "[ACHΣ]シリンジ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz51", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz61", "data_name": "[ACHΣ]ろ過流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz61", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz71", "data_name": "[ACHΣ]透析液/ドレン流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz71", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz81", "data_name": "[ACHΣ]補液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz81", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz91", "data_name": "[ACHΣ]透析液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz91", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz101", "data_name": "[ACHΣ]補液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz111", "data_name": "[ACHΣ]現在除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz111", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz121", "data_name": "[ACHΣ]現在血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz121", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz131", "data_name": "[ACHΣ]現在ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz131", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz141", "data_name": "[ACHΣ]現在透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz141", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz151", "data_name": "[ACHΣ]現在補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz151", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz161", "data_name": "[ACHΣ]治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz161", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz171", "data_name": "[ACHΣ]シリンジ積算量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz171", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz181", "data_name": "[ACHΣ]目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz181", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz191", "data_name": "[ACHΣ]目標血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz191", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz201", "data_name": "[ACHΣ]目標ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz201", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz211", "data_name": "[ACHΣ]目標透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz211", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz221", "data_name": "[ACHΣ]目標補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz221", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz231", "data_name": "[ACHΣ]目標治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz231", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz241", "data_name": "[ACHΣ]脱血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz241", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz251", "data_name": "[ACHΣ]入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz251", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz261", "data_name": "[ACHΣ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz261", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz271", "data_name": "[ACHΣ]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz271", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz281", "data_name": "[ACHΣ]排気圧/2次膜圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz281", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz291", "data_name": "[ACHΣ]TMP/TMP1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz291", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz301", "data_name": "[ACHΣ]TMP2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz301", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz311", "data_name": "[ACHΣ]差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz311", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz321", "data_name": "[ACHΣ]気泡検知警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz321", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz331", "data_name": "[ACHΣ]漏血警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz331", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz341", "data_name": "[ACHΣ]加温器警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz341", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz351", "data_name": "[ACHΣ]脱血圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz351", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz361", "data_name": "[ACHΣ]入口圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz361", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz371", "data_name": "[ACHΣ]静脈圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz371", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz381", "data_name": "[ACHΣ]ろ過圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz381", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz391", "data_name": "[ACHΣ]排気圧/2次膜圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz391", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz401", "data_name": "[ACHΣ]TMP警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz401", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz411", "data_name": "[ACHΣ]TMP2警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz411", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz421", "data_name": "[ACHΣ]差圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz421", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz431", "data_name": "[ACHΣ]その他警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz431", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz441", "data_name": "[ACHΣ]クエン酸流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz441", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz451", "data_name": "[ACHΣ]現在クエン酸量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz451", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz12", "data_name": "[KM8900]測定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz12", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz22", "data_name": "[KM8900]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz22", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz32", "data_name": "[KM8900]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz32", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz42", "data_name": "[KM8900]測定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz42", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz52", "data_name": "[KM8900]圧力上限警報設定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz52", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz62", "data_name": "[KM8900]圧力上限警報設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz62", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz72", "data_name": "[KM8900]圧力上限警報設定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz72", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz82", "data_name": "[KM8900]圧力上限警報設定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz82", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz92", "data_name": "[KM8900]流量情報BP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz92", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz102", "data_name": "[KM8900]流量情報PP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz112", "data_name": "[KM8900]流量情報DP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz112", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz122", "data_name": "[KM8900]流量情報BP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz122", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz132", "data_name": "[KM8900]流量情報PP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz132", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz142", "data_name": "[KM8900]流量情報DP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz142", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz152", "data_name": "[KM8900]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz152", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz162", "data_name": "[KM8900]流量情報血漿処理目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz162", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz172", "data_name": "[KM8900]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz172", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz182", "data_name": "[KM8900]その他情報バランス", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz182", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz192", "data_name": "[KM8900]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz192", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz202", "data_name": "[KM8900]その他情報アラーム番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz202", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz212", "data_name": "[KM8900]その他情報自己診断番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz212", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz222", "data_name": "[KM8900]その他情報モード(用途)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz222", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz232", "data_name": "[KM8900]その他情報工程情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz232", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz13", "data_name": "[iQ21]治療経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz13", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz23", "data_name": "[iQ21]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz23", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz33", "data_name": "[iQ21]ろ過ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz33", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz43", "data_name": "[iQ21]補液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz43", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz53", "data_name": "[iQ21]透析液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz53", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz63", "data_name": "[iQ21]血液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz63", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz73", "data_name": "[iQ21]シリンジポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz73", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz83", "data_name": "[iQ21]除水量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz83", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz93", "data_name": "[iQ21]ろ過量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz93", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz103", "data_name": "[iQ21]補液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz113", "data_name": "[iQ21]透析液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz113", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz123", "data_name": "[iQ21]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz123", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz133", "data_name": "[iQ21]シリンジポンプ積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz133", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz143", "data_name": "[iQ21]採血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz143", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz153", "data_name": "[iQ21]動脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz153", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz163", "data_name": "[iQ21]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz163", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz173", "data_name": "[iQ21]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz173", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz183", "data_name": "[iQ21]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz183", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz193", "data_name": "[iQ21]分離ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz193", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz203", "data_name": "[iQ21]返漿ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz203", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz213", "data_name": "[iQ21]ドレンポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz213", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz223", "data_name": "[iQ21]分離量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz223", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz233", "data_name": "[iQ21]返漿量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz233", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz243", "data_name": "[iQ21]ドレン量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz243", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz253", "data_name": "[iQ21]血漿圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz253", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz263", "data_name": "[iQ21]血漿入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz263", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz14", "data_name": "[KM9000]測定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz14", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz24", "data_name": "[KM9000]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz24", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz34", "data_name": "[KM9000]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz34", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz44", "data_name": "[KM9000]測定値ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz44", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz54", "data_name": "[KM9000]測定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz54", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz64", "data_name": "[KM9000]設定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz64", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz74", "data_name": "[KM9000]設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz74", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz84", "data_name": "[KM9000]設定値返血圧・上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz84", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz94", "data_name": "[KM9000]設定値返血圧・下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz94", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz104", "data_name": "[KM9000]設定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz104", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz114", "data_name": "[KM9000]設定値除水設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz114", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz124", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz124", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz134", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz134", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz144", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz144", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz154", "data_name": "[KM9000]流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz154", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz164", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz164", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz174", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz174", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz184", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz184", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz194", "data_name": "[KM9000]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz194", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz204", "data_name": "[KM9000]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz204", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz214", "data_name": "[KM9000]その他情報除水差分/重量値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz214", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz224", "data_name": "[KM9000]その他情報初期診断情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz224", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz234", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz234", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz244", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz244", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz254", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz254", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz264", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報4", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz264", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz274", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報5", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz274", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz284", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz284", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz294", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報7", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz294", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz304", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報8", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz304", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz314", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz314", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz324", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz324", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz334", "data_name": "[KM9000]その他情報注意情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz334", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz344", "data_name": "[KM9000]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz344", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz354", "data_name": "[KM9000]その他情報用途", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz354", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz364", "data_name": "[KM9000]その他情報工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz364", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz374", "data_name": "[KM9000]その他情報動作日、時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz374", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "dw", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "iapratio", "data_name": "IAP Ratio", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "iapratio", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "ihdf引き残し量", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ihdf引き残し量", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip電源自動切り時間", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源自動切り時間", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "引き残し", "data_name": "引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "引き残し", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "観察記録件数", "data_name": "観察記録件数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "観察記録件数", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "警報・報知", "data_name": "警報・報知", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "警報・報知", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "後体重風袋合計", "data_name": "後体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "0", "data_code": "抗凝固剤持続総量", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続総量", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "0", "data_code": "再循環率有効値", "data_name": "再循環率有効値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "再循環率有効値", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "最新愁訴", "data_name": "最新愁訴", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新愁訴", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "最新処置", "data_name": "最新処置", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新処置", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "はい", "can_calc": "0", "data_code": "指示変更", "data_name": "指示変更", "data_type": "string", "conv_table": [{"code": 0, "disp": "変更なし", "item": "変更なし"}, {"code": 1, "disp": "変更あり", "item": "変更あり"}], "data_class": "治療状況", "field_name": "指示変更", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "治療終了", "data_name": "治療終了", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療終了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測補液完了", "data_name": "終了予測(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測補液完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "除水補正合計", "data_name": "除水補正合計", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "除水補正合計", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "静的静脈圧", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "静的静脈圧", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "前回後体重", "data_name": "前回後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前回後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.90", "can_calc": "0", "data_code": "前体重", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "前体重dw", "data_name": "前体重DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重dw", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "前体重目標体重", "data_name": "前体重 - 目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重目標体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "前体重後体重", "data_name": "前体重-後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "前体重風袋合計", "data_name": "前体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "装置自己診断", "data_name": "装置自己診断", "data_type": "string", "conv_table": [{"code": 0, "disp": "未実施", "item": "未実施"}, {"code": 1, "disp": "已実施", "item": "已実施"}], "data_class": "治療状況", "field_name": "装置自己診断", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "増加率", "data_name": "増加率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "増加量", "data_name": "増加量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "達成率", "data_name": "達成率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "達成率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0/0", "can_calc": "0", "data_code": "投与状況", "data_name": "投与状況", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "投与状況", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "透析液使用数", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液使用数", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "予想引き残し", "data_name": "予想引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "予想引き残し", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "ベッド名", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ベッド名", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト', '2020-04-25 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (141, 'select a.f_medi_cd,a.medicine_name as f_medi_name,a.f_medi_amount,a.medicine_unit as f_medicine_unit,array_agg(a.f_week) as f_week from (
select
		weekmedi_info.cd as f_medi_cd,
    mmd.medicine_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
    mmd.unit as medicine_unit,
    weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    CAST(medi ->>''amount'' AS DECIMAL) as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and
      ord.pat_id = @patId

 and
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mmd.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''1''
 UNION ALL
 select
		weekmedi_info.cd as f_medi_cd,
    mix.medicine_mix_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
		mix.unit as medicine_unit,
   weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    CAST(medi ->>''amount'' AS DECIMAL) as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and
      ord.pat_id = @patId

 and
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine_mix as mix
    on
      mix.medicine_mix_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mix.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''2''
 )  a
     group by a.f_medi_cd,a.medicine_name,a.f_medi_amount,a.medicine_unit', 2, '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_cd", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 9, 10]}', '紹介状　指示：投薬(未来有効）　@facilityCd@patId@fromdate@todate使用', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (161, 'select rst_treatment_name,rst_kur_name,rst_bed_name,rst_dw,case when  abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999'')) then  mst.in_hospital_cd_a1 else mst.in_hospital_cd_b1 end as rst_trea_in_hospital_cd_1,case when  abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999'')) then  mst.in_hospital_cd_a2 else mst.in_hospital_cd_b2 end as rst_trea_in_hospital_cd_2,case when  abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999'')) then  mst.in_hospital_cd_a3 else mst.in_hospital_cd_b3 end as rst_trea_in_hospital_cd_3,case when  abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',to_date(ord.treat_date,''yyyyMMdd'')) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999'')) then  mst.in_hospital_cd_a4 else mst.in_hospital_cd_b4 end as rst_trea_in_hospital_cd_4,msk.in_hospital_cd_1 as rst_kur_in_hospital_cd_1,msb.in_hospital_cd_1 as rst_bed_in_hospital_cd_1,msb.in_hospital_cd_2 as rst_bed_in_hospital_cd_2 from ord_main ord left join mst_treatment mst on ( ord.rst_treatment_cd = mst.treatment_cd  and mst.is_del = ''0'' and mst.is_disp = ''1'' ) left join mst_kur  msk on ( ord.rst_kur_cd = msk.kur_cd and msk.is_del = ''0''  ) left join mst_bed  msb on ( ord.rst_bed_cd = msb.bed_cd and msb.is_disp = ''1'' and msb.is_del = ''0'' ) where ord.pat_id = @patId  and ord.ord_no = @ordNo and ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6'';', 2, '[{"preview": "テスト治療方法", "can_calc": "0", "data_code": "rst_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストクール", "can_calc": "0", "data_code": "rst_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_kur_in_hospital_cd_1", "data_name": "クール連携コード", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド", "can_calc": "0", "data_code": "rst_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_1", "data_name": "ベッド連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_2", "data_name": "ベッド連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "rst_dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dw", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', '', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (162, 'WITH DATA AS (




with tmp as
(
select
  CAST(rst_weight_info->>''weight_before'' AS DECIMAL) as weight_before
  ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date

  ,CAST(rst_weight_info->>''weight_after'' AS DECIMAL) as weight_after
  ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date

  ,CAST(rst_weight_info->>''ctr'' AS DECIMAL) as ctr
  ,(rst_weight_info->>''ctr_measure_date'')::timestamp as ctr_measure_date
  ,CAST(rst_weight_info->>''ctr_weight'' AS DECIMAL) as ctr_weight

  ,CAST(rst_weight_info->>''kt_v_measure'' AS DECIMAL) as kt_v_measure
  ,CAST(rst_weight_info->>''urr'' AS DECIMAL) as urr
  ,CAST((select monitor_data from mni_monitor where ord_no = @ordNo and bio_moni_ctl_no::text = rst_weight_info->>''re_loop_rate_main'' and is_del = ''0'')->>''38'' AS DECIMAL) as re_loop_rate

  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''90'', ''999'') as before_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''91'', ''999'') as before_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''92'', ''999'') as before_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''93'', ''999'') as before_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'') as before_vital_measure_date

  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''90'', ''999'') as after_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''91'', ''999'') as after_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''92'', ''999'') as after_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''93'', ''999'') as after_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'') as after_vital_measure_date
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
 and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)

select
  @ordNo as ord_no_t,*
  ,before_bp_high::text || ''/'' || before_bp_low::text || ''/'' || before_bp_ave || ''('' || before_pulse::text || '')'' as before_bp_summary
  ,after_bp_high::text || ''/'' || after_bp_low::text || ''/'' || after_bp_ave || ''('' || after_pulse::text || '')'' as after_bp_summary
from
  tmp

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
	', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：体重情報/血圧情報 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (166, 'WITH DATA AS (

with ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where ord_no = @ordNo
  and is_del = ''0''
), bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
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
      (select * from pat_unique where is_del = ''0'') as pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
), pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
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
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
    ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.rst_kur_cd as kur_cd,
  ord.ord_no as ord_no_t,
  ord.rst_treatment_cd as treatment_cd,
  to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,

  to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,

  ord.rst_bed_cd as bed_cd,

  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  --ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''12''->>''value'' as single_needle,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''29''->>''value'' as ip,
  ord.rst_cond_info->''30''->>''value'' as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
  ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  CAST(ord.rst_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.rst_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.rst_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.rst_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,


  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,
  mst_va.va_direct as va_direct,


  mst_treatment.device_mode,
  mst_bed.shunt_position,
  mst_bed.is_infection,
  mst_bed.emergency_class,
  mst_machine.machine_name,

  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.maker,
  mst_dialyzer.function_class,
  mst_dialyzer.area,
  mst_dialyzer.ufr,
  mst_dialyzer.koa,
  mst_dialyzer.material,
  mst_dialyzer.wetdry,
  mst_dialyzer.sterilization,
  mst_dialyzer.bloodamt,
  mst_dialyzer.alqd_flood_vol,
  mst_dialyzer.urea_clearance,
  mst_dialyzer.gas_purge_time,
  mst_dialyzer.substituent_wash_amt,
  mst_dialyzer.membrane_wash,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,


  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,

   case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,

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

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit

  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_1'', ''''), '' '') as rst_charge_user_name1
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_2'', ''''), '' '') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_1'', ''''), '' '') as rst_puncture_user_name1
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_2'', ''''), '' '') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,trim(coalesce(rst_return_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_1'', ''''), '' '') as rst_return_user_name1
  ,trim(coalesce(rst_return_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_2'', ''''), '' '') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,pull_leave_amount
  ,ord.rst_dw
  ,ord.rst_treatment_name

from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1''  -- 実績

  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1''
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1''
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1''

  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1'' and mst_dialyzer.dialyzer_cd in (@diaIds)

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1''and adsorption_column_tbl.class_cd IN (@eqIds)
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' and primary_film_tbl.class_cd IN (@eqIds)
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' and secondary_film_tbl.class_cd IN (@eqIds)

  left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' and puncture_needle_a_tbl.class_cd IN (@eqIds)
  left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' and puncture_needle_v_tbl.class_cd IN (@eqIds)
  left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' and puncture_needle_sn_tbl.class_cd IN (@eqIds)
  left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' and blood_circuit_tbl.class_cd IN (@eqIds)

  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1'' and  med_dialysate_tbl.class_cd IN ( @medIds )
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1'' and  med_fluid_replacement_tbl.class_cd IN ( @medIds )
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''   and  med_anti_coagulant_tbl.class_cd IN ( @medIds )

  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1'' and  mix_dialysate_tbl.class_cd IN ( @medIds )
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1'' and  mix_fluid_replacement_tbl.class_cd IN ( @medIds )
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1''  and  mix_anti_coagulant_tbl.class_cd IN ( @medIds )
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''    )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   )
where
  ord.ord_no = @ordNo
 and ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''
 and ord.is_del = ''0''

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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "pull_leave_amount", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "pull_leave_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (169, 'WITH DATA AS (


	with current_ord AS (
    select pat_id, treat_date, rst_start_date
    from ord_main
    where ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
),
hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main INNER JOIN current_ord ON ord_main.pat_id = current_ord.pat_id
  where    rst_dialysis_state >''0'' and rst_dialysis_state <''6''
    and ord_main.ord_no <> @ordNo
    and (((current_ord.rst_start_date is not null) and (ord_main.rst_start_date <= current_ord.rst_start_date))
        or
         ((current_ord.rst_start_date is null) and (ord_main.rst_start_date is not null) and (ord_main.treat_date <= current_ord.treat_date)))
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_tbl as (
  select rst_start_date
    ,CAST(rst_weight_info->>''weight_before'' AS DECIMAL) as weight_before
    ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date
    ,CAST(rst_weight_info->>''weight_after'' AS DECIMAL) as weight_after
    ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date
    ,CAST(rst_weight_info->>''water_removal_rst'' AS DECIMAL) as water_removal_rst
  from
    ord_main
  where
    ord_no in (select ord_no from hist_ord_nos)
  and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
), ord_array_tbl as (
  select
    array_agg(weight_before order by rst_start_date desc) as array_weight_before
    ,array_agg(weight_before_date order by rst_start_date desc) as array_weight_before_date
    ,array_agg(weight_after order by rst_start_date desc) as array_weight_after
    ,array_agg(weight_after_date order by rst_start_date desc) as array_weight_after_date
    ,array_agg(water_removal_rst order by rst_start_date desc) as array_water_removal_rst
  from
    ord_hist_tbl
)
select
	@ordNo as ord_no_t
	,array_water_removal_rst[1] as water_removal_rst_prev
  ,array_weight_before[2] as weight_before_prev_prev
  ,array_weight_before_date[2] as weight_before_date_prev_prev
  ,array_weight_after[2] as weight_after_prev_prev
  ,array_weight_after_date[2] as weight_after_date_prev_prev
  ,array_water_removal_rst[2] as water_removal_rst_prev_prev
from
  ord_array_tbl

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
	', 2, '[{"preview": "2.00", "can_calc": "1", "data_code": "water_removal_rst_prev", "data_name": "実績除水量(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "58.20", "can_calc": "1", "data_code": "weight_before_prev_prev", "data_name": "前体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_before_date_prev_prev", "data_name": "前体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.30", "can_calc": "1", "data_code": "weight_after_prev_prev", "data_name": "後体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_after_date_prev_prev", "data_name": "後体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.10", "can_calc": "1", "data_code": "water_removal_rst_prev_prev", "data_name": "実績除水量(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：体重情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (173, 'WITH DATA AS (

with tmp as
(
  select
  CAST(rst_weight_info->>''water_removal_target'' AS DECIMAL) as water_removal_target
  ,CAST(rst_weight_info->>''water_removal_rst'' AS DECIMAL) as water_removal_rst
  ,CAST(rst_weight_info->>''add_water_total'' AS DECIMAL) as add_water_total

  ,rst_tare_info->''before''->>''name_1'' as before_tare_name_1
  ,rst_tare_info->''before''->>''name_2'' as before_tare_name_2
  ,rst_tare_info->''before''->>''name_3'' as before_tare_name_3
  ,rst_tare_info->''before''->>''name_4'' as before_tare_name_4
  ,rst_tare_info->''before''->>''name_5'' as before_tare_name_5
  ,CAST(rst_tare_info->''before''->>''weight_1'' AS DECIMAL) as before_tare_weight_1
  ,CAST(rst_tare_info->''before''->>''weight_2'' AS DECIMAL) as before_tare_weight_2
  ,CAST(rst_tare_info->''before''->>''weight_3'' AS DECIMAL) as before_tare_weight_3
  ,CAST(rst_tare_info->''before''->>''weight_4'' AS DECIMAL) as before_tare_weight_4
  ,CAST(rst_tare_info->''before''->>''weight_5'' AS DECIMAL) as before_tare_weight_5
  ,rst_tare_info->''before''->>''wheel_chair_name'' as before_wheel_chair_name
  ,CAST(rst_tare_info->''before''->>''wheel_chair_weight'' AS DECIMAL) as before_wheel_chair_weight

  ,rst_tare_info->''after''->>''name_1'' as after_tare_name_1
  ,rst_tare_info->''after''->>''name_2'' as after_tare_name_2
  ,rst_tare_info->''after''->>''name_3'' as after_tare_name_3
  ,rst_tare_info->''after''->>''name_4'' as after_tare_name_4
  ,rst_tare_info->''after''->>''name_5'' as after_tare_name_5
  ,CAST(rst_tare_info->''after''->>''weight_1'' AS DECIMAL) as after_tare_weight_1
  ,CAST(rst_tare_info->''after''->>''weight_2'' AS DECIMAL) as after_tare_weight_2
  ,CAST(rst_tare_info->''after''->>''weight_3'' AS DECIMAL) as after_tare_weight_3
  ,CAST(rst_tare_info->''after''->>''weight_4'' AS DECIMAL) as after_tare_weight_4
  ,CAST(rst_tare_info->''after''->>''weight_5'' AS DECIMAL) as after_tare_weight_5
  ,rst_tare_info->''after''->>''wheel_chair_name'' as after_wheel_chair_name
  ,CAST(rst_tare_info->''after''->>''wheel_chair_weight'' AS DECIMAL) as after_wheel_chair_weight

  ,rst_off_water_info->>''name_1'' as off_water_name_1
  ,rst_off_water_info->>''name_2'' as off_water_name_2
  ,rst_off_water_info->>''name_3'' as off_water_name_3
  ,rst_off_water_info->>''name_4'' as off_water_name_4
  ,rst_off_water_info->>''name_5'' as off_water_name_5
  ,CAST(rst_off_water_info->>''weight_1'' AS DECIMAL) as off_water_weight_1
  ,CAST(rst_off_water_info->>''weight_2'' AS DECIMAL) as off_water_weight_2
  ,CAST(rst_off_water_info->>''weight_3'' AS DECIMAL) as off_water_weight_3
  ,CAST(rst_off_water_info->>''weight_4'' AS DECIMAL) as off_water_weight_4
  ,CAST(rst_off_water_info->>''weight_5'' AS DECIMAL) as off_water_weight_5
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
)

select
  *
	, @ordNo as ord_no_t
  ,coalesce(before_tare_weight_1, 0) + coalesce(before_tare_weight_2, 0)
    + coalesce(before_tare_weight_3, 0) + coalesce(before_tare_weight_4, 0)
    + coalesce(before_tare_weight_5, 0) + coalesce(before_wheel_chair_weight, 0) as before_tare_total
  ,coalesce(after_tare_weight_1, 0) + coalesce(after_tare_weight_2, 0)
    + coalesce(after_tare_weight_3, 0) + coalesce(after_tare_weight_4, 0)
    + coalesce(after_tare_weight_5, 0) + coalesce(after_wheel_chair_weight, 0) as after_tare_total
  ,coalesce(off_water_weight_1, 0) + coalesce(off_water_weight_2, 0)
    + coalesce(off_water_weight_3, 0) + coalesce(off_water_weight_4, 0) + coalesce(off_water_weight_5, 0) as off_water_total
from
  tmp

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
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：除水情報/風袋・除水補正 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (176, 'WITH DATA AS (

with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)
, oxygen_tbl as
(
  select
    *
    ,(rti->>''occur_date'')::timestamp as occur_date
    ,date_trunc(''minute'', (rti->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp1
  where
    rti->>''treat_class'' = ''3''
)

select
	@ordNo as ord_no_t,
  sum(CAST(rti->>''oxygen_amount'' AS DECIMAL)) as total_amount
from
  oxygen_tbl
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
	', 2, '[{"preview": "16", "can_calc": "1", "data_code": "total_amount", "data_name": "吸入総量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入総量", "field_name": "total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：酸素吸入総量 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
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
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
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
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
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
left join ord_material_save as save on (save.supplies_base_no = A.ord_no and A.facility_cd = save.facility_cd and A.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'')
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
	', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "strnig", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (206, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
fncd AS ( SELECT facility_cd FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) LIMIT 1 ),
dz AS ( SELECT * FROM mst_dialyzer mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ) SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
NAME,
code,
kur_cd,
kur_name,
SUM ( Amount ) AS amount,
unit,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		COALESCE ( eqc.class_name, '''' ) AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4
			FROM
				om
				INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
				AND md.class_cd IN ( @medIds )
				LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--抗凝固剤
			SELECT
				10 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CEIL (
					(
						( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
							) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
						) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						INNER JOIN mdx ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
						CROSS JOIN LATERAL json_array_elements ( mdx.mix_info :: json ) mix_info1
						INNER JOIN md ON TO_NUMBER( mix_info1->> ''cd'', ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CAST(save.ind_rst_value AS DECIMAL)  AS Amount,
						COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.ind_rst_class = ''1''
									and save.supplies_class in (''12'', ''20'')
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--医材
					SELECT
						12 AS disp_order,
						om.treat_date,
						kr.kur_cd,
						COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
						COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
						om.pat_id,
					CASE

							WHEN eqc.class_name IS NULL THEN
							''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
						END AS kind,
						eq.equipment_name AS NAME,
						eq.equipment_cd AS code,
						CAST(save.ind_rst_value  AS DECIMAL)  AS Amount,
						COALESCE ( eq.unit, '''' ) AS Unit,
						eq.in_hospital_cd_1,
						eq.in_hospital_cd_2,
						eq.in_hospital_cd_3,
						eq.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
						INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
						AND eq.class_cd IN ( @eqIds )
						LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
					) AS EquipmentList
				GROUP BY
					treat_date,
					kind,
					NAME,
					code,
					kur_cd,
					kur_name,
					Unit,
					bed_name,
					pat_id,
					pat_id1,
					disp_order,
					in_hospital_cd_1,
					in_hospital_cd_2,
					in_hospital_cd_3,
					in_hospital_cd_4
				ORDER BY
					disp_order,
					kind,
					code,
					NAME,
					kur_cd,
					kur_name,
				bed_name,
	pat_id;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(器材)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (207, 'SELECT
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kur_cd,
	kur_name,
	bed_name,
	pat_id,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	pat_id AS pat_id_to_name
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		case when dz.model_number is not null then ''ダイアライザ'' else null END AS kind,
		dz.model_number AS NAME,
		case when dz.model_number is not null then 1 else null END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_dialyzer AS dz ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''9999999999'' ) = dz.dialyzer_cd
			AND dz.is_del = ''0''
			AND dz.is_disp = ''1''
		)
		AND dz.dialyzer_cd IN (@diaIds)
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''  AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' AND eqc.class_cd IN (@eqIds))
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS decimal)  AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_medicine AS md ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''9999999999'' ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL)  AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN mst_medicine AS md ON (
			TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''9999999999'' ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}''  AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
				) * md.unit_converted_amount_second
			) AS Amount,
			COALESCE ( md.unit_second, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN mst_medicine AS md ON (
				TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''9999999999'' ) = md.medicine_cd
				AND md.is_del = ''0''
				AND md.is_disp = ''1''
				AND md.class_cd IN ( @medIds )
			)
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
			AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--抗凝固剤調製薬剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		(
						COALESCE (
							CEIL (
								(
									( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) /
								CASE

										WHEN md.unit_converted_amount IS NULL
										OR md.unit_converted_amount = 0 THEN
											1 ELSE md.unit_converted_amount
										END
											) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
										),
										( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) )
									) * CAST( mmxd ->> ''amount'' AS DECIMAL)
								) AS Amount,

			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
			CROSS JOIN LATERAL json_array_elements ( mdx.mix_info :: json ) mmxd
			LEFT OUTER JOIN mst_medicine AS md ON md.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
			AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--投薬
		SELECT
			11 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END AS kind,
			md.medicine_name AS NAME,
			CAST( save.receipt_value  AS DECIMAL) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''12''
									and save.ind_rst_class = ''1'')
			INNER JOIN mst_medicine AS md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0'' UNION ALL--投薬調製薬剤
		SELECT
			11 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END AS kind,
			md.medicine_name AS NAME,
			CAST( save.receipt_value  AS DECIMAL) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''20''
									and save.ind_rst_class = ''1'')
			INNER JOIN mst_medicine AS md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0'' UNION ALL--医材
		SELECT
			12 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END AS kind,
			eq.equipment_name AS NAME,
			CAST( save.receipt_value  AS DECIMAL) AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
			INNER JOIN mst_equipment AS eq ON TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd  AND eq.class_cd IN (@eqIds)
			LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
		) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
	disp_order,
	kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件(分解)", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10, 'SELECT
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kur_cd,
	kur_name,
	bed_name,
	pat_id,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	pat_id AS pat_id_to_name
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		case when dz.model_number is not null then ''ダイアライザ'' else null END AS kind,
		dz.model_number AS NAME,
		case when dz.model_number is not null then 1 else null END AS Amount,
		''''  AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''01''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_dialyzer AS dz ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = dz.dialyzer_cd
			AND dz.is_del = ''0''
			AND dz.is_disp = ''1''
		)
		AND dz.dialyzer_cd IN (@diaIds)
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
 UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''02''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''  AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''03''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''04''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''06''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' AND eqc.class_cd IN (@eqIds))
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''07''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''05''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END  AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''00''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_equipment AS eq ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN (@eqIds)
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		CEIL(cast( save.receipt_value  AS DECIMAL)  )  AS Amount,
		COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''08''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_medicine AS md ON (
			cast( save.supplies_cd AS DECIMAL) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		cast( save.receipt_value as DECIMAL)  AS Amount,
		COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		ord_main AS om
		INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''09''
									and save.ind_rst_class = ''1'')
		INNER JOIN mst_medicine AS md ON (
			TO_NUMBER( save.supplies_cd, ''9999999999'' ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
		UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		md.medicine_name AS NAME,
		CEIL (
			(
				(cast(save.ind_rst_value  as DECIMAL)) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
				) * md.unit_converted_amount_second
			) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''10''
									and save.ind_rst_class = ''1'')
			INNER JOIN mst_medicine AS md ON (
				TO_NUMBER( save.supplies_cd, ''9999999999'' ) = md.medicine_cd
				AND md.is_del = ''0''
				AND md.is_disp = ''1''
				AND md.class_cd IN ( @medIds )
			)
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
	UNION ALL--抗凝固剤調製薬剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		kr.kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END  AS kind,
		mdx.medicine_mix_name AS NAME,
		cast( save.ind_rst_value  as DECIMAL ) AS Amount,
			COALESCE (mdx.unit, '''' ) AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''0''
									and save.supplies_class = ''17''
									and save.ind_rst_class = ''1'')
			INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( save.supplies_cd, ''999999999999'' )
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( mdx.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
		UNION ALL--投薬
		SELECT
			11 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END AS kind,
			md.medicine_name AS NAME,
			CAST ( COALESCE(regexp_replace(save.receipt_value, ''[^0-9.]+'', '''', ''g''),''0'') AS DECIMAL ) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''12''
									and save.ind_rst_class = ''1'')
			INNER JOIN mst_medicine AS md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0'' UNION ALL--投薬調製薬剤
		SELECT
			11 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN mdc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( mdc.class_name, '''' ) END AS kind,
			md.medicine_mix_name AS NAME,
			CAST ( COALESCE(regexp_replace(save.receipt_value, ''[^0-9.]+'', '''', ''g''),''0'') AS DECIMAL ) AS Amount,
			COALESCE (md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on (om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''13''
									and save.ind_rst_class = ''1'')
			LEFT JOIN mst_medicine_mix as md ON (TO_NUMBER( save.medicine_mix_cd, ''9999999999'' ) = md.medicine_mix_cd AND md.is_del = ''0''
						AND md.is_disp = ''1'' )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0'' UNION ALL--医材
		SELECT
			12 AS disp_order,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE WHEN eqc.class_name IS NULL THEN ''未分類'' ELSE COALESCE ( eqc.class_name, '''' ) END AS kind,
			eq.equipment_name AS NAME,
			CAST ( COALESCE(regexp_replace(save.receipt_value, ''[^0-9.]+'', '''', ''g''),''0'') AS DECIMAL ) AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			ord_main AS om
			INNER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
			INNER JOIN mst_equipment AS eq ON TO_NUMBER( save.supplies_cd, ''9999999999'' ) = eq.equipment_cd  AND eq.class_cd IN (@eqIds)
			LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
			LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
			LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.is_del = ''0''
		) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
	disp_order,
	kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
