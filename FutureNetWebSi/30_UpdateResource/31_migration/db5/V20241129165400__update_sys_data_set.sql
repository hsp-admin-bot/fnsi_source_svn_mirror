DELETE FROM "ntss"."sys_data_set" where sql_cd in (3, 8, 74, 78, 79, 82, 83, 93, 97, 98, 100, 104, 105, 115, 116, 117, 133, 160, 162, 163, 165, 166, 167, 168, 169, 170, 172, 173, 175, 176, 177, 179, 187, 188, 190, 199, 200, 225);
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
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no) and b.facility_cd = mni_monitor.facility_cd
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
		   SELECT
    g.*,tmp.*,
    before_bp_high :: TEXT || ''/'' || before_bp_low :: TEXT || ''/'' || before_bp_ave || ''('' || before_pulse :: TEXT || '')'' AS before_bp_summary,
    after_bp_high :: TEXT || ''/'' || after_bp_low :: TEXT || ''/'' || after_bp_ave || ''('' || after_pulse :: TEXT || '')'' AS after_bp_summary
FROM
    tmp
left join
	g
on tmp.ord_no=g.ordnob', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "iap_rt", "data_name": "IAP ratio", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "iap_rt", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "sttc_vns_prssr", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "sttc_vns_prssr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報/血圧情報 @ordNo 使用', '2020-03-31 23:59:59', '2024-07-31 19:50:37.249', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8, 'WITH ord AS (
    SELECT
       treat_date,
       facility_cd,
        ord_no,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
	AND ord_no in ( @ordNos )

    AND rst_dialysis_state <> ''0''
), b AS (
    select ord_main.* from ord_main
     where 	rst_dialysis_state between ''1'' and ''5''
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

select g.*,a.* from (select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ord_no,
  medi ->> ''cd'' as medi_cd,
  medi ->> ''name'' as medi_name,
  medi ->> ''unit'' as medi_unit,
  medi ->> ''amount'' as medi_amount,
  medi ->> ''class_cd'' as medi_class_cd,
  case when  (medi ->> ''class_cd''):: TEXT = ''-1'' then ''未分類'' else medi ->> ''class_name'' end as medi_class_name,
  medi ->> ''class_type'' as medi_class_type,
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
  , medi->>''medicine_type'' as medicine_type
	,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.class_cd else mstMedicMix.class_cd end as medicine_class_cd
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4
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

	
  ,save.receipt_value as receipt_value
  ,mstMedic.unit_second as unit_second
  from
    ord
    left join mst_medicine_mix  as mstMedicMix  on (ord.medi ->> ''cd'' = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' )
    left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1''  )
    left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  )
    left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mstMedic.medicine_cd :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and supplies_class != ''20'')
  where
	ord.ord_no in ( @ordNos )

  and ord.is_del = ''0''
order by json_idx) a
left join g
on a.ord_no=g.ordnob
where a.medicine_class_cd IN ( @medIds );', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "袋", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬 @ordNo 使用', '2019-09-17 11:32:00', '2024-11-02 23:10:42.749', NULL);
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
		ord_no
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
	case when eqp.class_cd = ''-1'' then ''未分類'' else eqp_cls.class_name end as equip_class_name,
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
	on ord.ord_no=g.ordnob', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_start", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_start", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材　@ordNo使用', '2020-03-27 12:59:00', '2024-03-31 21:16:06.936', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (78, 'WITH DATA AS (
	with input_params_expand as
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
, pe_basicinfo_plus as
(
  select
		ord_main.ord_no
		,pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,treat_date
    ,case
      when rst_dialysis_state <> ''0'' then rst_kur_name
      else ind_kur_name
    end as linked_kur_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_bed_name
      else ind_bed_name
    end as linked_bed_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_treatment_name
      else ind_treatment_name
    end as linked_treatment_name
  from
    pat_event
    left outer join (select * from ord_main where is_del = ''0'') as ord_main
      on pat_event.ord_no = ord_main.ord_no
  where
    pat_event.is_del = ''0''
    and use_type = 2 and pat_event.ord_no = @ordNo
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
    input_param->>''format_class'' = ''9''
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
  ord_no as ord_no_t,
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''
  end as is_linked
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' as linked_treat_date
  ,linked_kur_name
  ,linked_bed_name
  ,linked_treatment_name
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
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

	', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "治療実績リンク有無", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "is_linked", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "linked_treat_date", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "linked_kur_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "linked_bed_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "linked_treatment_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク", "field_name": "linked_detail", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 治療実績リンク @ordNo 使用', '2020-03-27 23:59:59', '2024-06-12 22:45:26.416', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (79, 'WITH DATA AS (


	with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo_plus as
(
  select
    ord_main.ord_no as ord_no_t
	,pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,treat_date
    ,case
      when rst_dialysis_state <> ''0'' then rst_kur_name
      else ind_kur_name
    end as linked_kur_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_bed_name
      else ind_bed_name
    end as linked_bed_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_treatment_name
      else ind_treatment_name
    end as linked_treatment_name
  from
    pat_event
    left outer join (select * from ord_main where is_del = ''0'') as ord_main
      on pat_event.ord_no = ord_main.ord_no
  where
    pat_event.is_del = ''0''
    and use_type = 2 and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''9''
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
	ord_no_t
	,pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''
  end as is_linked
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' as linked_treat_date
  ,linked_kur_name
  ,linked_bed_name
  ,linked_treatment_name
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
	order  by   event_date, reg_date
	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			 ord_no = @ordNo
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
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
', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "治療実績リンク有無", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "is_linked", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_treat_date", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_kur_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_bed_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_treatment_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_detail", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  治療実績リンク @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', '2024-07-31 19:50:38.016', NULL);
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

	', 2, '[{"preview": "55.00", "can_calc": "0", "data_code": "dw1", "data_name": "DW（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight1", "data_name": "目標体重（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date1", "data_name": "透析予定日(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date1", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw2", "data_name": "DW（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight2", "data_name": "目標体重（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date2", "data_name": "透析予定日(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date2", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：体重情報(過去指示)　@ordNo使用', '2020-03-27 15:00:00', '2023-07-17 21:02:02.696', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (83, 'WITH DATA AS (


	select
  pm.device_set_info#>>''{"bp","dev","A","211"}'' as bp_dev_a_0211,--血圧警報点最高血圧上限
  pm.device_set_info#>>''{"bp","dev","A","212"}'' as bp_dev_a_0212,--血圧警報点最高血圧下限
  pm.device_set_info#>>''{"bp","dev","A","213"}'' as bp_dev_a_0213,--血圧警報点最低血圧上限
  pm.device_set_info#>>''{"bp","dev","A","214"}'' as bp_dev_a_0214,--血圧警報点最低血圧下限
  pm.device_set_info#>>''{"bp","dev","A","215"}'' as bp_dev_a_0215,--血圧警報点平均血圧上限
  pm.device_set_info#>>''{"bp","dev","A","216"}'' as bp_dev_a_0216,--血圧警報点平均血圧下限
  pm.device_set_info#>>''{"bp","dev","A","217"}'' as bp_dev_a_0217,--血圧警報点脈拍数上限
  pm.device_set_info#>>''{"bp","dev","A","218"}'' as bp_dev_a_0218,--血圧警報点脈拍数下限
  pm.device_set_info#>>''{"bp","dev","A","227"}'' as bp_dev_a_0227,--最高血圧上限警報_血液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","219"}'' as bp_dev_a_0219,--最高血圧上限警報_血液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","228"}'' as bp_dev_a_0228,--最高血圧下限警報_血液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","220"}'' as bp_dev_a_0220,--最高血圧下限警報_血液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","229"}'' as bp_dev_a_0229,--最高血圧上限警報_除水ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","221"}'' as bp_dev_a_0221,--最高血圧上限警報_除水ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","230"}'' as bp_dev_a_0230,--最高血圧下限警報_除水ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","222"}'' as bp_dev_a_0222,--最高血圧下限警報_除水ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","231"}'' as bp_dev_a_0231,--最高血圧上限警報_Na注入ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","223"}'' as bp_dev_a_0223,--最高血圧上限警報_Na注入ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","232"}'' as bp_dev_a_0232,--最高血圧下限警報_Na注入ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","224"}'' as bp_dev_a_0224,--最高血圧下限警報_Na注入ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","233"}'' as bp_dev_a_0233,--最高血圧上限警報_補液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","225"}'' as bp_dev_a_0225,--最高血圧上限警報_補液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","234"}'' as bp_dev_a_0234,--最高血圧下限警報_補液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","226"}'' as bp_dev_a_0226,--最高血圧下限警報_補液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","191"}'' as bp_dev_a_0191,--血圧カフ選択
  pm.device_set_info#>>''{"bp","dev","A","190"}'' as bp_dev_a_0190,--血圧自動測定間隔
  pm.device_set_info#>>''{"bp","dev","A","192"}'' as bp_dev_a_0192,--昇圧値
  pm.device_set_info#>>''{"bp","dev","A","193"}'' as bp_dev_a_0193,--昇圧方法選択
  pm.device_set_info#>>''{"bp","dev","A","195"}'' as bp_dev_a_0195,--血圧測定方法選択
  pm.device_set_info#>>''{"bp","dev","A","239"}'' as bp_dev_a_0239,--高速測定選択
  pm.device_set_info#>>''{"bp","dev","A","194"}'' as bp_dev_a_0194,--血圧連続測定動作選択
  pm.device_set_info#>>''{"bp","dev","A","235"}'' as bp_dev_a_0235,--警報連動測定開始時間
  pm.device_set_info#>>''{"bp","dev","A","236"}'' as bp_dev_a_0236,--治療条件連動測定時間
  pm.device_set_info#>>''{"bp","dev","A","237"}'' as bp_dev_a_0237,--静脈圧警報発生時の血圧測定
  pm.device_set_info#>>''{"bp","dev","A","238"}'' as bp_dev_a_0238,--血流量または除水速度変更時の血圧測定
  pm.device_set_info#>>''{"bv","dev","A","267"}'' as bv_dev_a_0267,--BV計使用選択
  pm.device_set_info#>>''{"bv","dev","A","260"}'' as bv_dev_a_0260,--⊿BV低下警報点1
  pm.device_set_info#>>''{"bv","dev","A","261"}'' as bv_dev_a_0261,--⊿BV低下警報点2
  pm.device_set_info#>>''{"bv","dev","A","262"}'' as bv_dev_a_0262,--⊿BV変化率警報点
  pm.device_set_info#>>''{"bv","dev","A","277"}'' as bv_dev_a_0277,--⊿BV除水低下速度
  pm.device_set_info#>>''{"bv","dev","A","278"}'' as bv_dev_a_0278,--⊿BV除水低下遅延時間
  pm.device_set_info#>>''{"bv","dev","A","258"}'' as bv_dev_a_0258,--アクセス再循環測定使用選択
  pm.device_set_info#>>''{"bv","dev","A","259"}'' as bv_dev_a_0259,--アクセス再循環自動測定1
  pm.device_set_info#>>''{"bv","dev","A","263"}'' as bv_dev_a_0263,--アクセス再循環自動測定2
  pm.device_set_info#>>''{"bv","dev","A","264"}'' as bv_dev_a_0264,--アクセス再循環自動測定3
  pm.device_set_info#>>''{"bv","dev","A","265"}'' as bv_dev_a_0265,--アクセス再循環自動測定4
  pm.device_set_info#>>''{"bv","dev","A","266"}'' as bv_dev_a_0266,--アクセス再循環自動測定5
  pm.device_set_info#>>''{"bv","dev","A","281"}'' as bv_dev_a_0281,--アクセス再循環再循環率報知
  pm.device_set_info#>>''{"cpro","dev","A","252"}'' as cpro_dev_a_0252,--Ｂ液濃度プログラム自動設定警報幅上限
  pm.device_set_info#>>''{"cpro","dev","A","253"}'' as cpro_dev_a_0253,--Ｂ液濃度プログラム自動設定警報幅下限
  pm.device_set_info#>>''{"cpro","dev","A","250"}'' as cpro_dev_a_0250,--透析液濃度プログラム自動設定警報幅上限
  pm.device_set_info#>>''{"cpro","dev","A","251"}'' as cpro_dev_a_0251,--透析液濃度プログラム自動設定警報幅下限
  pm.device_set_info#>>''{"dfas","dev","A","339"}'' as dfas_dev_a_0339,--脱血方法選択
  pm.device_set_info#>>''{"dfas","dev","A","333"}'' as dfas_dev_a_0333,--脱血速度
  pm.device_set_info#>>''{"dfas","dev","A","331"}'' as dfas_dev_a_0331,--同時脱血_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","334"}'' as dfas_dev_a_0334,--片側脱血(除水なし)_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","338"}'' as dfas_dev_a_0338,--片側脱血（除水あり）_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","332"}'' as dfas_dev_a_0332,--片側脱血への切替え透析液圧
  pm.device_set_info#>>''{"dfas","dev","A","373"}'' as dfas_dev_a_0373,--静脈側返血速度
  pm.device_set_info#>>''{"dfas","dev","A","374"}'' as dfas_dev_a_0374,--静脈側最大返血量
  pm.device_set_info#>>''{"dfas","dev","A","377"}'' as dfas_dev_a_0377,--静脈側返血_血液判別器使用選択
  pm.device_set_info#>>''{"dfas","dev","A","270"}'' as dfas_dev_a_0270,--動脈側返血使用選択
  pm.device_set_info#>>''{"dfas","dev","A","376"}'' as dfas_dev_a_0376,--動脈側最大返血量
  pm.device_set_info#>>''{"dfas","dev","A","378"}'' as dfas_dev_a_0378,--動脈側返血_血液判別器使用選択
  pm.device_set_info#>>''{"dfas","dev","A","335"}'' as dfas_dev_a_0335,--治療開始時_血液ポンプ速度
  pm.device_set_info#>>''{"dfas","dev","B","36"}'' as dfas_dev_b_0036,--治療開始時_血流量使用有無
  pm.device_set_info#>>''{"dfas","pat","B","1"}'' as dfas_pat_b_0001,--IPラインプライミング使用選択
  pm.device_set_info#>>''{"dfas","pat","B","5"}'' as dfas_pat_b_0005,--中空糸_プライミング時のBP速度
  pm.device_set_info#>>''{"dfas","pat","B","7"}'' as dfas_pat_b_0007,--中空糸_送液最大時間
  pm.device_set_info#>>''{"dfas","pat","B","8"}'' as dfas_pat_b_0008,--中空糸_回路内洗浄送液量
  pm.device_set_info#>>''{"dfas","pat","B","9"}'' as dfas_pat_b_0009,--中空糸_気泡抜き動作実行回数
  pm.device_set_info#>>''{"dfas","pat","B","10"}'' as dfas_pat_b_0010,--中空糸_気泡抜き圧力上限
  pm.device_set_info#>>''{"dfas","pat","B","59"}'' as dfas_pat_b_0059,--積層_プライミング時のBP速度
  pm.device_set_info#>>''{"dfas","pat","B","54"}'' as dfas_pat_b_0054,--積層_送液最大時間
  pm.device_set_info#>>''{"dfas","pat","B","55"}'' as dfas_pat_b_0055,--積層_回路内洗浄送液量
  pm.device_set_info#>>''{"dfas","pat","B","56"}'' as dfas_pat_b_0056,--積層_気泡抜き動作実行回数
  pm.device_set_info#>>''{"dfas","pat","B","57"}'' as dfas_pat_b_0057,--積層_気泡抜き圧力上限
  pm.device_set_info#>>''{"dfas","pat","B","58"}'' as dfas_pat_b_0058,--積層_除水ポンプ速度
  pm.device_set_info#>>''{"ecum","dev","A","16"}'' as ecum_dev_a_0016,--ECUM選択
  pm.device_set_info#>>''{"ecum","dev","A","17"}'' as ecum_dev_a_0017,--ECUM量
  pm.device_set_info#>>''{"ecum","dev","A","18"}'' as ecum_dev_a_0018,--ECUM時間
  pm.device_set_info#>>''{"ecum","dev","A","19"}'' as ecum_dev_a_0019,--ECUM時間カウント選択
  pm.device_set_info#>>''{"ope","dev","A","179"}'' as ope_dev_a_0179,--血流量設定最大値
  pm.device_set_info#>>''{"ope","dev","A","181"}'' as ope_dev_a_0181,--除水速度制限
  pm.device_set_info#>>''{"ope","dev","A","38"}'' as ope_dev_a_0038,--動脈側気泡検出器
  pm.device_set_info#>>''{"ope","dev","A","21"}'' as ope_dev_a_0021,--除水計算時間
  pm.device_set_info#>>''{"ope","dev","A","22"}'' as ope_dev_a_0022,--除水計算優先項目
  pm.device_set_info#>>''{"ope","dev","A","39"}'' as ope_dev_a_0039,--除水開始遅延時間
  pm.device_set_info#>>''{"ope","dev","A","182"}'' as ope_dev_a_0182,--透析液温度操作範囲上限
  pm.device_set_info#>>''{"ope","dev","A","183"}'' as ope_dev_a_0183,--透析液温度操作範囲下限
  pm.device_set_info#>>''{"ope","dev","A","268"}'' as ope_dev_a_0268,--透析液流量　設定方法
  pm.device_set_info#>>''{"ope","dev","A","269"}'' as ope_dev_a_0269,--透析液流量　比率設定
  pm.device_set_info#>>''{"ope","dev","A","24"}'' as ope_dev_a_0024,--シングルニードル切替圧上限
  pm.device_set_info#>>''{"ope","dev","A","25"}'' as ope_dev_a_0025,--シングルニードル切替圧下限
  pm.device_set_info#>>''{"ope","dev","A","241"}'' as ope_dev_a_0241,--TMPゼロ補正
  pm.device_set_info#>>''{"ope","dev","A","168"}'' as ope_dev_a_0168,--HD補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","169"}'' as ope_dev_a_0169,--HD補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","171"}'' as ope_dev_a_0171,--ECUM補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","172"}'' as ope_dev_a_0172,--ECUM補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","174"}'' as ope_dev_a_0174,--HDF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","175"}'' as ope_dev_a_0175,--HDF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","177"}'' as ope_dev_a_0177,--HF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","178"}'' as ope_dev_a_0178,--HF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","391"}'' as ope_dev_a_0391,--OHDF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","392"}'' as ope_dev_a_0392,--OHDF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","394"}'' as ope_dev_a_0394,--OHF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","395"}'' as ope_dev_a_0395,--OHF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","383"}'' as ope_dev_a_0383,--補液量制限
  pm.device_set_info#>>''{"ope","dev","A","389"}'' as ope_dev_a_0389,--補液計算優先項目
  pm.device_set_info#>>''{"ope","dev","A","379"}'' as ope_dev_a_0379,--補液比率（前補液）
  pm.device_set_info#>>''{"ope","dev","A","398"}'' as ope_dev_a_0398,--補液開始遅延時間
  pm.device_set_info#>>''{"ope","dev","A","369"}'' as ope_dev_a_0369,--DP=Qd+Qs(補液速度加算)
  pm.device_set_info#>>''{"ope","dev","A","90"}'' as ope_dev_a_0090,--濾過率（前補液）
  pm.device_set_info#>>''{"ope","dev","A","91"}'' as ope_dev_a_0091,--ヘマトクリット（Ht）
  pm.device_set_info#>>''{"ope","dev","A","92"}'' as ope_dev_a_0092,--総タンパク（TP）
  pm.device_set_info#>>''{"ope","dev","A","336"}'' as ope_dev_a_0336,--緊急補液速度
  pm.device_set_info#>>''{"ope","dev","A","337"}'' as ope_dev_a_0337,--緊急補液量
  pm.device_set_info#>>''{"ope","dev","A","185"}'' as ope_dev_a_0185,--HDF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","186"}'' as ope_dev_a_0186,--HF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","396"}'' as ope_dev_a_0396,--OHDF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","397"}'' as ope_dev_a_0397,--OHF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","384"}'' as ope_dev_a_0384,--AFBF補液比率使用選択
  pm.device_set_info#>>''{"ope","dev","A","385"}'' as ope_dev_a_0385,--AFBF補液比率
  pm.device_set_info#>>''{"ope","dev","A","386"}'' as ope_dev_a_0386,--AFBF速度操作範囲上限
  pm.device_set_info#>>''{"ope","dev","A","387"}'' as ope_dev_a_0387,--AFBF速度操作範囲下限
  pm.device_set_info#>>''{"ope","dev","A","472"}'' as ope_dev_a_0472,--TMP閾値　速度低下,
  pm.device_set_info#>>''{"ope","dev","A","473"}'' as ope_dev_a_0473,--TMP閾値　速度復帰,
  pm.device_set_info#>>''{"ope","dev","A","474"}'' as ope_dev_a_0474,--速度変化率　速度低下,
  pm.device_set_info#>>''{"ope","dev","A","475"}'' as ope_dev_a_0475,--速度変化率　速度復帰
  pm.device_set_info#>>''{"ope","dev","B","37"}'' as ope_dev_b_0037,--HD+補液補正警報上限値
  pm.device_set_info#>>''{"ope","dev","B","38"}'' as ope_dev_b_0038,--HD+補液補正警報下限値
  pm.device_set_info#>>''{"ope","dev","B","39"}'' as ope_dev_b_0039,--補液比率（後補液）
  pm.device_set_info#>>''{"ope","dev","B","40"}'' as ope_dev_b_0040,--濾過率（後補液）
  pm.device_set_info#>>''{"ope","dev","B","30"}'' as ope_dev_b_0030,--HD+補液速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","B","31"}'' as ope_dev_b_0031,--HDF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","32"}'' as ope_dev_b_0032,--HF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","33"}'' as ope_dev_b_0033,--HD+補液速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","34"}'' as ope_dev_b_0034,--OHDF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","35"}'' as ope_dev_b_0035,--OHF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","C","91"}'' as ope_dev_c_0091,--ヘマトクリット（Ht）
  pm.device_set_info#>>''{"ope","dev","C","92"}'' as ope_dev_c_0092,--総タンパク（TP）
  pm.device_set_info#>>''{"pri","dev","A","370"}'' as pri_dev_a_0370,--自動回収_使用液量
  pm.device_set_info#>>''{"pri","dev","A","371"}'' as pri_dev_a_0371,--自動回収_流速
  pm.device_set_info#>>''{"pri","dev","A","372"}'' as pri_dev_a_0372,--自動回収_血液判別器による終了選択
  pm.device_set_info#>>''{"pri","pat","A","219"}'' as pri_pat_a_0219,--プライミング補助動脈充填液量
  pm.device_set_info#>>''{"pri","pat","A","220"}'' as pri_pat_a_0220,--プライミング補助動脈充填流速
  pm.device_set_info#>>''{"pri","pat","A","225"}'' as pri_pat_a_0225,--プライミング補助動脈充填後継続の有無
  pm.device_set_info#>>''{"pri","pat","A","221"}'' as pri_pat_a_0221,--プライミング補助静脈充填液量
  pm.device_set_info#>>''{"pri","pat","A","222"}'' as pri_pat_a_0222,--プライミング補助静脈充填流速
  pm.device_set_info#>>''{"pri","pat","A","226"}'' as pri_pat_a_0226,--プライミング補助静脈充填後継続の有無
  pm.device_set_info#>>''{"pri","pat","A","223"}'' as pri_pat_a_0223,--プライミング補助気泡抜き液量
  pm.device_set_info#>>''{"pri","pat","A","224"}'' as pri_pat_a_0224,--プライミング補助気泡抜き流速
  pm.device_set_info#>>''{"pri","pat","A","227"}'' as pri_pat_a_0227,--プライミング補助気泡抜き間欠動作選択
  pm.device_set_info#>>''{"pri","pat","A","228"}'' as pri_pat_a_0228,--プライミング補助液交換量
  pm.device_set_info#>>''{"pri","pat","A","229"}'' as pri_pat_a_0229,--プライミング補助間欠動作動作時間
  pm.device_set_info#>>''{"pri","pat","A","230"}'' as pri_pat_a_0230,--プライミング補助間欠動作停止時間
  pm.device_set_info#>>''{"pri","pat","A","232"}'' as pri_pat_a_0232,--自動プライミング落差時間
  pm.device_set_info#>>''{"pri","pat","A","238"}'' as pri_pat_a_0238,--自動プライミング総量
  pm.device_set_info#>>''{"pri","pat","A","231"}'' as pri_pat_a_0231,--自動プライミング開始時間
  pm.device_set_info#>>''{"pri","pat","A","233"}'' as pri_pat_a_0233,--自動プライミング送液液量
  pm.device_set_info#>>''{"pri","pat","A","234"}'' as pri_pat_a_0234,--自動プライミング送液流速1回目
  pm.device_set_info#>>''{"pri","pat","A","235"}'' as pri_pat_a_0235,--自動プライミング送液流速2回目以降
  pm.device_set_info#>>''{"pri","pat","A","236"}'' as pri_pat_a_0236,--自動プライミング循環流速
  pm.device_set_info#>>''{"pri","pat","A","237"}'' as pri_pat_a_0237,--自動プライミング循環時間
  pm.device_set_info#>>''{"pri","pat","B","51"}'' as pri_pat_b_0051,--オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  pm.device_set_info#>>''{"pri","pat","B","32"}'' as pri_pat_b_0032,--オンラインプライミング_動脈チャンバ液面作成時間_前補液
  pm.device_set_info#>>''{"pri","pat","B","52"}'' as pri_pat_b_0052,--オンラインプライミング_動脈チャンバ液面作成時間_後補液
  pm.device_set_info#>>''{"pri","pat","B","33"}'' as pri_pat_b_0033,--オンラインプライミング_循環洗浄時間_前補液
  pm.device_set_info#>>''{"pri","pat","B","53"}'' as pri_pat_b_0053,--オンラインプライミング_循環洗浄時間_後補液
  pm.device_set_info#>>''{"war","dev","A","240"}'' as war_dev_a_0240,--TMP監視モード
  pm.device_set_info#>>''{"war","dev","A","100"}'' as war_dev_a_0100,--HD/ECUM静脈圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","101"}'' as war_dev_a_0101,--HD/ECUM静脈圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","102"}'' as war_dev_a_0102,--HD/ECUM静脈圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","103"}'' as war_dev_a_0103,--HD/ECUM静脈圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","104"}'' as war_dev_a_0104,--HD/ECUM静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","105"}'' as war_dev_a_0105,--HD/ECUM静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","152"}'' as war_dev_a_0152,--HD/ECUMダイアライザ入口圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","153"}'' as war_dev_a_0153,--HD/ECUMダイアライザ入口圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","154"}'' as war_dev_a_0154,--HD/ECUMダイアライザ入口圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","155"}'' as war_dev_a_0155,--HD/ECUMダイアライザ入口圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","156"}'' as war_dev_a_0156,--HD/ECUMダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","157"}'' as war_dev_a_0157,--HD/ECUMダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","112"}'' as war_dev_a_0112,--HD/ECUM液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","113"}'' as war_dev_a_0113,--HD/ECUM液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","114"}'' as war_dev_a_0114,--HD/ECUM液圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","115"}'' as war_dev_a_0115,--HD/ECUM液圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","116"}'' as war_dev_a_0116,--HD/ECUM液圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","117"}'' as war_dev_a_0117,--HD/ECUM液圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","128"}'' as war_dev_a_0128,--HD/ECUMTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","129"}'' as war_dev_a_0129,--HD/ECUMTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","130"}'' as war_dev_a_0130,--HD/ECUMTMP自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","131"}'' as war_dev_a_0131,--HD/ECUMTMP自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","132"}'' as war_dev_a_0132,--HD/ECUMTMP固定警報上限
  pm.device_set_info#>>''{"war","dev","A","133"}'' as war_dev_a_0133,--HD/ECUMTMP固定警報下限
  pm.device_set_info#>>''{"war","dev","A","126"}'' as war_dev_a_0126,--HD/ECUMTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","127"}'' as war_dev_a_0127,--HD/ECUMTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","146"}'' as war_dev_a_0146,--HD/ECUMダイアライザ差圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","147"}'' as war_dev_a_0147,--HD/ECUMダイアライザ差圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","148"}'' as war_dev_a_0148,--HD/ECUMダイアライザ差圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","149"}'' as war_dev_a_0149,--HD/ECUMダイアライザ差圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","106"}'' as war_dev_a_0106,--HDF/HF静脈圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","107"}'' as war_dev_a_0107,--HDF/HF静脈圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","158"}'' as war_dev_a_0158,--HDF/HFダイアライザ入口圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","159"}'' as war_dev_a_0159,--HDF/HFダイアライザ入口圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","118"}'' as war_dev_a_0118,--HDF/HF液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","119"}'' as war_dev_a_0119,--HDF/HF液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","136"}'' as war_dev_a_0136,--HDF/HFTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","137"}'' as war_dev_a_0137,--HDF/HFTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","134"}'' as war_dev_a_0134,--HDF/HFTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","135"}'' as war_dev_a_0135,--HDF/HFTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","150"}'' as war_dev_a_0150,--HDF/HFダイアライザ差圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","151"}'' as war_dev_a_0151,--HDF/HFダイアライザ差圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","110"}'' as war_dev_a_0110,--SN静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","111"}'' as war_dev_a_0111,--SN静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","162"}'' as war_dev_a_0162,--SNダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","163"}'' as war_dev_a_0163,--SNダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","120"}'' as war_dev_a_0120,--SN液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","121"}'' as war_dev_a_0121,--SN液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","122"}'' as war_dev_a_0122,--SN液圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","123"}'' as war_dev_a_0123,--SN液圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","124"}'' as war_dev_a_0124,--SN液圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","125"}'' as war_dev_a_0125,--SN液圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","140"}'' as war_dev_a_0140,--SNTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","141"}'' as war_dev_a_0141,--SNTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","142"}'' as war_dev_a_0142,--SNTMP自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","143"}'' as war_dev_a_0143,--SNTMP自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","144"}'' as war_dev_a_0144,--SNTMP固定警報上限
  pm.device_set_info#>>''{"war","dev","A","145"}'' as war_dev_a_0145,--SNTMP固定警報下限
  pm.device_set_info#>>''{"war","dev","A","138"}'' as war_dev_a_0138,--SNTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","139"}'' as war_dev_a_0139,--SNTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","108"}'' as war_dev_a_0108,--準備回収静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","109"}'' as war_dev_a_0109,--準備回収静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","160"}'' as war_dev_a_0160,--準備回収ダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","161"}'' as war_dev_a_0161,--準備回収ダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","254"}'' as war_dev_a_0254,--Na濃度自動警報幅上限値
  pm.device_set_info#>>''{"war","dev","A","255"}'' as war_dev_a_0255,--Na濃度自動警報幅下限値
  pm.device_set_info#>>''{"war","dev","A","256"}'' as war_dev_a_0256,--Na濃度固定警報幅上限値
  pm.device_set_info#>>''{"war","dev","A","257"}'' as war_dev_a_0257,--Na濃度固定警報幅下限値
  pm.device_set_info#>>''{"war","dev","A","242"}'' as war_dev_a_0242,--静脈圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","243"}'' as war_dev_a_0243,--ダイアライザー血液入口圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","244"}'' as war_dev_a_0244,--透析液圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","245"}'' as war_dev_a_0245,--ＴＭＰ自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","246"}'' as war_dev_a_0246,--差圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","247"}'' as war_dev_a_0247,--Ｎａ濃度自動設定警報監視有無
  pm.device_set_info#>>''{"lap","dev","A","468"}'' as lap_dev_a_0468,--VA確認報知基準値(静的静脈圧)
  pm.device_set_info#>>''{"lap","dev","A","469"}'' as lap_dev_a_0469,--VA確認報知基準値(アクセス内圧力比率)
  pm.device_set_info#>>''{"lap","dev","A","470"}'' as lap_dev_a_0470,--静的静脈圧記録 自動実施選択
  pm.device_set_info#>>''{"lap","dev","A","471"}'' as lap_dev_a_0471,--血圧測定 自動実施選択
  om.ind_device_set_info#>>''{"ihdf","dev","A","201"}'' as ihdf_dev_a_0201,--I-HDF_補液速度
  om.ind_device_set_info#>>''{"ihdf","dev","A","203"}'' as ihdf_dev_a_0203,--I-HDF_補液開始時間
  om.ind_device_set_info#>>''{"ihdf","dev","A","200"}'' as ihdf_dev_a_0200,--I-HDF_補液量設定
  om.ind_device_set_info#>>''{"ihdf","dev","A","204"}'' as ihdf_dev_a_0204,--I-HDF_除水再開時間
  om.ind_device_set_info#>>''{"ihdf","dev","A","202"}'' as ihdf_dev_a_0202,--I-HDF_補液周期
  om.ind_device_set_info#>>''{"ihdf","dev","A","205"}'' as ihdf_dev_a_0205,--I-HDF_総補液量上限
  om.ind_device_set_info#>>''{"ihdf","dev","A","432"}'' as ihdf_dev_a_0432,--I-HDFプログラム使用選択
  om.ind_device_set_info#>>''{"ihdf","dev","A","433"}'' as ihdf_dev_a_0433,--予定補液回数
  om.ind_device_set_info#>>''{"ihdf","dev","A","434"}'' as ihdf_dev_a_0434,--補液バランス制限
  om.ind_device_set_info#>>''{"ihdf","dev","A","435"}'' as ihdf_dev_a_0435,--補液量01
  om.ind_device_set_info#>>''{"ihdf","dev","A","436"}'' as ihdf_dev_a_0436,--補液量02
  om.ind_device_set_info#>>''{"ihdf","dev","A","437"}'' as ihdf_dev_a_0437,--補液量03
  om.ind_device_set_info#>>''{"ihdf","dev","A","438"}'' as ihdf_dev_a_0438,--補液量04
  om.ind_device_set_info#>>''{"ihdf","dev","A","439"}'' as ihdf_dev_a_0439,--補液量05
  om.ind_device_set_info#>>''{"ihdf","dev","A","440"}'' as ihdf_dev_a_0440,--補液量06
  om.ind_device_set_info#>>''{"ihdf","dev","A","441"}'' as ihdf_dev_a_0441,--補液量07
  om.ind_device_set_info#>>''{"ihdf","dev","A","442"}'' as ihdf_dev_a_0442,--補液量08
  om.ind_device_set_info#>>''{"ihdf","dev","A","443"}'' as ihdf_dev_a_0443,--補液量09
  om.ind_device_set_info#>>''{"ihdf","dev","A","444"}'' as ihdf_dev_a_0444,--補液量10
  om.ind_device_set_info#>>''{"ihdf","dev","A","445"}'' as ihdf_dev_a_0445,--補液量11
  om.ind_device_set_info#>>''{"ihdf","dev","A","446"}'' as ihdf_dev_a_0446,--補液量12
  om.ind_device_set_info#>>''{"ihdf","dev","A","447"}'' as ihdf_dev_a_0447,--補液量13
  om.ind_device_set_info#>>''{"ihdf","dev","A","448"}'' as ihdf_dev_a_0448,--補液量14
  om.ind_device_set_info#>>''{"ihdf","dev","A","449"}'' as ihdf_dev_a_0449,--補液量15
  om.ind_device_set_info#>>''{"ihdf","dev","A","450"}'' as ihdf_dev_a_0450,--補液量16
  om.ind_device_set_info#>>''{"ihdf","dev","A","451"}'' as ihdf_dev_a_0451,--回収量01
  om.ind_device_set_info#>>''{"ihdf","dev","A","452"}'' as ihdf_dev_a_0452,--回収量02
  om.ind_device_set_info#>>''{"ihdf","dev","A","453"}'' as ihdf_dev_a_0453,--回収量03
  om.ind_device_set_info#>>''{"ihdf","dev","A","454"}'' as ihdf_dev_a_0454,--回収量04
  om.ind_device_set_info#>>''{"ihdf","dev","A","455"}'' as ihdf_dev_a_0455,--回収量05
  om.ind_device_set_info#>>''{"ihdf","dev","A","456"}'' as ihdf_dev_a_0456,--回収量06
  om.ind_device_set_info#>>''{"ihdf","dev","A","457"}'' as ihdf_dev_a_0457,--回収量07
  om.ind_device_set_info#>>''{"ihdf","dev","A","458"}'' as ihdf_dev_a_0458,--回収量08
  om.ind_device_set_info#>>''{"ihdf","dev","A","459"}'' as ihdf_dev_a_0459,--回収量09
  om.ind_device_set_info#>>''{"ihdf","dev","A","460"}'' as ihdf_dev_a_0460,--回収量10
  om.ind_device_set_info#>>''{"ihdf","dev","A","461"}'' as ihdf_dev_a_0461,--回収量11
  om.ind_device_set_info#>>''{"ihdf","dev","A","462"}'' as ihdf_dev_a_0462,--回収量12
  om.ind_device_set_info#>>''{"ihdf","dev","A","463"}'' as ihdf_dev_a_0463,--回収量13
  om.ind_device_set_info#>>''{"ihdf","dev","A","464"}'' as ihdf_dev_a_0464,--回収量14
  om.ind_device_set_info#>>''{"ihdf","dev","A","465"}'' as ihdf_dev_a_0465,--回収量15
  om.ind_device_set_info#>>''{"ihdf","dev","A","466"}'' as ihdf_dev_a_0466,--回収量16
  om.ind_device_set_info#>>''{"qbqd","dev","A","430"}'' as qbqd_dev_a_0430,--QBプログラム電源
  om.ind_device_set_info#>>''{"qbqd","dev","A","429"}'' as qbqd_dev_a_0429,--QB、QDプログラム最大ステップ数
  om.ind_device_set_info#>>''{"qbqd","dev","A","400"}'' as qbqd_dev_a_0400,--QBプログラム血流量1
  om.ind_device_set_info#>>''{"qbqd","dev","A","401"}'' as qbqd_dev_a_0401,--QBプログラム血流量2
  om.ind_device_set_info#>>''{"qbqd","dev","A","402"}'' as qbqd_dev_a_0402,--QBプログラム血流量3
  om.ind_device_set_info#>>''{"qbqd","dev","A","403"}'' as qbqd_dev_a_0403,--QBプログラム血流量4
  om.ind_device_set_info#>>''{"qbqd","dev","A","404"}'' as qbqd_dev_a_0404,--QBプログラム血流量5
  om.ind_device_set_info#>>''{"qbqd","dev","A","405"}'' as qbqd_dev_a_0405,--QBプログラム血流量6
  om.ind_device_set_info#>>''{"qbqd","dev","A","406"}'' as qbqd_dev_a_0406,--QBプログラム血流量7
  om.ind_device_set_info#>>''{"qbqd","dev","A","407"}'' as qbqd_dev_a_0407,--QBプログラム血流量8
  om.ind_device_set_info#>>''{"qbqd","dev","A","408"}'' as qbqd_dev_a_0408,--QBプログラム血流量9
  om.ind_device_set_info#>>''{"qbqd","dev","A","409"}'' as qbqd_dev_a_0409,--QBプログラム血流量10
  om.ind_device_set_info#>>''{"qbqd","dev","A","431"}'' as qbqd_dev_a_0431,--QDプログラム電源
  om.ind_device_set_info#>>''{"qbqd","dev","A","410"}'' as qbqd_dev_a_0410,--QDプログラム透析液流量1
  om.ind_device_set_info#>>''{"qbqd","dev","A","411"}'' as qbqd_dev_a_0411,--QDプログラム透析液流量2
  om.ind_device_set_info#>>''{"qbqd","dev","A","412"}'' as qbqd_dev_a_0412,--QDプログラム透析液流量3
  om.ind_device_set_info#>>''{"qbqd","dev","A","413"}'' as qbqd_dev_a_0413,--QDプログラム透析液流量4
  om.ind_device_set_info#>>''{"qbqd","dev","A","414"}'' as qbqd_dev_a_0414,--QDプログラム透析液流量5
  om.ind_device_set_info#>>''{"qbqd","dev","A","415"}'' as qbqd_dev_a_0415,--QDプログラム透析液流量6
  om.ind_device_set_info#>>''{"qbqd","dev","A","416"}'' as qbqd_dev_a_0416,--QDプログラム透析液流量7
  om.ind_device_set_info#>>''{"qbqd","dev","A","417"}'' as qbqd_dev_a_0417,--QDプログラム透析液流量8
  om.ind_device_set_info#>>''{"qbqd","dev","A","418"}'' as qbqd_dev_a_0418,--QDプログラム透析液流量9
  om.ind_device_set_info#>>''{"qbqd","dev","A","419"}'' as qbqd_dev_a_0419,--QDプログラム透析液流量10
  om.ind_device_set_info#>>''{"qbqd","dev","A","420"}'' as qbqd_dev_a_0420,--QB、QDプログラム切替時間1
  om.ind_device_set_info#>>''{"qbqd","dev","A","421"}'' as qbqd_dev_a_0421,--QB、QDプログラム切替時間2
  om.ind_device_set_info#>>''{"qbqd","dev","A","422"}'' as qbqd_dev_a_0422,--QB、QDプログラム切替時間3
  om.ind_device_set_info#>>''{"qbqd","dev","A","423"}'' as qbqd_dev_a_0423,--QB、QDプログラム切替時間4
  om.ind_device_set_info#>>''{"qbqd","dev","A","424"}'' as qbqd_dev_a_0424,--QB、QDプログラム切替時間5
  om.ind_device_set_info#>>''{"qbqd","dev","A","425"}'' as qbqd_dev_a_0425,--QB、QDプログラム切替時間6
  om.ind_device_set_info#>>''{"qbqd","dev","A","426"}'' as qbqd_dev_a_0426,--QB、QDプログラム切替時間7
  om.ind_device_set_info#>>''{"qbqd","dev","A","427"}'' as qbqd_dev_a_0427,--QB、QDプログラム切替時間8
  om.ind_device_set_info#>>''{"qbqd","dev","A","428"}'' as qbqd_dev_a_0428,--QB、QDプログラム切替時間9
  om.ind_device_set_info#>>''{"ufr","dev","A","290"}'' as ufr_dev_a_0290,--ＵＦＲプログラム電源ＳＷ
  om.ind_device_set_info#>>''{"ufr","dev","A","311"}'' as ufr_dev_a_0311,--ＵＦＲプログラム最終位置
  om.ind_device_set_info#>>''{"ufr","dev","A","312"}'' as ufr_dev_a_0312,--ＵＦＲプログラムコース
  om.ind_device_set_info#>>''{"ufr","dev","A","291"}'' as ufr_dev_a_0291,--治療モード１
  om.ind_device_set_info#>>''{"ufr","dev","A","292"}'' as ufr_dev_a_0292,--治療モード２
  om.ind_device_set_info#>>''{"ufr","dev","A","293"}'' as ufr_dev_a_0293,--治療モード３
  om.ind_device_set_info#>>''{"ufr","dev","A","294"}'' as ufr_dev_a_0294,--治療モード４
  om.ind_device_set_info#>>''{"ufr","dev","A","295"}'' as ufr_dev_a_0295,--治療モード５
  om.ind_device_set_info#>>''{"ufr","dev","A","296"}'' as ufr_dev_a_0296,--治療モード６
  om.ind_device_set_info#>>''{"ufr","dev","A","297"}'' as ufr_dev_a_0297,--治療モード７
  om.ind_device_set_info#>>''{"ufr","dev","A","298"}'' as ufr_dev_a_0298,--治療モード８
  om.ind_device_set_info#>>''{"ufr","dev","A","299"}'' as ufr_dev_a_0299,--治療モード９
  om.ind_device_set_info#>>''{"ufr","dev","A","300"}'' as ufr_dev_a_0300,--治療モード１０
  om.ind_device_set_info#>>''{"ufr","dev","A","301"}'' as ufr_dev_a_0301,--ＵＦＲプログラム指数１
  om.ind_device_set_info#>>''{"ufr","dev","A","302"}'' as ufr_dev_a_0302,--ＵＦＲプログラム指数２
  om.ind_device_set_info#>>''{"ufr","dev","A","303"}'' as ufr_dev_a_0303,--ＵＦＲプログラム指数３
  om.ind_device_set_info#>>''{"ufr","dev","A","304"}'' as ufr_dev_a_0304,--ＵＦＲプログラム指数４
  om.ind_device_set_info#>>''{"ufr","dev","A","305"}'' as ufr_dev_a_0305,--ＵＦＲプログラム指数５
  om.ind_device_set_info#>>''{"ufr","dev","A","306"}'' as ufr_dev_a_0306,--ＵＦＲプログラム指数６
  om.ind_device_set_info#>>''{"ufr","dev","A","307"}'' as ufr_dev_a_0307,--ＵＦＲプログラム指数７
  om.ind_device_set_info#>>''{"ufr","dev","A","308"}'' as ufr_dev_a_0308,--ＵＦＲプログラム指数８
  om.ind_device_set_info#>>''{"ufr","dev","A","309"}'' as ufr_dev_a_0309,--ＵＦＲプログラム指数９
  om.ind_device_set_info#>>''{"ufr","dev","A","310"}'' as ufr_dev_a_0310,--ＵＦＲプログラム指数１０
  om.ind_device_set_info#>>''{"ufr","dev","A","313"}'' as ufr_dev_a_0313,--ＵＦＲプログラム開始数値
  om.ind_device_set_info#>>''{"ufr","dev","A","314"}'' as ufr_dev_a_0314,--ＵＦＲプログラム終了数値
  om.ind_device_set_info#>>''{"ufr","dev","B","0"}'' as ufr_dev_b_0000,--UFRプログラム工程1の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","1"}'' as ufr_dev_b_0001,--UFRプログラム工程2の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","2"}'' as ufr_dev_b_0002,--UFRプログラム工程3の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","3"}'' as ufr_dev_b_0003,--UFRプログラム工程4の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","4"}'' as ufr_dev_b_0004,--UFRプログラム工程5の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","5"}'' as ufr_dev_b_0005,--UFRプログラム工程6の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","6"}'' as ufr_dev_b_0006,--UFRプログラム工程7の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","7"}'' as ufr_dev_b_0007,--UFRプログラム工程8の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","8"}'' as ufr_dev_b_0008,--UFRプログラム工程9の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","9"}'' as ufr_dev_b_0009,--UFRプログラム工程10の指数
  om.ind_device_set_info#>>''{"na","dev","A","315"}'' as na_dev_a_0315,--Na注入プログラム電源ＳＷ
  om.ind_device_set_info#>>''{"na","dev","A","326"}'' as na_dev_a_0326,--Na注入プログラム切替時間
  om.ind_device_set_info#>>''{"na","dev","A","328"}'' as na_dev_a_0328,--Na注入プログラムコース
  om.ind_device_set_info#>>''{"na","dev","A","327"}'' as na_dev_a_0327,--Na注入プログラム　ＵＦＲプロとの連動選択
  om.ind_device_set_info#>>''{"na","dev","A","316"}'' as na_dev_a_0316,--Na注入プログラム設定１
  om.ind_device_set_info#>>''{"na","dev","A","317"}'' as na_dev_a_0317,--Na注入プログラム設定２
  om.ind_device_set_info#>>''{"na","dev","A","318"}'' as na_dev_a_0318,--Na注入プログラム設定３
  om.ind_device_set_info#>>''{"na","dev","A","319"}'' as na_dev_a_0319,--Na注入プログラム設定４
  om.ind_device_set_info#>>''{"na","dev","A","320"}'' as na_dev_a_0320,--Na注入プログラム設定５
  om.ind_device_set_info#>>''{"na","dev","A","321"}'' as na_dev_a_0321,--Na注入プログラム設定６
  om.ind_device_set_info#>>''{"na","dev","A","322"}'' as na_dev_a_0322,--Na注入プログラム設定７
  om.ind_device_set_info#>>''{"na","dev","A","323"}'' as na_dev_a_0323,--Na注入プログラム設定８
  om.ind_device_set_info#>>''{"na","dev","A","324"}'' as na_dev_a_0324,--Na注入プログラム設定９
  om.ind_device_set_info#>>''{"na","dev","A","325"}'' as na_dev_a_0325,--Na注入プログラム設定１０
  om.ind_device_set_info#>>''{"na","dev","A","329"}'' as na_dev_a_0329,--Na注入プログラム開始数値
  om.ind_device_set_info#>>''{"na","dev","A","330"}'' as na_dev_a_0330,--Na注入プログラム終了数値
  om.ind_device_set_info#>>''{"na","dev","A","184"}'' as na_dev_a_0184,--Na注入濃度操作範囲上限
  om.ind_device_set_info#>>''{"bvufc","dev","A","196"}'' as bvufc_dev_a_0196,--BV-UFC使用選択
  om.ind_device_set_info#>>''{"bvufc","dev","A","197"}'' as bvufc_dev_a_0197,--UFC期間除水速度上限
  om.ind_device_set_info#>>''{"bvufc","dev","A","198"}'' as bvufc_dev_a_0198,--UFC期間除水速度下限
  om.ind_device_set_info#>>''{"bvufc","dev","A","199"}'' as bvufc_dev_a_0199,--開始期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","206"}'' as bvufc_dev_a_0206,--開始期間 除水速度倍率
  om.ind_device_set_info#>>''{"bvufc","dev","A","207"}'' as bvufc_dev_a_0207,--固定倍率除水期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","208"}'' as bvufc_dev_a_0208,--固定倍率除水期間 除水速度倍率
  om.ind_device_set_info#>>''{"bvufc","dev","A","209"}'' as bvufc_dev_a_0209,--固定倍率除水終了条件　最高血圧
  om.ind_device_set_info#>>''{"bvufc","dev","A","210"}'' as bvufc_dev_a_0210,--固定倍率除水終了条件　脈拍
  om.ind_device_set_info#>>''{"bvufc","dev","A","248"}'' as bvufc_dev_a_0248,--固定倍率除水終了条件　ΔBV
  om.ind_device_set_info#>>''{"bvufc","dev","A","249"}'' as bvufc_dev_a_0249,--終了前期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","271"}'' as bvufc_dev_a_0271,--開始時ΔBV基準値
  om.ind_device_set_info#>>''{"bvufc","dev","A","272"}'' as bvufc_dev_a_0272,--ΔBV基準線　指数1
  om.ind_device_set_info#>>''{"bvufc","dev","A","273"}'' as bvufc_dev_a_0273,--ΔBV基準線　指数2
  om.ind_device_set_info#>>''{"bvufc","dev","A","274"}'' as bvufc_dev_a_0274,--ΔBV基準線　指数3
  om.ind_device_set_info#>>''{"bvufc","dev","A","275"}'' as bvufc_dev_a_0275,--終了時ΔBV基準値
  om.ind_device_set_info#>>''{"dia","dev","A","282"}'' as dia_dev_a_0282,--透析量プログラム使用選択
  om.ind_device_set_info#>>''{"dia","dev","A","288"}'' as dia_dev_a_0288,--目標Kt/V
  om.ind_device_set_info#>>''{"dia","dev","A","ord_no"}'' as dia_dev_a_ord_no,--検査日オーダ番号
  om.ind_device_set_info#>>''{"dc","dev","A","340"}'' as dc_dev_a_0340,--透析液濃度プログラム使用選択
  om.ind_device_set_info#>>''{"dc","dev","A","368"}'' as dc_dev_a_0368,--濃度プログラム　ＵＦＲプロとの連動選択
  om.ind_device_set_info#>>''{"dc","dev","A","367"}'' as dc_dev_a_0367,--濃度プログラム切替時間
  om.ind_device_set_info#>>''{"dc","dev","A","361"}'' as dc_dev_a_0361,--透析液濃度プログラムステップ切替無し　コース
  om.ind_device_set_info#>>''{"dc","dev","A","341"}'' as dc_dev_a_0341,--透析液濃度プログラム設定１
  om.ind_device_set_info#>>''{"dc","dev","A","342"}'' as dc_dev_a_0342,--透析液濃度プログラム設定２
  om.ind_device_set_info#>>''{"dc","dev","A","343"}'' as dc_dev_a_0343,--透析液濃度プログラム設定３
  om.ind_device_set_info#>>''{"dc","dev","A","344"}'' as dc_dev_a_0344,--透析液濃度プログラム設定４
  om.ind_device_set_info#>>''{"dc","dev","A","345"}'' as dc_dev_a_0345,--透析液濃度プログラム設定５
  om.ind_device_set_info#>>''{"dc","dev","A","346"}'' as dc_dev_a_0346,--透析液濃度プログラム設定６
  om.ind_device_set_info#>>''{"dc","dev","A","347"}'' as dc_dev_a_0347,--透析液濃度プログラム設定７
  om.ind_device_set_info#>>''{"dc","dev","A","348"}'' as dc_dev_a_0348,--透析液濃度プログラム設定８
  om.ind_device_set_info#>>''{"dc","dev","A","349"}'' as dc_dev_a_0349,--透析液濃度プログラム設定９
  om.ind_device_set_info#>>''{"dc","dev","A","350"}'' as dc_dev_a_0350,--透析液濃度プログラム設定１０
  om.ind_device_set_info#>>''{"dc","dev","A","362"}'' as dc_dev_a_0362,--透析液濃度プログラム開始数値
  om.ind_device_set_info#>>''{"dc","dev","A","363"}'' as dc_dev_a_0363,--透析液濃度プログラム終了数値
  om.ind_device_set_info#>>''{"dc","dev","A","364"}'' as dc_dev_a_0364,--Ｂ液濃度プログラムステップ切替無し　コース
  om.ind_device_set_info#>>''{"dc","dev","A","351"}'' as dc_dev_a_0351,--Ｂ液濃度プログラム設定１
  om.ind_device_set_info#>>''{"dc","dev","A","352"}'' as dc_dev_a_0352,--Ｂ液濃度プログラム設定２
  om.ind_device_set_info#>>''{"dc","dev","A","353"}'' as dc_dev_a_0353,--Ｂ液濃度プログラム設定３
  om.ind_device_set_info#>>''{"dc","dev","A","354"}'' as dc_dev_a_0354,--Ｂ液濃度プログラム設定４
  om.ind_device_set_info#>>''{"dc","dev","A","355"}'' as dc_dev_a_0355,--Ｂ液濃度プログラム設定５
  om.ind_device_set_info#>>''{"dc","dev","A","356"}'' as dc_dev_a_0356,--Ｂ液濃度プログラム設定６
  om.ind_device_set_info#>>''{"dc","dev","A","357"}'' as dc_dev_a_0357,--Ｂ液濃度プログラム設定７
  om.ind_device_set_info#>>''{"dc","dev","A","358"}'' as dc_dev_a_0358,--Ｂ液濃度プログラム設定８
  om.ind_device_set_info#>>''{"dc","dev","A","359"}'' as dc_dev_a_0359,--Ｂ液濃度プログラム設定９
  om.ind_device_set_info#>>''{"dc","dev","A","360"}'' as dc_dev_a_0360,--Ｂ液濃度プログラム設定１０
  om.ind_device_set_info#>>''{"dc","dev","A","365"}'' as dc_dev_a_0365,--Ｂ液濃度プログラム開始数値
  om.ind_device_set_info#>>''{"dc","dev","A","366"}'' as dc_dev_a_0366,--Ｂ液濃度プログラム終了数値
  om.ind_device_set_info#>>''{"dc","dev","B","20"}'' as dc_dev_b_0020,--A液濃度プログラム工程1のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","21"}'' as dc_dev_b_0021,--A液濃度プログラム工程2のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","22"}'' as dc_dev_b_0022,--A液濃度プログラム工程3のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","23"}'' as dc_dev_b_0023,--A液濃度プログラム工程4のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","24"}'' as dc_dev_b_0024,--A液濃度プログラム工程5のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","25"}'' as dc_dev_b_0025,--A液濃度プログラム工程6のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","26"}'' as dc_dev_b_0026,--A液濃度プログラム工程7のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","27"}'' as dc_dev_b_0027,--A液濃度プログラム工程8のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","28"}'' as dc_dev_b_0028,--A液濃度プログラム工程9のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","29"}'' as dc_dev_b_0029,--A液濃度プログラム工程10のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","10"}'' as dc_dev_b_0010,--B液濃度プログラム工程1のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","11"}'' as dc_dev_b_0011,--B液濃度プログラム工程2のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","12"}'' as dc_dev_b_0012,--B液濃度プログラム工程3のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","13"}'' as dc_dev_b_0013,--B液濃度プログラム工程4のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","14"}'' as dc_dev_b_0014,--B液濃度プログラム工程5のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","15"}'' as dc_dev_b_0015,--B液濃度プログラム工程6のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","16"}'' as dc_dev_b_0016,--B液濃度プログラム工程7のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","17"}'' as dc_dev_b_0017,--B液濃度プログラム工程8のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","18"}'' as dc_dev_b_0018,--B液濃度プログラム工程9のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","19"}'' as dc_dev_b_0019--B液濃度プログラム工程10のB液濃度
  ,om.ind_device_set_info#>>''{"blood_flow","judge"}'' as blood_flow_judge --ホスト監視血流量監視フラグ
  ,om.ind_device_set_info#>>''{"blood_flow","upper"}'' as blood_flow_upper --ホスト監視血流量上限
  ,om.ind_device_set_info#>>''{"blood_flow","lower"}'' as blood_flow_lower --ホスト監視血流量下限
  ,om.ind_device_set_info#>>''{"ip_speed","judge"}'' as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,om.ind_device_set_info#>>''{"ip_speed","upper"}'' as ip_speed_upper --ホスト監視IP速度上限
  ,om.ind_device_set_info#>>''{"ip_speed","lower"}'' as ip_speed_lower --ホスト監視IP速度下限
  ,om.ind_device_set_info#>>''{"ufr","judge"}'' as ufr_judge --ホスト監視除水速度監視フラグ
  ,om.ind_device_set_info#>>''{"ufr","upper"}'' as ufr_upper --ホスト監視除水速度上限
  ,om.ind_device_set_info#>>''{"ufr","lower"}'' as ufr_lower --ホスト監視除水速度下限
  ,om.ind_device_set_info#>>''{"bp_max","judge"}'' as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_max","upper"}'' as bp_max_upper --ホスト監視最高血圧上限
  ,om.ind_device_set_info#>>''{"bp_max","lower"}'' as bp_max_lower --ホスト監視最高血圧下限
  ,om.ind_device_set_info#>>''{"bp_min","judge"}'' as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_min","upper"}'' as bp_min_upper --ホスト監視最低血圧上限
  ,om.ind_device_set_info#>>''{"bp_min","lower"}'' as bp_min_lower --ホスト監視最低血圧下限
  ,om.ind_device_set_info#>>''{"bp_ave","judge"}'' as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_ave","upper"}'' as bp_ave_upper --ホスト監視平均血圧上限
  ,om.ind_device_set_info#>>''{"bp_ave","lower"}'' as bp_ave_lower --ホスト監視平均血圧下限
  ,om.ind_device_set_info#>>''{"pulse","judge"}'' as pulse_judge --ホスト監視脈拍監視フラグ
  ,om.ind_device_set_info#>>''{"pulse","upper"}'' as pulse_upper --ホスト監視脈拍上限
  ,om.ind_device_set_info#>>''{"pulse","lower"}'' as pulse_lower --ホスト監視脈拍下限
  ,om.ind_device_set_info#>>''{"vp","judge"}'' as vp_judge --ホスト監視静脈圧監視フラグ
  ,om.ind_device_set_info#>>''{"vp","upper"}'' as vp_upper --ホスト監視静脈圧上限
  ,om.ind_device_set_info#>>''{"vp","lower"}'' as vp_lower --ホスト監視静脈圧下限
  ,om.ind_device_set_info#>>''{"ap","judge"}'' as ap_ave_judge --ホスト監視動脈圧監視フラグ
  ,om.ind_device_set_info#>>''{"ap","upper"}'' as ap_ave_upper --ホスト監視動脈圧上限
  ,om.ind_device_set_info#>>''{"ap","lower"}'' as ap_ave_lower --ホスト監視動脈圧下限
  ,om.ind_device_set_info#>>''{"na_conc","judge"}'' as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,om.ind_device_set_info#>>''{"na_conc","upper"}'' as na_conc_upper --ホスト監視Na濃度上限
  ,om.ind_device_set_info#>>''{"na_conc","lower"}'' as na_conc_lower --ホスト監視Na濃度下限
  ,om.ind_device_set_info#>>''{"dialys_temp","judge"}'' as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,om.ind_device_set_info#>>''{"dialys_temp","upper"}'' as dialys_temp_upper --ホスト監視透析液温度上限
  ,om.ind_device_set_info#>>''{"dialys_temp","lower"}'' as dialys_temp_lower --ホスト監視透析液温度下限
  ,om.ind_device_set_info#>>''{"care_i","judge"}'' as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,om.ind_device_set_info#>>''{"care_i","interval"}'' as care_i_interval --ホスト監視ケア報知
  ,ord_no as ord_no_t
from
  pat_main pm
   inner join
    (select
      pat_id,
      ind_device_set_info,
			ord_no
    from
      ord_main
    where
      ord_no = @ordNo
      and is_del = ''0''

    ) om ON pm.pat_id = om.pat_id
    and is_del = ''0''



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

	', 2, '[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "1", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "1", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "1", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "1", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "1", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "51", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "41", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.6", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "1", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "1", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "1", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "1", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "3", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "1", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "降圧測定", "item": "降圧測定"}, {"code": "1", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "1", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "1", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00:12", "can_calc": "1", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:23", "can_calc": "1", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "1", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "1", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "1", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "1", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "01:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "1", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "1", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "指示", "facility_table": "0", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "1", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "1", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "1", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "1", "data_code": "ufr_dev_a_0290", "data_name": "ＵＦＲプログラム電源ＳＷ", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "1", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム電源ＳＷ", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "1", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "1", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "06:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間に含まない", "can_calc": "1", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血(除水なし)", "can_calc": "1", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血(除水あり)", "item": "片側脱血(除水あり)"}, {"code": "1", "disp": "片側脱血(除水なし)", "item": "片側脱血(除水なし)"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "1", "data_code": "dfas_dev_b_0036", "data_name": "治療開始時_血流量使用有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_b_0036", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dfas_dev_a_0335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0335", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "1", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "1", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "1", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "0", "disp": "流量設定", "item": "流量設定"}, {"code": "1", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "1", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り", "item": "入り"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "1", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り", "item": "入り"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：装置設定　@ordNo使用', '2020-03-27 17:15:00', '2023-09-10 22:06:07.982', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (93, 'WITH DATA AS (

with input_params_expand as
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
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,pat_event.ord_no
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_cd
	,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,treat_date
    ,case
      when rst_dialysis_state <> ''0'' then rst_kur_name
      else ind_kur_name
    end as linked_kur_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_bed_name
      else ind_bed_name
    end as linked_bed_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_treatment_name
      else ind_treatment_name
    end as linked_treatment_name
  from
    pat_event
    left outer join (select * from ord_main where is_del = ''0'') as ord_main
      on pat_event.ord_no = ord_main.ord_no
  where
    pat_event.is_del = ''0''
    and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''9''
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
  pe_basicinfo_plus.ord_no as ord_no_t
  ,pe_array_agg.pat_event_cd
   ,to_timestamp(event_start_date||event_start_time, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||event_end_time, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo_plus.reg_date
--   ,up_staff_name
--   ,pe_basicinfo_plus.up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''
  end as is_linked
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' as linked_treat_date
  ,case
    when linked_kur_name is null or linked_kur_name = ''''
      then kbt.kur_name
      else linked_kur_name
    end
  ,case
    when linked_bed_name is null or linked_bed_name = ''''
      then kbt.bed_name
      else linked_bed_name
    end
  ,case
    when linked_treatment_name is null or linked_treatment_name = ''''
      then kbt.treatment_name
      else linked_treatment_name
    end
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
  left outer join (select
                       om.ord_no,
                       mk.kur_name as kur_name,
                       mb.bed_name as bed_name,
                       mt.treatment_name as treatment_name
                     from
                       ord_main as om
                       left outer join mst_kur mk on om.ind_kur_cd = mk.kur_cd
                       left outer join mst_bed mb on om.ind_bed_cd = mb.bed_cd
                       left outer join mst_treatment mt on om.ind_treatment_cd = mt.treatment_cd
                     where om.is_del = ''0'') as kbt
               on pe_basicinfo_plus.ord_no = kbt.ord_no
ORDER BY event_start_date, reg_date
  ),
time_info AS (
  WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
      pat_id in (@patId)
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')

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
  b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
  CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS ind_end_date_time
  , b.rst_start_date
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
;', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(治療実績リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "is_linked", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treat_date", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_kur_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_bed_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treatment_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_detail", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 治療実績リンク　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', '2024-07-31 19:50:38.016', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (97, 'WITH DATA AS (


	with ord_key_tbl as (
  select distinct
    facility_cd
  from
    ord_main
  where
    ord_no in ( @ordNos ) and is_del = ''0'' and rst_dialysis_state <> ''0''


),
dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
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
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
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
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
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

    -- 実績
    ,info->>''needle_type'' as needle_type
    ,ord_no
  from
    ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( rst_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )

  where
    ord_no in ( @ordNos ) and is_del = ''0'' and rst_dialysis_state <> ''0''

)


(select
	ord_no as ord_no_t
	,1 AS dis_order,
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
ord_no as ord_no_t,
	2 AS dis_order,
  ord.*,
  eqp.equipment_name as equip_name,
	eqp.class_cd AS equip_class_cd,
  eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  eqp.unit as equip_unit,
	case when eqp.class_cd = ''-1'' then ''未分類'' else eqp_cls.class_name end as equip_class_name,
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



	),
time_info AS (
	WITH b AS (
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

	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未使用", "item": "未使用"}, {"code": "1", "disp": "A針", "item": "A針"}, {"code": "2", "disp": "V針", "item": "V針"}, {"code": "3", "disp": "SN", "item": "SN"}], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @ordNo 使用', '2020-03-31 23:59:59', '2024-03-31 21:16:06.936', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (98, 'WITH DATA AS (


	select
  ord_no as ord_no_t
	,facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
order by no


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

	', 2, '[{"preview": "指示簿テストです。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：指示簿(指示コメント) @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:00.634', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (100, 'WITH DATA AS (



with latest_otc as(
  select * from ord_treat_condition where (ord_no, up_date) in (select ord_no, max(up_date) from ord_treat_condition where ord_no = @ordNo and is_del = ''0'' and is_disp = ''1'' group by ord_no)
)
, dialyzer_record as(
  select gas_purge_time, substituent_wash_amt, membrane_wash
  from
    ord_main
    inner join (select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1'') as mst_dialyzer
      on (ord_main.rst_cond_info#>>''{5, value}'')::text = mst_dialyzer.dialyzer_cd::text
  where
    ord_no = @ordNo and ord_main.is_del = ''0''
    and ord_main.rst_dialysis_state <>''0''
)

select
  null as ope_dev_a_0179 -- 血流量設定最大値
  ,null as ope_dev_a_0181 -- 除水速度制限
  ,null as ope_dev_a_0038 -- 動脈側気泡検出器
  ,null as ope_dev_a_0021 -- 除水計算時間
  ,null as ope_dev_a_0022 -- 除水計算優先項目
  ,null as ope_dev_a_0039 -- 除水開始遅延時間
  ,null as ope_dev_a_0182 -- 透析液温度操作範囲上限
  ,null as ope_dev_a_0183 -- 透析液温度操作範囲下限
  ,null as ope_dev_a_0024 -- シングルニードル切替圧上限
  ,null as ope_dev_a_0025 -- シングルニードル切替圧下限
  ,null as ope_dev_a_0241 -- TMPゼロ補正
  ,null as ope_dev_a_0168 -- HD補正警報上限値
  ,null as ope_dev_a_0169 -- HD補正警報下限値
  ,null as ope_dev_a_0171 -- ECUM補正警報上限値
  ,null as ope_dev_a_0172 -- ECUM補正警報下限値
  ,null as ope_dev_a_0174 -- HDF補正警報上限値
  ,null as ope_dev_a_0175 -- HDF補正警報下限値
  ,null as ope_dev_a_0177 -- HF補正警報上限値
  ,null as ope_dev_a_0178 -- HF補正警報下限値
  ,null as ope_dev_b_0037 -- HD+補液補正警報上限値
  ,null as ope_dev_b_0038 -- HD+補液補正警報下限値
  ,null as ope_dev_a_0391 -- OHDF補正警報上限値
  ,null as ope_dev_a_0392 -- OHDF補正警報下限値
  ,null as ope_dev_a_0394 -- OHF補正警報上限値
  ,null as ope_dev_a_0395 -- OHF補正警報下限値
  ,null as ope_dev_a_0383 -- 補液量制限
  ,null as ope_dev_a_0389 -- 補液計算優先項目
  ,null as ope_dev_a_0379 -- 補液比率（前補液）
  ,null as ope_dev_b_0039 -- 補液比率（後補液）
  ,null as ope_dev_a_0398 -- 補液開始遅延時間
  ,null as ope_dev_a_0369 -- DP=Qd+Qs(補液速度加算)
  ,null as ope_dev_a_0090 -- 濾過率（前補液）
  ,null as ope_dev_b_0040 -- 濾過率（後補液）
  ,null as ope_dev_a_0091 -- ヘマトクリット（Ht）
  ,null as ope_dev_a_0092 -- 総タンパク（TP）
  ,null as ope_dev_a_0336 -- 緊急補液速度
  ,null as ope_dev_a_0337 -- 緊急補液量
  ,null as ope_dev_a_0185 -- HDF速度操作範囲上限前補液
  ,null as ope_dev_b_0031 -- HDF速度操作範囲上限後補液
  ,null as ope_dev_a_0186 -- HF速度操作範囲上限前補液
  ,null as ope_dev_b_0032 -- HF速度操作範囲上限後補液
  ,null as ope_dev_b_0030 -- HD+補液速度操作範囲上限前補液
  ,null as ope_dev_b_0033 -- HD+補液速度操作範囲上限後補液
  ,null as ope_dev_a_0396 -- OHDF速度操作範囲上限前補液
  ,null as ope_dev_b_0034 -- OHDF速度操作範囲上限後補液
  ,null as ope_dev_a_0397 -- OHF速度操作範囲上限前補液
  ,null as ope_dev_b_0035 -- OHF速度操作範囲上限後補液
  ,null as ope_dev_a_0384 -- AFBF補液比率使用選択
  ,null as ope_dev_a_0385 -- AFBF補液比率
  ,null as ope_dev_a_0386 -- AFBF速度操作範囲上限
  ,null as ope_dev_a_0387 -- AFBF速度操作範囲下限
  ,null as ihdf_dev_a_0200 -- I-HDF_補液量設定
  ,null as ihdf_dev_a_0201 -- I-HDF_補液速度
  ,null as ihdf_dev_a_0202 -- I-HDF_補液周期
  ,null as ihdf_dev_a_0203 -- I-HDF_補液開始時間
  ,null as ihdf_dev_a_0204 -- I-HDF_除水再開時間
  ,null as ihdf_dev_a_0205 -- I-HDF_総補液量上限
  ,null as blood_flow_judge --ホスト監視血流量監視フラグ
  ,null as blood_flow_upper --ホスト監視血流量上限
  ,null as blood_flow_lower --ホスト監視血流量下限
  ,null as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,null as ip_speed_upper --ホスト監視IP速度上限
  ,null as ip_speed_lower --ホスト監視IP速度下限
  ,null as ufr_judge --ホスト監視除水速度監視フラグ
  ,null as ufr_upper --ホスト監視除水速度上限
  ,null as ufr_lower --ホスト監視除水速度下限
  ,null as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,null as bp_max_upper --ホスト監視最高血圧上限
  ,null as bp_max_lower --ホスト監視最高血圧下限
  ,null as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,null as bp_min_upper --ホスト監視最低血圧上限
  ,null as bp_min_lower --ホスト監視最低血圧下限
  ,null as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,null as bp_ave_upper --ホスト監視平均血圧上限
  ,null as bp_ave_lower --ホスト監視平均血圧下限
  ,null as pulse_judge --ホスト監視脈拍監視フラグ
  ,null as pulse_upper --ホスト監視脈拍上限
  ,null as pulse_lower --ホスト監視脈拍下限
  ,null as vp_judge --ホスト監視静脈圧監視フラグ
  ,null as vp_upper --ホスト監視静脈圧上限
  ,null as vp_lower --ホスト監視静脈圧下限
  ,null as rst_ap_judge --ホスト監視動脈圧監視フラグ
  ,null as rst_ap_upper --ホスト監視動脈圧上限
  ,null as rst_ap_lower --ホスト監視動脈圧下限
  ,null as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,null as na_conc_upper --ホスト監視Na濃度上限
  ,null as na_conc_lower --ホスト監視Na濃度下限
  ,null as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,null as dialys_temp_upper --ホスト監視透析液温度上限
  ,null as dialys_temp_lower --ホスト監視透析液温度下限
  ,null as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,null as care_i_interval --ホスト監視ケア報知
  ,null as war_dev_a_0240 -- TMP監視モード
  ,null as war_dev_a_0100 -- HD/ECUM静脈圧自動設定警報幅上限
  ,null as war_dev_a_0101 -- HD/ECUM静脈圧自動設定警報幅下限
  ,null as war_dev_a_0102 -- HD/ECUM静脈圧自動設定警報限界上限
  ,null as war_dev_a_0103 -- HD/ECUM静脈圧自動設定警報限界下限
  ,null as war_dev_a_0104 -- HD/ECUM静脈圧固定警報上限
  ,null as war_dev_a_0105 -- HD/ECUM静脈圧固定警報下限
  ,null as war_dev_a_0152 -- HD/ECUMダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0153 -- HD/ECUMダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0154 -- HD/ECUMダイアライザ入口圧自動設定警報限界上限
  ,null as war_dev_a_0155 -- HD/ECUMダイアライザ入口圧自動設定警報限界下限
  ,null as war_dev_a_0156 -- HD/ECUMダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0157 -- HD/ECUMダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0112 -- HD/ECUM液圧自動設定警報幅上限
  ,null as war_dev_a_0113 -- HD/ECUM液圧自動設定警報幅下限
  ,null as war_dev_a_0114 -- HD/ECUM液圧自動設定警報限界上限
  ,null as war_dev_a_0115 -- HD/ECUM液圧自動設定警報限界下限
  ,null as war_dev_a_0116 -- HD/ECUM液圧固定警報上限
  ,null as war_dev_a_0117 -- HD/ECUM液圧固定警報下限
  ,null as war_dev_a_0128 -- HD/ECUMTMP自動設定警報幅上限
  ,null as war_dev_a_0129 -- HD/ECUMTMP自動設定警報幅下限
  ,null as war_dev_a_0130 -- HD/ECUMTMP自動設定警報限界上限
  ,null as war_dev_a_0131 -- HD/ECUMTMP自動設定警報限界下限
  ,null as war_dev_a_0132 -- HD/ECUMTMP固定警報上限
  ,null as war_dev_a_0133 -- HD/ECUMTMP固定警報下限
  ,null as war_dev_a_0126 -- HD/ECUMTMP自動追従警報幅上限
  ,null as war_dev_a_0127 -- HD/ECUMTMP自動追従警報幅下限
  ,null as war_dev_a_0146 -- HD/ECUMダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0147 -- HD/ECUMダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0148 -- HD/ECUMダイアライザ差圧固定警報上限
  ,null as war_dev_a_0149 -- HD/ECUMダイアライザ差圧固定警報下限
  ,null as war_dev_a_0106 -- HDF/HF静脈圧自動設定警報幅上限
  ,null as war_dev_a_0107 -- HDF/HF静脈圧自動設定警報幅下限
  ,null as war_dev_a_0158 -- HDF/HFダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0159 -- HDF/HFダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0118 -- HDF/HF液圧自動設定警報幅上限
  ,null as war_dev_a_0119 -- HDF/HF液圧自動設定警報幅下限
  ,null as war_dev_a_0136 -- HDF/HFTMP自動設定警報幅上限
  ,null as war_dev_a_0137 -- HDF/HFTMP自動設定警報幅下限
  ,null as war_dev_a_0134 -- HDF/HFTMP自動追従警報幅上限
  ,null as war_dev_a_0135 -- HDF/HFTMP自動追従警報幅下限
  ,null as war_dev_a_0150 -- HDF/HFダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0151 -- HDF/HFダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0110 -- SN静脈圧固定警報上限
  ,null as war_dev_a_0111 -- SN静脈圧固定警報下限
  ,null as war_dev_a_0162 -- SNダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0163 -- SNダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0120 -- SN液圧自動設定警報幅上限
  ,null as war_dev_a_0121 -- SN液圧自動設定警報幅下限
  ,null as war_dev_a_0122 -- SN液圧自動設定警報限界上限
  ,null as war_dev_a_0123 -- SN液圧自動設定警報限界下限
  ,null as war_dev_a_0124 -- SN液圧固定警報上限
  ,null as war_dev_a_0125 -- SN液圧固定警報下限
  ,null as war_dev_a_0140 -- SNTMP自動設定警報幅上限
  ,null as war_dev_a_0141 -- SNTMP自動設定警報幅下限
  ,null as war_dev_a_0142 -- SNTMP自動設定警報限界上限
  ,null as war_dev_a_0143 -- SNTMP自動設定警報限界下限
  ,null as war_dev_a_0144 -- SNTMP固定警報上限
  ,null as war_dev_a_0145 -- SNTMP固定警報下限
  ,null as war_dev_a_0138 -- SNTMP自動追従警報幅上限
  ,null as war_dev_a_0139 -- SNTMP自動追従警報幅下限
  ,null as war_dev_a_0108 -- 準備回収静脈圧固定警報上限
  ,null as war_dev_a_0109 -- 準備回収静脈圧固定警報下限
  ,null as war_dev_a_0160 -- 準備回収ダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0161 -- 準備回収ダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0254 -- Na濃度自動警報幅上限値
  ,null as war_dev_a_0255 -- Na濃度自動警報幅下限値
  ,null as war_dev_a_0256 -- Na濃度固定警報幅上限値
  ,null as war_dev_a_0257 -- Na濃度固定警報幅下限値
  ,null as bp_dev_a_0211 -- 血圧警報点最高血圧上限
  ,null as bp_dev_a_0212 -- 血圧警報点最高血圧下限
  ,null as bp_dev_a_0213 -- 血圧警報点最低血圧上限
  ,null as bp_dev_a_0214 -- 血圧警報点最低血圧下限
  ,null as bp_dev_a_0215 -- 血圧警報点平均血圧上限
  ,null as bp_dev_a_0216 -- 血圧警報点平均血圧下限
  ,null as bp_dev_a_0217 -- 血圧警報点脈拍数上限
  ,null as bp_dev_a_0218 -- 血圧警報点脈拍数下限
  ,null as bp_dev_a_0219 -- 最高血圧上限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0227 -- 最高血圧上限警報_血液ポンプ_速度
  ,null as bp_dev_a_0220 -- 最高血圧下限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0228 -- 最高血圧下限警報_血液ポンプ_速度
  ,null as bp_dev_a_0221 -- 最高血圧上限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0229 -- 最高血圧上限警報_除水ポンプ_速度
  ,null as bp_dev_a_0222 -- 最高血圧下限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0230 -- 最高血圧下限警報_除水ポンプ_速度
  ,null as bp_dev_a_0223 -- 最高血圧上限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0231 -- 最高血圧上限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0224 -- 最高血圧下限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0232 -- 最高血圧下限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0225 -- 最高血圧上限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0233 -- 最高血圧上限警報_補液ポンプ_速度
  ,null as bp_dev_a_0226 -- 最高血圧下限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0234 -- 最高血圧下限警報_補液ポンプ_速度
  ,null as bp_dev_a_0191 -- 血圧カフ選択
  ,null as bp_dev_a_0190 -- 血圧自動測定間隔
  ,null as bp_dev_a_0192 -- 昇圧値
  ,null as bp_dev_a_0193 -- 昇圧方法選択
  ,null as bp_dev_a_0195 -- 血圧測定方法選択
  ,null as bp_dev_a_0239 -- 高速測定選択
  ,null as bp_dev_a_0194 -- 血圧連続測定動作選択
  ,null as bp_dev_a_0235 -- 警報連動測定開始時間
  ,null as bp_dev_a_0236 -- 治療条件連動測定時間
  ,null as bp_dev_a_0237 -- 静脈圧警報発生時の血圧測定
  ,null as bp_dev_a_0238 -- 血流量または除水速度変更時の血圧測定
  ,null as bv_dev_a_0267 -- BV計使用選択
  ,null as bv_dev_a_0260 -- ⊿BV低下警報点1
  ,null as bv_dev_a_0261 -- ⊿BV低下警報点2
  ,null as bv_dev_a_0262 -- ⊿BV変化率警報点
  ,null as bv_dev_a_0277 -- ⊿BV除水低下速度
  ,null as bv_dev_a_0278 -- ⊿BV除水低下遅延時間
  ,null as bv_dev_a_0258 -- アクセス再循環測定使用選択
  ,null as bv_dev_a_0259 -- アクセス再循環自動測定1
  ,null as bv_dev_a_0263 -- アクセス再循環自動測定2
  ,null as bv_dev_a_0264 -- アクセス再循環自動測定3
  ,null as bv_dev_a_0265 -- アクセス再循環自動測定4
  ,null as bv_dev_a_0266 -- アクセス再循環自動測定5
  ,null as dfas_dev_a_0270 -- 動脈側返血使用選択
  ,null as bv_dev_a_0281 -- アクセス再循環再循環率報知
  ,null as pri_pat_a_0219 -- プライミング補助動脈充填液量
  ,null as pri_pat_a_0220 -- プライミング補助動脈充填流速
  ,null as pri_pat_a_0225 -- プライミング補助動脈充填後継続の有無
  ,null as pri_pat_a_0221 -- プライミング補助静脈充填液量
  ,null as pri_pat_a_0222 -- プライミング補助静脈充填流速
  ,null as pri_pat_a_0226 -- プライミング補助静脈充填後継続の有無
  ,null as pri_pat_a_0223 -- プライミング補助気泡抜き液量
  ,null as pri_pat_a_0224 -- プライミング補助気泡抜き流速
  ,null as pri_pat_a_0227 -- プライミング補助気泡抜き間欠動作選択
  ,null as pri_pat_a_0228 -- プライミング補助液交換量
  ,null as pri_pat_a_0229 -- プライミング補助間欠動作動作時間
  ,null as pri_pat_a_0230 -- プライミング補助間欠動作停止時間
  ,null as pri_pat_a_0232 -- 自動プライミング落差時間
  ,null as pri_pat_a_0238 -- 自動プライミング総量
  ,null as pri_pat_a_0231 -- 自動プライミング開始時間
  ,null as pri_pat_a_0233 -- 自動プライミング送液液量
  ,null as pri_pat_a_0234 -- 自動プライミング送液流速1回目
  ,null as pri_pat_a_0235 -- 自動プライミング送液流速2回目以降
  ,null as pri_pat_a_0236 -- 自動プライミング循環流速
  ,null as pri_pat_a_0237 -- 自動プライミング循環時間
  ,null as pri_dev_a_0370 -- 自動回収_使用液量
  ,null as pri_dev_a_0371 -- 自動回収_流速
  ,null as pri_dev_a_0372 -- 自動回収_血液判別器による終了選択
  ,null as pri_pat_b_0051 -- オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  ,null as pri_pat_b_0032 -- オンラインプライミング_動脈チャンバ液面作成時間_前補液
  ,null as pri_pat_b_0052 -- オンラインプライミング_動脈チャンバ液面作成時間_後補液
  ,null as pri_pat_b_0033 -- オンラインプライミング_循環洗浄時間_前補液
  ,null as pri_pat_b_0053 -- オンラインプライミング_循環洗浄時間_後補液
  ,null as ufr_dev_a_0290 -- UFRプログラム使用選択
  ,null as na_dev_a_0315 -- Na注入プログラム使用選択
  ,null as na_dev_a_0184 -- Na注入濃度最大値
  ,null as dc_dev_a_0340 -- 透析液濃度プログラム使用選択
  ,null as ecum_dev_a_0016 -- ECUM選択
  ,null as ecum_dev_a_0017 -- ECUM量
  ,null as ecum_dev_a_0018 -- ECUM時間
  ,null as ecum_dev_a_0019 -- ECUM時間カウント選択
  ,null as cpro_dev_a_0252 -- Ｂ液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0253 -- Ｂ液濃度プログラム自動設定警報幅下限
  ,null as cpro_dev_a_0250 -- 透析液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0251 -- 透析液濃度プログラム自動設定警報幅下限
  ,null as dfas_pat_b_0001 -- IPラインプライミング使用選択
  ,dialyzer_record.gas_purge_time -- ガスパージ時間
  ,dialyzer_record.substituent_wash_amt-- 置換洗浄量（透析液）
  ,dialyzer_record.membrane_wash -- 膜洗浄（中空糸）
  ,null as dfas_pat_b_0005 -- 中空糸_プライミング時のBP速度
  ,null as dfas_pat_b_0007 -- 中空糸_送液最大時間
  ,null as dfas_pat_b_0008 -- 中空糸_回路内洗浄送液量
  ,null as dfas_pat_b_0009 -- 中空糸_気泡抜き動作実行回数
  ,null as dfas_pat_b_0010 -- 中空糸_気泡抜き圧力上限
  ,null as dfas_pat_b_0059 -- 積層_プライミング時のBP速度
  ,null as dfas_pat_b_0054 -- 積層_送液最大時間
  ,null as dfas_pat_b_0055 -- 積層_回路内洗浄送液量
  ,null as dfas_pat_b_0056 -- 積層_気泡抜き動作実行回数
  ,null as dfas_pat_b_0057 -- 積層_気泡抜き圧力上限
  ,null as dfas_pat_b_0058 -- 積層_除水ポンプ速度
  ,null as dfas_dev_a_0339 -- 脱血方法選択
  ,null as dfas_dev_a_0333 -- 脱血速度
  ,null as dfas_dev_a_0331 -- 同時脱血_脱血量
  ,null as dfas_dev_a_0334 -- 片側脱血(除水なし)_脱血量
  ,null as dfas_dev_a_0338 -- 片側脱血（除水あり）_脱血量
  ,null as dfas_dev_a_0332 -- 片側脱血への切替え透析液圧
  ,treat_condition->>''335'' as ord_treat_condition_335 -- 治療開始時_血液ポンプ速度
  ,null as dfas_dev_a_0373 -- 静脈側返血速度
  ,null as dfas_dev_a_0374 -- 静脈側最大返血量
  ,null as dfas_dev_a_0377 -- 静脈側返血_血液判別器使用選択
  ,null as dfas_dev_a_0376 -- 動脈側最大返血量
  ,null as dfas_dev_a_0378 -- 動脈側返血_血液判別器使用選択
  ,null as dia_dev_a_0282 -- 透析量プログラム使用選択
  ,treat_condition->>''283'' as ord_treat_condition_283 -- 体液量計算時後体重
  ,treat_condition->>''284'' as ord_treat_condition_284 -- 体液量+補正値
  ,treat_condition->>''285'' as ord_treat_condition_285 -- 目標後体重
  ,treat_condition->>''286'' as ord_treat_condition_286 -- 標準血流量
  ,treat_condition->>''287'' as ord_treat_condition_287 -- KoA
  ,null as dia_dev_a_0288 -- 目標Kt/V
  ,treat_condition->>''187'' as ord_treat_condition_187 -- ダイアライザ 尿素クリアランス
  ,treat_condition->>''188'' as ord_treat_condition_188 -- ダイアライザ 血流量
  ,treat_condition->>''189'' as ord_treat_condition_189 -- ダイアライザ 透析液流量
  ,null as bvufc_dev_a_0196 -- BV-UFC使用選択
  ,null as bvufc_dev_a_0197 -- UFC期間除水速度上限
  ,null as bvufc_dev_a_0198 -- UFC期間除水速度下限
  ,null as bvufc_dev_a_0199 -- 開始期間 時間
  ,null as bvufc_dev_a_0206 -- 開始期間 除水速度倍率
  ,null as bvufc_dev_a_0207 -- 固定倍率除水期間 時間
  ,null as bvufc_dev_a_0208 -- 固定倍率除水期間 除水速度倍率
  ,null as bvufc_dev_a_0209 -- 固定倍率除水終了条件　最高血圧
  ,null as bvufc_dev_a_0210 -- 固定倍率除水終了条件　脈拍
  ,null as bvufc_dev_a_0248 -- 固定倍率除水終了条件　ΔBV
  ,null as bvufc_dev_a_0249 -- 終了前期間 時間
  ,null as ope_dev_a_0268 -- 透析液流量　設定方法
  ,null as ope_dev_a_0269 -- 透析液流量　比率設定
  ,null as bvufc_dev_a_0271 -- 開始時ΔBV基準値
  ,null as bvufc_dev_a_0272 -- ΔBV基準線　指数1
  ,null as bvufc_dev_a_0273 -- ΔBV基準線　指数2
  ,null as bvufc_dev_a_0274 -- ΔBV基準線　指数3
  ,null as bvufc_dev_a_0275 -- 終了時ΔBV基準値
  ,null as qbqd_dev_a_0400 -- QBプログラム血流量1
  ,null as qbqd_dev_a_0401 -- QBプログラム血流量2
  ,null as qbqd_dev_a_0402 -- QBプログラム血流量3
  ,null as qbqd_dev_a_0403 -- QBプログラム血流量4
  ,null as qbqd_dev_a_0404 -- QBプログラム血流量5
  ,null as qbqd_dev_a_0405 -- QBプログラム血流量6
  ,null as qbqd_dev_a_0406 -- QBプログラム血流量7
  ,null as qbqd_dev_a_0407 -- QBプログラム血流量8
  ,null as qbqd_dev_a_0408 -- QBプログラム血流量9
  ,null as qbqd_dev_a_0409 -- QBプログラム血流量10
  ,null as qbqd_dev_a_0410 -- QDプログラム透析液流量1
  ,null as qbqd_dev_a_0411 -- QDプログラム透析液流量2
  ,null as qbqd_dev_a_0412 -- QDプログラム透析液流量3
  ,null as qbqd_dev_a_0413 -- QDプログラム透析液流量4
  ,null as qbqd_dev_a_0414 -- QDプログラム透析液流量5
  ,null as qbqd_dev_a_0415 -- QDプログラム透析液流量6
  ,null as qbqd_dev_a_0416 -- QDプログラム透析液流量7
  ,null as qbqd_dev_a_0417 -- QDプログラム透析液流量8
  ,null as qbqd_dev_a_0418 -- QDプログラム透析液流量9
  ,null as qbqd_dev_a_0419 -- QDプログラム透析液流量10
  ,null as qbqd_dev_a_0420 -- QB、QDプログラム切替時間1
  ,null as qbqd_dev_a_0421 -- QB、QDプログラム切替時間2
  ,null as qbqd_dev_a_0422 -- QB、QDプログラム切替時間3
  ,null as qbqd_dev_a_0423 -- QB、QDプログラム切替時間4
  ,null as qbqd_dev_a_0424 -- QB、QDプログラム切替時間5
  ,null as qbqd_dev_a_0425 -- QB、QDプログラム切替時間6
  ,null as qbqd_dev_a_0426 -- QB、QDプログラム切替時間7
  ,null as qbqd_dev_a_0427 -- QB、QDプログラム切替時間8
  ,null as qbqd_dev_a_0428 -- QB、QDプログラム切替時間9
  ,null as qbqd_dev_a_0429 -- QB、QDプログラム最大ステップ数
  ,null as qbqd_dev_a_0430 -- QBプログラム電源
  ,null as qbqd_dev_a_0431 -- QDプログラム電源
  ,null as ihdf_dev_a_0432 -- I-HDFプログラム使用選択
  ,null as ihdf_dev_a_0433 -- 予定補液回数
  ,null as ihdf_dev_a_0434 -- 補液バランス制限
  ,null as ihdf_dev_a_0435 -- 補液量01
  ,null as ihdf_dev_a_0436 -- 補液量02
  ,null as ihdf_dev_a_0437 -- 補液量03
  ,null as ihdf_dev_a_0438 -- 補液量04
  ,null as ihdf_dev_a_0439 -- 補液量05
  ,null as ihdf_dev_a_0440 -- 補液量06
  ,null as ihdf_dev_a_0441 -- 補液量07
  ,null as ihdf_dev_a_0442 -- 補液量08
  ,null as ihdf_dev_a_0443 -- 補液量09
  ,null as ihdf_dev_a_0444 -- 補液量10
  ,null as ihdf_dev_a_0445 -- 補液量11
  ,null as ihdf_dev_a_0446 -- 補液量12
  ,null as ihdf_dev_a_0447 -- 補液量13
  ,null as ihdf_dev_a_0448 -- 補液量14
  ,null as ihdf_dev_a_0449 -- 補液量15
  ,null as ihdf_dev_a_0450 -- 補液量16
  ,null as ihdf_dev_a_0451 -- 回収量01
  ,null as ihdf_dev_a_0452 -- 回収量02
  ,null as ihdf_dev_a_0453 -- 回収量03
  ,null as ihdf_dev_a_0454 -- 回収量04
  ,null as ihdf_dev_a_0455 -- 回収量05
  ,null as ihdf_dev_a_0456 -- 回収量06
  ,null as ihdf_dev_a_0457 -- 回収量07
  ,null as ihdf_dev_a_0458 -- 回収量08
  ,null as ihdf_dev_a_0459 -- 回収量09
  ,null as ihdf_dev_a_0460 -- 回収量10
  ,null as ihdf_dev_a_0461 -- 回収量11
  ,null as ihdf_dev_a_0462 -- 回収量12
  ,null as ihdf_dev_a_0463 -- 回収量13
  ,null as ihdf_dev_a_0464 -- 回収量14
  ,null as ihdf_dev_a_0465 -- 回収量15
  ,null as ihdf_dev_a_0466 -- 回収量16
	,ord_main.ord_no as ord_no_t
from
  ord_main
  inner join latest_otc on ord_main.ord_no = latest_otc.ord_no
  cross join dialyzer_record
where ord_main.ord_no = @ordNo and ord_main.is_del = ''0''
 and ord_main.rst_dialysis_state <>''0''


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
	DATA.ord_no_t = time_info.ordnob', 2, '[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "0", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "0", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "0", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "1", "disp": "使用しない", "item": "使用しない"}, {"code": "2", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "52", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.7", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "0", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "0", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "0", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "2", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "0", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "1", "disp": "降圧測定", "item": "降圧測定"}, {"code": "2", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "0", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2:34", "can_calc": "0", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3:45", "can_calc": "0", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "0", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "0", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "ufr_dev_a_0290", "data_name": "UFRプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "07:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血（除水なし）", "can_calc": "0", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血（除水あり）", "item": "片側脱血（除水あり）"}, {"code": "2", "disp": "片側脱血（除水なし）", "item": "片側脱血（除水なし）"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ord_treat_condition_335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_335", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "ord_treat_condition_287", "data_name": "KoA", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_287", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "ord_treat_condition_187", "data_name": "ダイアライザ 尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_187", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ord_treat_condition_188", "data_name": "ダイアライザ 血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_188", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "ord_treat_condition_189", "data_name": "ダイアライザ 透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_189", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "0", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "1", "disp": "流量設定", "item": "流量設定"}, {"code": "2", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：装置設定 @ordNo 使用', '2020-03-31 23:59:59', '2024-06-06 01:41:24.854', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (104, 'WITH DATA AS (


	with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main
  where
    ord_main.pat_id = (select pat_id from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state<>''0'')
    and rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and rst_start_date <= (select rst_start_date from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state<>''0'')
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_mae as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date as before_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as before_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as before_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as before_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as before_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 5
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_hist_ato as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date  as after_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as after_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as after_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as after_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as after_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 6
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_array_tbl as (
  select
    array_agg(ord_hist_mae.ord_no order by ord_hist_mae.rst_start_date desc) as array_ord_no
    ,array_agg(ord_hist_mae.rst_start_date order by ord_hist_mae.rst_start_date desc) as array_rst_start_date

    ,array_agg(before_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_before_vital_measure_date
    ,array_agg(before_bp_high order by ord_hist_mae.rst_start_date desc) as array_before_bp_high
    ,array_agg(before_bp_low order by ord_hist_mae.rst_start_date desc) as array_before_bp_low
    ,array_agg(before_bp_ave order by ord_hist_mae.rst_start_date desc) as array_before_bp_ave
    ,array_agg(before_pulse order by ord_hist_mae.rst_start_date desc) as array_before_pulse

    ,array_agg(after_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_after_vital_measure_date
    ,array_agg(after_bp_high order by ord_hist_mae.rst_start_date desc) as array_after_bp_high
    ,array_agg(after_bp_low order by ord_hist_mae.rst_start_date desc) as array_after_bp_low
    ,array_agg(after_bp_ave order by ord_hist_mae.rst_start_date desc) as array_after_bp_ave
    ,array_agg(after_pulse order by ord_hist_mae.rst_start_date desc) as array_after_pulse
  from
    ord_hist_mae
    inner join ord_hist_ato
      on ord_hist_mae.ord_no = ord_hist_ato.ord_no
)

select
  ord_no as ord_no_t
	,array_ord_no[1] as ord_no_prev
  ,array_ord_no[2] as ord_no_prev_prev
  ,array_rst_start_date[1] as rst_start_date_prev
  ,array_rst_start_date[2] as rst_start_date_prev_prev

  ,array_before_vital_measure_date[1] as before_vital_measure_date_prev
  ,array_before_vital_measure_date[2] as before_vital_measure_date_prev_prev
  ,array_before_bp_high[1] as before_bp_high_prev
  ,array_before_bp_high[2] as before_bp_high_prev_prev
  ,array_before_bp_low[1] as before_bp_low_prev
  ,array_before_bp_low[2] as before_bp_low_prev_prev
  ,array_before_bp_ave[1] as before_bp_ave_prev
  ,array_before_bp_ave[2] as before_bp_ave_prev_prev
  ,array_before_pulse[1] as before_pulse_prev
  ,array_before_pulse[2] as before_pulse_prev_prev

  ,array_after_vital_measure_date[1] as after_vital_measure_date_prev
  ,array_after_vital_measure_date[2] as after_vital_measure_date_prev_prev
  ,array_after_bp_high[1] as after_bp_high_prev
  ,array_after_bp_high[2] as after_bp_high_prev_prev
  ,array_after_bp_low[1] as after_bp_low_prev
  ,array_after_bp_low[2] as after_bp_low_prev_prev
  ,array_after_bp_ave[1] as after_bp_ave_prev
  ,array_after_bp_ave[2] as after_bp_ave_prev_prev
  ,array_after_pulse[1] as after_pulse_prev
  ,array_after_pulse[2] as after_pulse_prev_prev

  ,array_before_bp_high[1]::text || ''/'' || array_before_bp_low[1]::text || ''/'' || array_before_bp_ave[1] || ''('' || array_before_pulse[1]::text || '')'' as before_bp_summary_prev
  ,array_before_bp_high[2]::text || ''/'' || array_before_bp_low[2]::text || ''/'' || array_before_bp_ave[2] || ''('' || array_before_pulse[2]::text || '')'' as before_bp_summary_prev_prev

  ,array_after_bp_high[1]::text || ''/'' || array_after_bp_low[1]::text || ''/'' || array_after_bp_ave[1] || ''('' || array_after_pulse[1]::text || '')'' as after_bp_summary_prev
  ,array_after_bp_high[2]::text || ''/'' || array_after_bp_low[2]::text || ''/'' || array_after_bp_ave[2] || ''('' || array_after_pulse[2]::text || '')'' as after_bp_summary_prev_prev
from
  ord_array_tbl,hist_ord_nos



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
	', 2, '[{"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev", "data_name": "前血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev", "data_name": "前血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev", "data_name": "前血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev", "data_name": "前脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev", "data_name": "前血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev", "data_name": "後血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev", "data_name": "後血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev", "data_name": "後血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev", "data_name": "後脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev", "data_name": "後血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev_prev", "data_name": "前血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev_prev", "data_name": "前血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev_prev", "data_name": "前血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev_prev", "data_name": "前脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev_prev", "data_name": "前血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev_prev", "data_name": "後血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev_prev", "data_name": "後血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev_prev", "data_name": "後血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev_prev", "data_name": "後脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev_prev", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev_prev", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev_prev", "data_name": "後血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：血圧情報(過去実績) @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:00.634', NULL);
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
	,ord_no
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
)

select
  *
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

	DATA.*,time_info.ind_end_date,time_info.ind_end_date_time,time_info.rst_start_date,time_info.rst_end_date
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no = time_info.ordnob
	;
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：除水情報/風袋・除水補正 @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:05.469', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (115, 'WITH DATA AS (




with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <>''0''
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
, tmp2 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treat_staff_info) as rtsi
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <>''0''
)
, staff_tbl as
(
  select
    *
    ,date_trunc(''minute'', (rtsi->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp2
)

select
  oxygen_tbl.ord_no as ord_no_t
	,oxygen_tbl.ord_no
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then occur_date else null -- 開始
  end as start_date
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then occur_date else null -- 終了
  end as end_date
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then rtsi->>''treat_staff_name'' else null -- 開始
  end as start_staff
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rtsi->>''treat_staff_name'' else null -- 終了
  end as end_staff
  ,case
    when bit_length(rti->>''oxygen_speed'') <> 0 then rti->>''oxygen_speed'' else null
  end as speed
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rti->>''oxygen_amount'' else null
  end as amount
from
  oxygen_tbl
  left outer join staff_tbl
    on oxygen_tbl.ord_no = staff_tbl.ord_no and oxygen_tbl.date_trunc_occur_date = staff_tbl.date_trunc_occur_date
order by
  ord_no, occur_date
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
	', 2, '[{"preview": "09:47", "can_calc": "0", "data_code": "start_date", "data_name": "開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:00", "can_calc": "0", "data_code": "end_date", "data_name": "終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦２", "can_calc": "0", "data_code": "start_staff", "data_name": "開始者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_staff", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦３", "can_calc": "0", "data_code": "end_staff", "data_name": "終了者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_staff", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "speed", "data_name": "吸入速度", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15", "can_calc": "1", "data_code": "amount", "data_name": "吸入量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：酸素吸入 @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:00.634', NULL);
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
	', 2, '[{"preview": "16", "can_calc": "1", "data_code": "total_amount", "data_name": "吸入総量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入総量", "field_name": "total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：酸素吸入総量 @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:02.696', NULL);
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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "加算", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "addition_name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "addition_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：加算 @ordNo 使用', '2020-03-31 23:59:59', '2023-07-17 21:02:02.696', NULL);
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
             and pat_id = @patId
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = @facilityCd
    group by b.ord_no
    , mni_monitor.data_type
        LIMIT 1
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 予測時間_除水
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 予測時間_透析
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd
), f AS (
    select e.*
--     to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
--     , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
--     , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_除水完了,0) AS 予測時間_除水
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_透析完了,0) AS 予測時間_透析
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_補液完了,0) AS 予測時間_補液 
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
),j as(
    select pat_event.pat_id, count(*) as observation_records_num 
        from  pat_event INNER JOIN b on (pat_event.pat_id = b.pat_id) AND (pat_event.ord_no = b.ord_no)
        WHERE pat_event.ord_no > 0 AND pat_event.facility_cd <> ''null'' AND pat_event.use_type = 2 AND  pat_event.event_status = ''1'' AND pat_event.is_newest = ''1'' AND pat_event.is_del = ''0''
        GROUP BY pat_event.pat_id
)
,k as (select h.ord_no, machine_status as machine_status , machine_serial from mnt_machine_state INNER JOIN h on mnt_machine_state.bed_cd = h.bed_cd)
,q as (
   select
     e.ord_no,
     to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
     from e
     inner join mnt_machine_state on
     e.facility_cd = mnt_machine_state.facility_cd and
     e.machine_type_cd = mnt_machine_state.machine_type_cd and
     e.machine_serial = mnt_machine_state.machine_type_cd and
     e.ord_no = mnt_machine_state.ord_no and
     e.pat_id = mnt_machine_state.pat_id
)
,p as (select com_format_cd,com_type,h.ord_no from mst_machine INNER JOIN h on h.machine_no = mst_machine.machine_no)
,l as (select pat_ind_approve.ord_no, pat_ind_approve.is_content_changed_for_map as is_content_changed_for_map from pat_ind_approve INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as dosing_status
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
 ,bed_group as (
 SELECT
        index_no AS bed_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_group_code,
        order_cd ->> ''name'' AS bed_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
        AND master_physical_name = ''mst_room_bed_group''
 )
  ,bed as (
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
 )
,kur as (
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
 )
 ,patgrou as (
 SELECT
        index_no AS pat_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS pat_group_code,
        order_cd ->> ''name'' AS pat_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
        AND master_physical_name = ''pat_group''
 )
 ,mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 )
select b.ord_no, b.treat_date
, b.pat_id AS pat_id
, b.pat_id AS pat_id1
, b.pat_id AS pat_id2
, b.pat_id AS pat_id3
, b.pat_id AS pat_id4
, b.pat_id AS pat_id5
, MIN(patgrou.pat_group_order) AS pat_group_order
, pt.is_infect
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
, b.rst_cond_info::json#>>''{3, value}'' AS target_weight
, CASE WHEN b.rst_cond_info::json#>>''{3, value}'' is not null AND b.rst_cond_info::json#>>''{3, value}'' <> ''null'' THEN CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) 
  ELSE CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - b.rst_dw 
  END AS target_weight_2
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS forecast_end_water_removal_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS forecast_end_dialysis_end
, b.rst_end_date
, b.rst_cond_info#>>''{1, value}'' AS treatment_minute
, b.rst_cond_info#>>''{1, value}'' AS treatment_time
, CASE WHEN b.rst_dialysis_state <> ''3'' THEN 0
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN f.予測時間_除水 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN f.予測時間_透析 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
       ELSE COALESCE(f.予測時間_補液,0) - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
  END AS delay_time
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = ''0'' THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
             WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
             END AS progress_rate 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->''90'' AS bpbefore_max
, BpBefore.monitor_data->''91'' AS bpbefore_min
, BpBefore.monitor_data->''92'' AS bpbefore_avg
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS bpbefore
, BpBefore.monitor_data->''93'' AS pulse_before
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS bpcurrent
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
, BpAfter.monitor_data->''90'' AS bpafter_max
, BpAfter.monitor_data->''91'' AS bpafter_min
, BpAfter.monitor_data->''92'' AS bpafter_avg
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS bpafter
, BpAfter.monitor_data->''93'' AS pulse_after
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS pat_confirm
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS plan_end
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS rounds_status
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS rounds_data
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS water_removal_limit
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS dialyzer
, b.rst_cond_info#>>''{6, value_name_1}'' AS adsorption_column
, b.rst_cond_info#>>''{7, value_name_1}'' AS primary_membrane
, b.rst_cond_info#>>''{8, value_name_1}'' AS Second_membrane
, b.rst_cond_info#>>''{9, value_name_1}'' AS needles_a
, b.rst_cond_info#>>''{10, value_name_1}'' AS needles_v
, b.rst_cond_info#>>''{11, value_name_1}'' AS needles_sn
, CASE WHEN b.rst_cond_info#>>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS single_needle_use
, b.rst_cond_info#>>''{13, value_name_1}'' AS blood_circuit
, b.rst_cond_info#>>''{14, value}'' AS blood_flow
, b.rst_cond_info#>>''{15, value_name_1}'' AS dialysate
, b.rst_cond_info#>>''{16, value}'' AS dialysate_flow
, b.rst_cond_info#>>''{17, value}'' AS dialysate_volume
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS dialysate_temperature
, b.rst_cond_info#>>''{19, value_name_1}'' AS fluid_replenishment
, b.rst_cond_info#>>''{20, value}'' AS fr_volume
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS fr_selection
, b.rst_cond_info#>>''{22, value}'' AS fr_use_num
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS fr_temperature
, b.rst_cond_info#>>''{24, value}'' AS fr_velocity
, b.rst_cond_info#>>''{25, value_name_1}'' AS anticoagulants
, b.rst_cond_info#>>''{26, value}'' AS anticoagulants_oneshot_quantity
, b.rst_cond_info#>>''{27, value}'' AS anticoagulants_duration_rate
, b.rst_cond_info#>>''{28, value}'' AS anticoagulants_total_volume
-- , CASE WHEN b.rst_cond_info#>>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip_usage_selection
, b.rst_cond_info#>>''{29, value}'' AS ip_usage_selection
-- , null AS ip_start
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ip_start
, b.rst_cond_info#>>''{30, value}'' AS ip_start
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ip_oneshot_quantity
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip_velocity
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip_velocity_max
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ip_oneshot_quantity
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip_velocity
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip_velocity_max
-- , CASE WHEN b.rst_cond_info#>>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS auto_oneshot
, b.rst_cond_info#>>''{34, value}'' AS auto_oneshot
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_auto_off
, b.rst_cond_info#>>''{35, value}'' AS ip_auto_off
, b.rst_cond_info#>>''{36, value}'' AS ip_auto_cycle_time
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{37, value}'' AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{38, value}'' AS ip_power_ok_monitor_off_time
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
, BpBefore.monitor_data
--, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS leftovers
, b.pat_id AS hosp_pat_id
, b.rst_end_date as treatment_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end_fr_end
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS sttc_vns_prssr
, b.rst_dw AS last_weight_after
, b.rst_weight_info #>> ''{ihdf_pll}'' AS ihdf_pll
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS off_water_total
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,f.monitor_data->''Z212'' AS device_self_diagnosis
,b.rst_bed_name AS bed_name
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS weight_before_tare_total
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS weight_after_tare_total
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS complaint_latest
, o.treatment AS treatment_latest
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as dialysates_used_num
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS weight_before_dw
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS weight_before_weight_target
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS weight_before_weight_after
,CASE WHEN b.rst_dw is NULL OR b.rst_dw = 0 THEN 0 ELSE(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 END AS per_increase
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as amount_increase
,CASE WHEN CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL) > 0 THEN round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  ELSE 0 END as achievement_rate
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as leftovers_expected 
,COALESCE(j.observation_records_num,0) as observation_records_num
,k.machine_status
,l.is_content_changed_for_map
,m.dosing_status
,n.rate as recirculation_rate_eff 
,bed.bed_order
,kur.kur_order
,MIN(rb1.bed_group_order) as bed_group_order
,b.rst_start_date as start_time
,b.rst_end_date as end_time
-- 終了予定
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS  ind_end_date
-- 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
END AS ind_end_date_time
from b
LEFT outer JOIN j on (b.pat_id = j.pat_id)
LEFT JOIN d on (b.ord_no = d.ord_no)
LEFT JOIN e on (b.ord_no = e.ord_no)
LEFT JOIN k on (b.ord_no = k.ord_no)
LEFT JOIN q on (b.ord_no = q.ord_no)
LEFT JOIN p on (b.ord_no = p.ord_no)
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
    -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || b.rst_bed_cd) :: jsonb
            LEFT OUTER JOIN bed_group AS rb1 ON rbg1.room_bed_group_cd = rb1.bed_group_code
            LEFT OUTER JOIN bed ON bed.bed_code = b.rst_bed_cd
            LEFT OUTER JOIN kur ON kur.kur_code = b.rst_kur_cd
            LEFT OUTER JOIN pat_main as pt ON b.pat_id = pt.pat_id
            LEFT OUTER JOIN pat_group_detail as pgd ON b.pat_id = pgd.pat_id
            LEFT OUTER JOIN patgrou ON pgd.pat_group_cd = patgrou.pat_group_code
group by 
b.ord_no
, b.treat_date
, b.pat_id
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw
, mnt_machine_state.process_state
, b.rst_cond_info
, b.rst_weight_info
, b.rst_dialysis_state
, f.残り時間_除水完了
, f.残り時間_透析完了
, f.残り時間_補液完了
, f.予測時間_除水
, f.予測時間_透析
, f.予測時間_補液
, p.com_format_cd
, p.com_type
, d.data_type
, q.残り時間_透析完了
, e.残り時間_透析完了
, bpbefore.monitor_data
, bpcurrent.monitor_data
, b.rst_charge_user_info
, b.rst_puncture_user_info
, b.rst_return_user_info
, bpafter.monitor_data
, b.rst_rounds_info
, f.monitor_data
, bpbefore.ord_no
, b.rst_off_water_info
, b.rst_tare_info
, b.rst_bed_name
, b.rst_complaint_info
, o.treatment
, j.observation_records_num
, k.machine_status
, l.is_content_changed_for_map
, m.dosing_status
, n.rate
, bed.bed_order
, kur.kur_order
, e.経過時間
, f.bio_moni_ctl_no
, b.rst_start_date
, b.rst_end_date    
, pt.is_infect      
order by b.treat_date, b.ord_no, f.bio_moni_ctl_no
', 2, '[{"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_sex", "target_var": "@patId"}, "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_abo", "target_var": "@patId"}, "data_code": "pat_blood_type_abo", "data_name": "血液型(ABO)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id3", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_rh", "target_var": "@patId"}, "data_code": "pat_blood_type_rh", "data_name": "血液型(Rh)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id4", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name_kana", "target_var": "@patId"}, "data_code": "pat_name_kana", "data_name": "フリガナ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id5", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "treat_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午後", "can_calc": "0", "data_code": "ind_kur_name", "data_name": "クール", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ind_kur_name", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "運転", "can_calc": "0", "data_code": "process_state", "data_name": "状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "process_state", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight_2", "data_name": "目標体重から", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重から", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_start_date", "data_name": "治療開始", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_start_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "ind_end_date_time", "data_name": "終了予測", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_water_removal_end", "data_name": "終了予測(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_除水完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_dialysis_end", "data_name": "終了予測(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_透析完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_end_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "治療時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "treatment_minute", "data_name": "治療時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間分", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "delay_time", "data_name": "遅れ時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "遅れ時間", "disp_format": "H:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "progress_rate", "data_name": "進捗率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "進捗率", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_max", "data_name": "前血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_min", "data_name": "前血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_avg", "data_name": "前血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpbefore", "data_name": "前血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_before", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpcurrent", "data_name": "現在血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "現在血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_1", "data_name": "担当者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_1", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_2", "data_name": "担当者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_2", "data_name": "担当2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date", "data_name": "穿刺日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_1", "data_name": "穿刺者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_1", "data_name": "穿刺1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_2", "data_name": "穿刺者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_2", "data_name": "穿刺2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date", "data_name": "返血日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_1", "data_name": "返血者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_1", "data_name": "返血1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_2", "data_name": "返血者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_2", "data_name": "返血2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_after", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_max", "data_name": "後血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_min", "data_name": "後血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_avg", "data_name": "後血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpafter", "data_name": "後血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_after", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_target", "data_name": "除水目標", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "water_removal_target", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "pat_confirm", "data_name": "患者確認", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "患者確認", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-03-25T09:20:30.000+09:00", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-12-10 01:56:01", "can_calc": "0", "data_code": "ind_end_date", "data_name": "終了予定", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予定", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "rounds_status", "data_name": "回診状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診状態", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未回診", "can_calc": "0", "data_code": "rounds_data", "data_name": "回診データ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診データ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ctr", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "右", "can_calc": "0", "data_code": "va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "va", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "除水量制限", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装[FDY-21GW]", "can_calc": "0", "data_code": "dialyzer", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ダイアライザ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト吸着カラム１", "can_calc": "0", "data_code": "adsorption_column", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "吸着カラム", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_membrane", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "一次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "Second_membrane", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "二次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針１", "can_calc": "0", "data_code": "needles_a", "data_name": "穿刺針(A針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_a針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針２", "can_calc": "0", "data_code": "needles_v", "data_name": "穿刺針(V針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_v針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針3", "can_calc": "0", "data_code": "needles_sn", "data_name": "穿刺針(SN)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_sn", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "single_needle_use", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "シングルニードル使用", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト血液回路１", "can_calc": "0", "data_code": "blood_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "血液回路", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "血流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト透析液１", "can_calc": "0", "data_code": "dialysate", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "透析液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "349", "can_calc": "0", "data_code": "dialysate_volume", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.0", "can_calc": "0", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液１", "can_calc": "0", "data_code": "fluid_replenishment", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "fr_volume", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fr_selection", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "fr_use_num", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液使用数", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.9", "can_calc": "0", "data_code": "fr_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "fr_velocity", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤１", "can_calc": "0", "data_code": "anticoagulants", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_oneshot_quantity", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤ワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_duration_rate", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip_usage_selection", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "IP使用選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "治療状況", "field_name": "IPスタート", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "ip_oneshot_quantity", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IPワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度最大値", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_oneshot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "自動ワンショット", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源自動切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_power_ok_monitor_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "ip_power_ok_monitor_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m000", "data_name": "[モニタ]工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m000", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "m001", "data_name": "[モニタ]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m001", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "m002", "data_name": "[モニタ]経過時間(ECUM)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m002", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m003", "data_name": "[モニタ]残り時間(除水完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m003", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "m004", "data_name": "[モニタ]残り時間(透析完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m004", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m005", "data_name": "[モニタ]除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m005", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.55", "can_calc": "0", "data_code": "m006", "data_name": "[モニタ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m006", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3.0", "can_calc": "0", "data_code": "m007", "data_name": "[モニタ]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m007", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "0", "data_code": "m009", "data_name": "[モニタ]IP総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m009", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.0", "can_calc": "0", "data_code": "m010", "data_name": "[モニタ]IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m010", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "m011", "data_name": "[モニタ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m011", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "m012", "data_name": "[モニタ]透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m012", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m013", "data_name": "[モニタ]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m013", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m014", "data_name": "[モニタ]ダイアライザー入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m014", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "m015", "data_name": "[モニタ]ダイアライザー差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m015", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "m016", "data_name": "[モニタ]血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m016", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.0", "can_calc": "0", "data_code": "m017", "data_name": "[モニタ]⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m017", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.40", "can_calc": "0", "data_code": "m018", "data_name": "[モニタ]バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m018", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "m019", "data_name": "[モニタ]透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m019", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16", "can_calc": "0", "data_code": "m020", "data_name": "[モニタ]Na濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m020", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.0", "can_calc": "0", "data_code": "m021", "data_name": "[モニタ]透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m021", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "18", "can_calc": "0", "data_code": "m022", "data_name": "[モニタ]透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m022", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.9", "can_calc": "0", "data_code": "m023", "data_name": "[モニタ]漏血量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m023", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m024", "data_name": "[モニタ]給液圧(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m024", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m025", "data_name": "[モニタ]給液圧(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m025", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22.00", "can_calc": "0", "data_code": "m026", "data_name": "[モニタ]UFR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m026", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "m027", "data_name": "[モニタ]UFR低下率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m027", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "24.00", "can_calc": "0", "data_code": "m028", "data_name": "[モニタ]初期UFR測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m028", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25.0", "can_calc": "0", "data_code": "m029", "data_name": "[モニタ]TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m029", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "26", "can_calc": "0", "data_code": "m030", "data_name": "[モニタ]透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m030", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m031", "data_name": "[モニタ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m031", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "28.00", "can_calc": "0", "data_code": "m032", "data_name": "[モニタ]除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m032", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "0", "data_code": "m033", "data_name": "[モニタ]除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m033", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m034", "data_name": "[モニタ]透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m034", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "31", "can_calc": "0", "data_code": "m035", "data_name": "[モニタ]透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m035", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "32", "can_calc": "0", "data_code": "m036", "data_name": "[モニタ]血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m036", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m037", "data_name": "[モニタ]IP速度設定", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m037", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.34", "can_calc": "0", "data_code": "m038", "data_name": "[モニタ]Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m038", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "0", "data_code": "m039", "data_name": "[モニタ]静脈圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m039", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36", "can_calc": "0", "data_code": "m040", "data_name": "[モニタ]静脈圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m040", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37", "can_calc": "0", "data_code": "m041", "data_name": "[モニタ]透析液圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m041", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "m042", "data_name": "[モニタ]透析液圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m042", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m043", "data_name": "[モニタ]TMP警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m043", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m044", "data_name": "[モニタ]TMP警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m044", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m045", "data_name": "[モニタ]ダイアライザー入口圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m045", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "0", "data_code": "m046", "data_name": "[モニタ]ダイアライザー入口圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m046", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "43", "can_calc": "0", "data_code": "m047", "data_name": "[モニタ]ダイアライザー差圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m047", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "44", "can_calc": "0", "data_code": "m048", "data_name": "[モニタ]ダイアライザー差圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m048", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-45.0", "can_calc": "0", "data_code": "m049", "data_name": "[モニタ]⊿BV低下警報点１", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m049", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-46.0", "can_calc": "0", "data_code": "m050", "data_name": "[モニタ]⊿BV低下警報点２", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m050", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-17.0", "can_calc": "0", "data_code": "m051", "data_name": "[モニタ]⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m051", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "48", "can_calc": "0", "data_code": "m052", "data_name": "[モニタ]BPM関連データ9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m052", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-49", "can_calc": "0", "data_code": "m053", "data_name": "[モニタ]BPM関連データ10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m053", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "m054", "data_name": "[モニタ]バイカーボ濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m054", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.10", "can_calc": "0", "data_code": "m055", "data_name": "[モニタ]バイカーボ濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m055", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "m056", "data_name": "[モニタ]透析液濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m056", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "53.0", "can_calc": "0", "data_code": "m057", "data_name": "[モニタ]透析液濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m057", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "54", "can_calc": "0", "data_code": "m058", "data_name": "[モニタ]Na濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m058", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55", "can_calc": "0", "data_code": "m059", "data_name": "[モニタ]Na濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m059", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.0", "can_calc": "0", "data_code": "m060", "data_name": "[モニタ]透析液温度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m060", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.0", "can_calc": "0", "data_code": "m061", "data_name": "[モニタ]透析液温度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m061", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.8", "can_calc": "0", "data_code": "m062", "data_name": "[モニタ]漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m062", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "59", "can_calc": "0", "data_code": "m063", "data_name": "[モニタ]給水圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m063", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "m064", "data_name": "[モニタ]給水圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m064", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.10", "can_calc": "0", "data_code": "m065", "data_name": "[モニタ]初期UFR警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m065", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "62.00", "can_calc": "0", "data_code": "m066", "data_name": "[モニタ]初期UFR警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m066", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "63", "can_calc": "0", "data_code": "m067", "data_name": "[モニタ]UFR低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m067", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.60", "can_calc": "0", "data_code": "m068", "data_name": "[モニタ]Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m068", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.50", "can_calc": "0", "data_code": "m069", "data_name": "[モニタ]運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m069", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.5", "can_calc": "0", "data_code": "m070", "data_name": "[モニタ]補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m070", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.68", "can_calc": "0", "data_code": "m071", "data_name": "[モニタ]補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m071", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "69.00", "can_calc": "0", "data_code": "m072", "data_name": "[モニタ]補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m072", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.70", "can_calc": "0", "data_code": "m073", "data_name": "[モニタ]補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m073", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.7", "can_calc": "0", "data_code": "m074", "data_name": "[モニタ]補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m074", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30.0", "can_calc": "0", "data_code": "m075", "data_name": "[モニタ]補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m075", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.30", "can_calc": "0", "data_code": "m076", "data_name": "[モニタ]濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m076", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "74.00", "can_calc": "0", "data_code": "m077", "data_name": "[モニタ]荷重計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m077", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m078", "data_name": "[モニタ]残り時間(補液完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m078", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m079", "data_name": "[モニタ]URR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m079", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "77.0", "can_calc": "0", "data_code": "m080", "data_name": "[モニタ]⊿BV変化率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m080", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "78.00", "can_calc": "0", "data_code": "m081", "data_name": "[モニタ]PWI", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m081", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "79", "can_calc": "0", "data_code": "m082", "data_name": "[モニタ]BPM関連データ1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m082", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "0", "data_code": "m083", "data_name": "[モニタ]BPM関連データ2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m083", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m084", "data_name": "[モニタ]BPM関連データ3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m084", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82.0", "can_calc": "0", "data_code": "m085", "data_name": "[モニタ]⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m085", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "83.0", "can_calc": "0", "data_code": "m086", "data_name": "[モニタ]⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m086", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "84", "can_calc": "0", "data_code": "m087", "data_name": "[モニタ]BPM関連データ6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m087", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "0", "data_code": "m088", "data_name": "[モニタ]PRR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m088", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m089", "data_name": "[モニタ]再循環率測定結果(BVMS連携用)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m089", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "m095", "data_name": "[モニタ]⊿BV5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m095", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "0", "data_code": "m096", "data_name": "[モニタ]⊿BV最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m096", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "m097", "data_name": "[モニタ]推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m097", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m098", "data_name": "[モニタ]血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m098", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m100", "data_name": "[モニタ]⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m100", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m101", "data_name": "[モニタ]vHt", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m102", "data_name": "[モニタ]LDQb", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz11", "data_name": "[ACHΣ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz11", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz21", "data_name": "[ACHΣ]工程状態", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz21", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz31", "data_name": "[ACHΣ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz31", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz41", "data_name": "[ACHΣ]血液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz41", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz51", "data_name": "[ACHΣ]シリンジ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz51", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz61", "data_name": "[ACHΣ]ろ過流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz61", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz71", "data_name": "[ACHΣ]透析液/ドレン流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz71", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz81", "data_name": "[ACHΣ]補液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz81", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz91", "data_name": "[ACHΣ]透析液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz91", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz101", "data_name": "[ACHΣ]補液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz111", "data_name": "[ACHΣ]現在除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz111", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz121", "data_name": "[ACHΣ]現在血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz121", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz131", "data_name": "[ACHΣ]現在ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz131", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz141", "data_name": "[ACHΣ]現在透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz141", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz151", "data_name": "[ACHΣ]現在補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz151", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz161", "data_name": "[ACHΣ]治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz161", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz171", "data_name": "[ACHΣ]シリンジ積算量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz171", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz181", "data_name": "[ACHΣ]目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz181", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz191", "data_name": "[ACHΣ]目標血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz191", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz201", "data_name": "[ACHΣ]目標ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz201", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz211", "data_name": "[ACHΣ]目標透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz211", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz221", "data_name": "[ACHΣ]目標補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz221", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz231", "data_name": "[ACHΣ]目標治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz231", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz241", "data_name": "[ACHΣ]脱血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz241", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz251", "data_name": "[ACHΣ]入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz251", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz261", "data_name": "[ACHΣ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz261", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz271", "data_name": "[ACHΣ]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz271", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz281", "data_name": "[ACHΣ]排気圧/2次膜圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz281", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz291", "data_name": "[ACHΣ]TMP/TMP1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz291", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz301", "data_name": "[ACHΣ]TMP2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz301", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz311", "data_name": "[ACHΣ]差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz311", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz321", "data_name": "[ACHΣ]気泡検知警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz321", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz331", "data_name": "[ACHΣ]漏血警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz331", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz341", "data_name": "[ACHΣ]加温器警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz341", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz351", "data_name": "[ACHΣ]脱血圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz351", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz361", "data_name": "[ACHΣ]入口圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz361", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz371", "data_name": "[ACHΣ]静脈圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz371", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz381", "data_name": "[ACHΣ]ろ過圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz381", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz391", "data_name": "[ACHΣ]排気圧/2次膜圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz391", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz401", "data_name": "[ACHΣ]TMP警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz401", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz411", "data_name": "[ACHΣ]TMP2警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz411", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz421", "data_name": "[ACHΣ]差圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz421", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz431", "data_name": "[ACHΣ]その他警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz431", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz441", "data_name": "[ACHΣ]クエン酸流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz441", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz451", "data_name": "[ACHΣ]現在クエン酸量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz451", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz12", "data_name": "[KM8900]測定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz12", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz22", "data_name": "[KM8900]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz22", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz32", "data_name": "[KM8900]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz32", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz42", "data_name": "[KM8900]測定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz42", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz52", "data_name": "[KM8900]圧力上限警報設定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz52", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz62", "data_name": "[KM8900]圧力上限警報設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz62", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz72", "data_name": "[KM8900]圧力上限警報設定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz72", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz82", "data_name": "[KM8900]圧力上限警報設定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz82", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz92", "data_name": "[KM8900]流量情報BP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz92", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz102", "data_name": "[KM8900]流量情報PP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz112", "data_name": "[KM8900]流量情報DP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz112", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz122", "data_name": "[KM8900]流量情報BP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz122", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz132", "data_name": "[KM8900]流量情報PP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz132", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz142", "data_name": "[KM8900]流量情報DP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz142", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz152", "data_name": "[KM8900]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz152", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz162", "data_name": "[KM8900]流量情報血漿処理目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz162", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz172", "data_name": "[KM8900]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz172", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz182", "data_name": "[KM8900]その他情報バランス", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz182", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz192", "data_name": "[KM8900]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz192", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz202", "data_name": "[KM8900]その他情報アラーム番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz202", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz212", "data_name": "[KM8900]その他情報自己診断番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz212", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz222", "data_name": "[KM8900]その他情報モード(用途)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz222", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz232", "data_name": "[KM8900]その他情報工程情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz232", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz13", "data_name": "[iQ21]治療経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz13", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz23", "data_name": "[iQ21]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz23", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz33", "data_name": "[iQ21]ろ過ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz33", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz43", "data_name": "[iQ21]補液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz43", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz53", "data_name": "[iQ21]透析液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz53", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz63", "data_name": "[iQ21]血液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz63", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz73", "data_name": "[iQ21]シリンジポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz73", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz83", "data_name": "[iQ21]除水量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz83", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz93", "data_name": "[iQ21]ろ過量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz93", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz103", "data_name": "[iQ21]補液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz113", "data_name": "[iQ21]透析液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz113", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz123", "data_name": "[iQ21]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz123", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz133", "data_name": "[iQ21]シリンジポンプ積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz133", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz143", "data_name": "[iQ21]採血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz143", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz153", "data_name": "[iQ21]動脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz153", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz163", "data_name": "[iQ21]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz163", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz173", "data_name": "[iQ21]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz173", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz183", "data_name": "[iQ21]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz183", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz193", "data_name": "[iQ21]分離ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz193", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz203", "data_name": "[iQ21]返漿ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz203", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz213", "data_name": "[iQ21]ドレンポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz213", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz223", "data_name": "[iQ21]分離量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz223", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz233", "data_name": "[iQ21]返漿量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz233", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz243", "data_name": "[iQ21]ドレン量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz243", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz253", "data_name": "[iQ21]血漿圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz253", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz263", "data_name": "[iQ21]血漿入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz263", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz14", "data_name": "[KM9000]測定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz14", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz24", "data_name": "[KM9000]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz24", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz34", "data_name": "[KM9000]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz34", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz44", "data_name": "[KM9000]測定値ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz44", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz54", "data_name": "[KM9000]測定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz54", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz64", "data_name": "[KM9000]設定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz64", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz74", "data_name": "[KM9000]設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz74", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz84", "data_name": "[KM9000]設定値返血圧・上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz84", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz94", "data_name": "[KM9000]設定値返血圧・下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz94", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz104", "data_name": "[KM9000]設定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz104", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz114", "data_name": "[KM9000]設定値除水設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz114", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz124", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz124", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz134", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz134", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz144", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz144", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz154", "data_name": "[KM9000]流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz154", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz164", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz164", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz174", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz174", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz184", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz184", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz194", "data_name": "[KM9000]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz194", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz204", "data_name": "[KM9000]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz204", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz214", "data_name": "[KM9000]その他情報除水差分/重量値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz214", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz224", "data_name": "[KM9000]その他情報初期診断情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz224", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz234", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz234", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz244", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz244", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz254", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz254", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz264", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報4", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz264", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz274", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報5", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz274", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz284", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz284", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz294", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報7", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz294", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz304", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報8", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz304", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz314", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz314", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz324", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz324", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz334", "data_name": "[KM9000]その他情報注意情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz334", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz344", "data_name": "[KM9000]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz344", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz354", "data_name": "[KM9000]その他情報用途", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz354", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz364", "data_name": "[KM9000]その他情報工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz364", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz374", "data_name": "[KM9000]その他情報動作日、時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz374", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "dw", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "iapratio", "data_name": "IAP Ratio", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "iapratio", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "ihdf_pll", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ihdf引き残し量", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_cycle_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源自動切り時間", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers", "data_name": "引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "引き残し", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "observation_records_num", "data_name": "観察記録件数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "観察記録件数", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "machine_status", "data_name": "警報・報知", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "警報・報知", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_after_tare_total", "data_name": "後体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "0", "data_code": "anticoagulants_total_volume", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続総量", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "0", "data_code": "recirculation_rate_eff", "data_name": "再循環率有効値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "再循環率有効値", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint_latest", "data_name": "最新愁訴", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新愁訴", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treatment_latest", "data_name": "最新処置", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新処置", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "はい", "can_calc": "0", "data_code": "is_content_changed_for_map", "data_name": "指示変更", "data_type": "string", "conv_table": [{"code": 0, "disp": "変更なし", "item": "変更なし"}, {"code": 1, "disp": "変更あり", "item": "変更あり"}], "data_class": "治療状況", "field_name": "指示変更", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "treatment_end", "data_name": "治療終了", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療終了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_fr_end", "data_name": "終了予測(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測補液完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_total", "data_name": "除水補正合計", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "除水補正合計", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "sttc_vns_prssr", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "静的静脈圧", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "last_weight_after", "data_name": "前回後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前回後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_dw", "data_name": "前体重DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重dw", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_weight_target", "data_name": "前体重 - 目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重目標体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_before_weight_after", "data_name": "前体重-後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_before_tare_total", "data_name": "前体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "device_self_diagnosis", "data_name": "装置自己診断", "data_type": "string", "conv_table": [{"code": 0, "disp": "未実施", "item": "未実施"}, {"code": 1, "disp": "実施済み", "item": "実施済み"}], "data_class": "治療状況", "field_name": "装置自己診断", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "per_increase", "data_name": "増加率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "amount_increase", "data_name": "増加量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "achievement_rate", "data_name": "達成率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "達成率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0/0", "can_calc": "0", "data_code": "dosing_status", "data_name": "投与状況", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "投与状況", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dialysates_used_num", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液使用数", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers_expected", "data_name": "予想引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "予想引き残し", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ベッド名", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "start_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "end_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト', '2020-04-25 00:00:00', '2024-05-11 18:08:28.334', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (160, 'WITH DATA AS (

with dat as
(
SELECT
	ord_no,
	rst_rounds_info ->> ''content'' AS CONTENT,
	rst_rounds_info ->> ''round_type_name'' AS round_type,
	rst_rounds_info ->> ''round_type_cd'' AS round_type_cd,
	CAST(rst_rounds_info ->> ''reg_date_time'' as TIMESTAMP) AS reg_date_time1,
	rst_rounds_info ->> ''ind_user_id'' AS ind_user_id,
	( rst_rounds_info ->> ''ind_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''ind_user_first_name'' ) AS ind_user_name,
	rst_rounds_info ->> ''reg_user_id'' AS reg_user_id,
	( rst_rounds_info ->> ''reg_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''reg_user_first_name'' ) AS reg_user_name,
CASE
		rst_rounds_info ->> ''is_ind_comment_post''
		WHEN ''0'' THEN
		''転記しない'' ELSE''転記する''
	END AS is_ind_comment_post,
	rst_rounds_info ->> ''ind_comment_no'' AS ind_comment_no,
CASE
		rst_rounds_info ->> ''posting_class''
		WHEN ''0'' THEN
		''継続'' ELSE''当日のみ''
	END AS posting_class,
	rst_rounds_info ->> ''created_user_id'' AS created_user_id,
	( rst_rounds_info ->> ''created_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''created_user_first_name'' ) AS created_user_name,
	rst_rounds_info ->> ''updated_user_id'' AS updated_user_id,
	( rst_rounds_info ->> ''updated_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''updated_user_first_name'' ) AS updated_user_name
FROM
	ord_main
WHERE
	ord_no = @ordNo
	AND is_del = ''0''
	AND rst_dialysis_state <> ''0''
)

SELECT
ord_no as ord_no_t,
CONTENT,
round_type,
round_type_cd,
substr(to_char(reg_date_time1,''YYYY/MM/DD hh24:mi:ss''), 0,17) as reg_date_time,
ind_user_id,
ind_user_name,
reg_user_id,
reg_user_name,
is_ind_comment_post,
ind_comment_no,
posting_class,
created_user_id,
created_user_name,
updated_user_id,
updated_user_name
FROM
	dat
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
	', 2, '[{"preview": "001", "can_calc": "1", "data_code": "round_type", "data_name": "種別名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "002", "can_calc": "1", "data_code": "content", "data_name": "種別内容", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "content", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "003", "can_calc": "1", "data_code": "round_type_cd", "data_name": "種別コード", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20 12:30", "can_calc": "1", "data_code": "reg_date_time", "data_name": "起票日時", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_date_time", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "005", "can_calc": "1", "conv_sql": {"sql_cd": 196, "field_name": "disp_user_id", "target_var": "@indUserId"}, "data_code": "ind_user_id", "data_name": "指示者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "006", "can_calc": "1", "data_code": "ind_user_name", "data_name": "指示者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "007", "can_calc": "1", "conv_sql": {"sql_cd": 193, "field_name": "disp_user_id", "target_var": "@regUserId"}, "data_code": "reg_user_id", "data_name": "起票者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "008", "can_calc": "1", "data_code": "reg_user_name", "data_name": "起票者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "009", "can_calc": "1", "data_code": "is_ind_comment_post", "data_name": "指示コメントに転記", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "is_ind_comment_post", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "010", "can_calc": "1", "data_code": "ind_comment_no", "data_name": "指示コメント番号", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_comment_no", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "011", "can_calc": "1", "data_code": "posting_class", "data_name": "転記区分", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "posting_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "012", "can_calc": "1", "conv_sql": {"sql_cd": 194, "field_name": "disp_user_id", "target_var": "@createdUserId"}, "data_code": "created_user_id", "data_name": "登録者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "013", "can_calc": "1", "data_code": "created_user_name", "data_name": "登録者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "014", "can_calc": "1", "conv_sql": {"sql_cd": 195, "field_name": "disp_user_id", "target_var": "@updatedUserId"}, "data_code": "updated_user_id", "data_name": "更新者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "015", "can_calc": "1", "data_code": "updated_user_name", "data_name": "更新者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：回診記録 @ordNo 使用', '2021-10-18 16:42:37.948', '2023-07-17 21:02:00.634', NULL);
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
	', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：体重情報/血圧情報 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (163, 'WITH DATA AS (

with mstcp_tbl as (
select
    comp_treatment_cd
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_1 else mstMedic.in_hospital_cd_1 end as treatMdeci_in_hospital_cd_1
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_2 else mstMedic.in_hospital_cd_2 end as treatMdeci_in_hospital_cd_2
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_3 else mstMedic.in_hospital_cd_3 end as treatMdeci_in_hospital_cd_3
    ,case treat_class when ''0'' then '''' else mstMedic.in_hospital_cd_4 end as treatMdeci_in_hospital_cd_4
		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
			 else ''''
		 end as comptreat_in_hospital_cd_1
 		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
			 else ''''
		 end as comptreat_in_hospital_cd_2
  	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
			 else ''''
		 end as comptreat_in_hospital_cd_3
   	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
			 else ''''
		 end as comptreat_in_hospital_cd_4
    from ord_main as ord		
		cross join lateral
      json_array_elements (ord.rst_treatment_info::json) info		
    inner join mst_comp_treatment as mstCpt on (info ->> ''treat_cd'' = mstCpt.comp_treatment_cd :: TEXT and ord.is_del = ''0'')
    left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
    left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
		 and ord.ord_no = @ordNo
		 
		 
--     from mst_comp_treatment mstCpt
--     left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
--     left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
--     where mstCpt.treat_class != ''2''
--     and mstCpt.is_del = ''0''
--     and mstCpt.is_disp = ''1''
    )
select
	a.ord_no as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
  treatMdeci_in_hospital_cd_4,
	b.comptreat_in_hospital_cd_1,
	b.comptreat_in_hospital_cd_2,
	b.comptreat_in_hospital_cd_3,
	b.comptreat_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.procedure_name,
  c.treat_staff_name,
  c.treat_staff_cd
from
  (
select
    ord.ord_no,
    complaint->>''occur_date'' as occur_date,
    complaint->>''complaint'' as complaint,
    complaint->>''row_no'' as row_no
from
    ord_main as ord
    cross join lateral
    json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6''
    and ord.ord_no = @ordNo
    and complaint->>''checkFlag'' = ''1''
order by
    ord_no,
    occur_date) a
full outer join
  (
select
    ord_no as ord_no_t
		,ord.ord_no,
    treatment->>''occur_date'' as occur_date,
    treatment->>''row_no'' as row_no,
case
    when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
    when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
    when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is not null then ''心電図測定開始''
    when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is null then ''心電図測定終了''
    else treatment->>''treat_name'' end
    as treat_name,
    treatment->>''treat_medicine_name'' as treat_medicine,
    treatment->>''amount'' as amount,
    treatment->>''unit'' as unit,
    treatment->>''procedure_name'' as procedure_name,
    mstcp_tbl.treatMdeci_in_hospital_cd_1,
    mstcp_tbl.treatMdeci_in_hospital_cd_2,
    mstcp_tbl.treatMdeci_in_hospital_cd_3,
    mstcp_tbl.treatMdeci_in_hospital_cd_4,
    mstcp_tbl.comptreat_in_hospital_cd_1,
    mstcp_tbl.comptreat_in_hospital_cd_2,
    mstcp_tbl.comptreat_in_hospital_cd_3,
    mstcp_tbl.comptreat_in_hospital_cd_4
from
    ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
      left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
    where ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6''
    and ord_no = @ordNo
    and treatment->>''checkFlag'' = ''1''

union all
select
		ord_no as ord_no_t,
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
    , machine_record_message as treat_name
    ,'''' as treat_medicine
    ,'''' as amount
    ,'''' as unit
    ,'''' as procedure_name
    ,'''' as treatMdeci_in_hospital_cd_1
    ,'''' as treatMdeci_in_hospital_cd_2
    ,'''' as treatMdeci_in_hospital_cd_3
    ,'''' as treatMdeci_in_hospital_cd_4
		,'''' as comptreat_in_hospital_cd_1
    ,'''' as comptreat_in_hospital_cd_2
    ,'''' as comptreat_in_hospital_cd_3
    ,'''' as comptreat_in_hospital_cd_4
from
    mnt_motion_record as mnt
where
    mnt.ord_no = @ordNo
    and mnt.report_disp_flg = ''1''

order by
    ord_no,
    occur_date,
    row_no) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
full outer join
  (
select
    ord.ord_no,
    treat_staff->>''occur_date'' as occur_date,
    treat_staff->>''row_no'' as row_no,
    treat_staff->>''treat_staff_name'' as treat_staff_name,
    treat_staff->>''treat_staff_cd'' as treat_staff_cd
from
    ord_main as ord
    cross join lateral
    json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state <''6''
    and ord_no = @ordNo
    and treat_staff->>''checkFlag'' = ''1''
order by
    ord_no,
    occur_date,
    row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')

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
	', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "complaint", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "処置薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：愁訴処置 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (165, 'WITH DATA AS (

WITH ord AS (
    SELECT
        ord_no,
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
    AND facility_cd = @facilityCd
    AND rst_dialysis_state > ''0'' AND rst_dialysis_state < ''6''
)
select @ordNo as ord_no_t,a.*
 from (
select
  medi ->> ''cd'' as medi_cd,
  medi ->> ''name'' as medi_name,
  medi ->> ''unit'' as medi_unit,
  medi ->> ''amount'' as medi_amount,
  case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.class_cd else mstMedicMix.class_cd end as medi_class_cd,
  medi ->> ''class_name'' as medi_class_name,
  medi ->> ''class_type'' as medi_class_type,
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
  , medi->>''medicine_type'' as medicine_type
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4
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
  from
    ord
    left join mst_medicine_mix  as mstMedicMix  on (ord.medi ->> ''cd'' = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' and mstMedicMix.facility_cd = @facilityCd )
    left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = @facilityCd )
    left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = @facilityCd)

  where
    ord.ord_no = @ordNo
  and ord.is_del = ''0'' )  a where a.medi_class_cd in ( @medIds )

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
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：投薬 @ordNo 使用', '2021-08-05 13:30:00', '2024-11-02 23:10:42.749', NULL);
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
	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b1 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b1
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b1
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b2 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b2
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b2
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b3 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b3
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b3
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,	
	case 	
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4 
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b4 
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b4
		when date_trunc(''day'',mst_treatment.in_hosp_b_startdate) < date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and date_trunc(''day'',mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'',mst_treatment.in_hosp_a_startdate) < date_trunc(''day'',mst_treatment.in_hosp_b_startdate) and date_trunc(''day'',mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b4
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'',mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,		
	

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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "pull_leave_amount", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "pull_leave_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (167, 'WITH DATA AS (


	with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''
), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
), ord_tbl as (
  select
		ord_no,
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    case
			when info->>''class_cd'' is null then ''-1''
			else info->>''class_cd''
			end as equip_class_cd,
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
    -- 実績
    ,info->>''needle_type'' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_equip_info :: json) info
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
)
(select
ord_no as ord_no_t,
  ord.*,
    dia.model_number as equip_name,
  dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  null as equip_unit,
  null as equip_class_name,
  null as equip_class_type
from
  ord_tbl as ord
  inner join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  where equip_type = ''1''   and dia.dialyzer_cd IN (@diaIds)
order by equip_class_cd, cd)
union all
(select
ord_no as ord_no_t,
  ord.*,
    eqp.equipment_name as equip_name,
  eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  eqp.unit as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type
from
  ord_tbl as ord
  inner join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  where equip_type <> ''1'' and eqp.class_cd IN (@eqIds)
order by equip_class_cd, cd)

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
	', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未使用", "item": "未使用"}, {"code": "1", "disp": "A針", "item": "A針"}, {"code": "2", "disp": "V針", "item": "V針"}, {"code": "3", "disp": "SN", "item": "SN"}], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：医材 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (168, 'WITH DATA AS (


	select
	ord_no as ord_no_t,
  facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
order by no

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
	', 2, '[{"preview": "指示簿テストです。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：指示簿(指示コメント) @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
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
	', 2, '[{"preview": "2.00", "can_calc": "1", "data_code": "water_removal_rst_prev", "data_name": "実績除水量(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "58.20", "can_calc": "1", "data_code": "weight_before_prev_prev", "data_name": "前体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_before_date_prev_prev", "data_name": "前体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_before_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.30", "can_calc": "1", "data_code": "weight_after_prev_prev", "data_name": "後体重(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/08", "can_calc": "0", "data_code": "weight_after_date_prev_prev", "data_name": "後体重測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "weight_after_date_prev_prev", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.10", "can_calc": "1", "data_code": "water_removal_rst_prev_prev", "data_name": "実績除水量(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "water_removal_rst_prev_prev", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：体重情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (170, 'WITH DATA AS (

with latest_otc as(
  select * from ord_treat_condition where (ord_no, up_date) in (select ord_no, max(up_date) from ord_treat_condition where ord_no = @ordNo and is_del = ''0'' and is_disp = ''1'' group by ord_no)
)
, dialyzer_record as(
  select gas_purge_time, substituent_wash_amt, membrane_wash
  from
    ord_main
    inner join (select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1'' and dialyzer_cd IN (@diaIds)) as mst_dialyzer
      on (ord_main.rst_cond_info#>>''{5, value}'')::text = mst_dialyzer.dialyzer_cd::text
  where
    ord_no = @ordNo and ord_main.is_del = ''0''
    and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''
)

select
  ord_main.ord_no as ord_no_t
	,null as ope_dev_a_0179 -- 血流量設定最大値
  ,null as ope_dev_a_0181 -- 除水速度制限
  ,null as ope_dev_a_0038 -- 動脈側気泡検出器
  ,null as ope_dev_a_0021 -- 除水計算時間
  ,null as ope_dev_a_0022 -- 除水計算優先項目
  ,null as ope_dev_a_0039 -- 除水開始遅延時間
  ,null as ope_dev_a_0182 -- 透析液温度操作範囲上限
  ,null as ope_dev_a_0183 -- 透析液温度操作範囲下限
  ,null as ope_dev_a_0024 -- シングルニードル切替圧上限
  ,null as ope_dev_a_0025 -- シングルニードル切替圧下限
  ,null as ope_dev_a_0241 -- TMPゼロ補正
  ,null as ope_dev_a_0168 -- HD補正警報上限値
  ,null as ope_dev_a_0169 -- HD補正警報下限値
  ,null as ope_dev_a_0171 -- ECUM補正警報上限値
  ,null as ope_dev_a_0172 -- ECUM補正警報下限値
  ,null as ope_dev_a_0174 -- HDF補正警報上限値
  ,null as ope_dev_a_0175 -- HDF補正警報下限値
  ,null as ope_dev_a_0177 -- HF補正警報上限値
  ,null as ope_dev_a_0178 -- HF補正警報下限値
  ,null as ope_dev_b_0037 -- HD+補液補正警報上限値
  ,null as ope_dev_b_0038 -- HD+補液補正警報下限値
  ,null as ope_dev_a_0391 -- OHDF補正警報上限値
  ,null as ope_dev_a_0392 -- OHDF補正警報下限値
  ,null as ope_dev_a_0394 -- OHF補正警報上限値
  ,null as ope_dev_a_0395 -- OHF補正警報下限値
  ,null as ope_dev_a_0383 -- 補液量制限
  ,null as ope_dev_a_0389 -- 補液計算優先項目
  ,null as ope_dev_a_0379 -- 補液比率（前補液）
  ,null as ope_dev_b_0039 -- 補液比率（後補液）
  ,null as ope_dev_a_0398 -- 補液開始遅延時間
  ,null as ope_dev_a_0369 -- DP=Qd+Qs(補液速度加算)
  ,null as ope_dev_a_0090 -- 濾過率（前補液）
  ,null as ope_dev_b_0040 -- 濾過率（後補液）
  ,null as ope_dev_a_0091 -- ヘマトクリット（Ht）
  ,null as ope_dev_a_0092 -- 総タンパク（TP）
  ,null as ope_dev_a_0336 -- 緊急補液速度
  ,null as ope_dev_a_0337 -- 緊急補液量
  ,null as ope_dev_a_0185 -- HDF速度操作範囲上限前補液
  ,null as ope_dev_b_0031 -- HDF速度操作範囲上限後補液
  ,null as ope_dev_a_0186 -- HF速度操作範囲上限前補液
  ,null as ope_dev_b_0032 -- HF速度操作範囲上限後補液
  ,null as ope_dev_b_0030 -- HD+補液速度操作範囲上限前補液
  ,null as ope_dev_b_0033 -- HD+補液速度操作範囲上限後補液
  ,null as ope_dev_a_0396 -- OHDF速度操作範囲上限前補液
  ,null as ope_dev_b_0034 -- OHDF速度操作範囲上限後補液
  ,null as ope_dev_a_0397 -- OHF速度操作範囲上限前補液
  ,null as ope_dev_b_0035 -- OHF速度操作範囲上限後補液
  ,null as ope_dev_a_0384 -- AFBF補液比率使用選択
  ,null as ope_dev_a_0385 -- AFBF補液比率
  ,null as ope_dev_a_0386 -- AFBF速度操作範囲上限
  ,null as ope_dev_a_0387 -- AFBF速度操作範囲下限
  ,null as ihdf_dev_a_0200 -- I-HDF_補液量設定
  ,null as ihdf_dev_a_0201 -- I-HDF_補液速度
  ,null as ihdf_dev_a_0202 -- I-HDF_補液周期
  ,null as ihdf_dev_a_0203 -- I-HDF_補液開始時間
  ,null as ihdf_dev_a_0204 -- I-HDF_除水再開時間
  ,null as ihdf_dev_a_0205 -- I-HDF_総補液量上限
  ,null as blood_flow_judge --ホスト監視血流量監視フラグ
  ,null as blood_flow_upper --ホスト監視血流量上限
  ,null as blood_flow_lower --ホスト監視血流量下限
  ,null as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,null as ip_speed_upper --ホスト監視IP速度上限
  ,null as ip_speed_lower --ホスト監視IP速度下限
  ,null as ufr_judge --ホスト監視除水速度監視フラグ
  ,null as ufr_upper --ホスト監視除水速度上限
  ,null as ufr_lower --ホスト監視除水速度下限
  ,null as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,null as bp_max_upper --ホスト監視最高血圧上限
  ,null as bp_max_lower --ホスト監視最高血圧下限
  ,null as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,null as bp_min_upper --ホスト監視最低血圧上限
  ,null as bp_min_lower --ホスト監視最低血圧下限
  ,null as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,null as bp_ave_upper --ホスト監視平均血圧上限
  ,null as bp_ave_lower --ホスト監視平均血圧下限
  ,null as pulse_judge --ホスト監視脈拍監視フラグ
  ,null as pulse_upper --ホスト監視脈拍上限
  ,null as pulse_lower --ホスト監視脈拍下限
  ,null as vp_judge --ホスト監視静脈圧監視フラグ
  ,null as vp_upper --ホスト監視静脈圧上限
  ,null as vp_lower --ホスト監視静脈圧下限
  ,null as rst_ap_judge --ホスト監視動脈圧監視フラグ
  ,null as rst_ap_upper --ホスト監視動脈圧上限
  ,null as rst_ap_lower --ホスト監視動脈圧下限
  ,null as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,null as na_conc_upper --ホスト監視Na濃度上限
  ,null as na_conc_lower --ホスト監視Na濃度下限
  ,null as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,null as dialys_temp_upper --ホスト監視透析液温度上限
  ,null as dialys_temp_lower --ホスト監視透析液温度下限
  ,null as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,null as care_i_interval --ホスト監視ケア報知
  ,null as war_dev_a_0240 -- TMP監視モード
  ,null as war_dev_a_0100 -- HD/ECUM静脈圧自動設定警報幅上限
  ,null as war_dev_a_0101 -- HD/ECUM静脈圧自動設定警報幅下限
  ,null as war_dev_a_0102 -- HD/ECUM静脈圧自動設定警報限界上限
  ,null as war_dev_a_0103 -- HD/ECUM静脈圧自動設定警報限界下限
  ,null as war_dev_a_0104 -- HD/ECUM静脈圧固定警報上限
  ,null as war_dev_a_0105 -- HD/ECUM静脈圧固定警報下限
  ,null as war_dev_a_0152 -- HD/ECUMダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0153 -- HD/ECUMダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0154 -- HD/ECUMダイアライザ入口圧自動設定警報限界上限
  ,null as war_dev_a_0155 -- HD/ECUMダイアライザ入口圧自動設定警報限界下限
  ,null as war_dev_a_0156 -- HD/ECUMダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0157 -- HD/ECUMダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0112 -- HD/ECUM液圧自動設定警報幅上限
  ,null as war_dev_a_0113 -- HD/ECUM液圧自動設定警報幅下限
  ,null as war_dev_a_0114 -- HD/ECUM液圧自動設定警報限界上限
  ,null as war_dev_a_0115 -- HD/ECUM液圧自動設定警報限界下限
  ,null as war_dev_a_0116 -- HD/ECUM液圧固定警報上限
  ,null as war_dev_a_0117 -- HD/ECUM液圧固定警報下限
  ,null as war_dev_a_0128 -- HD/ECUMTMP自動設定警報幅上限
  ,null as war_dev_a_0129 -- HD/ECUMTMP自動設定警報幅下限
  ,null as war_dev_a_0130 -- HD/ECUMTMP自動設定警報限界上限
  ,null as war_dev_a_0131 -- HD/ECUMTMP自動設定警報限界下限
  ,null as war_dev_a_0132 -- HD/ECUMTMP固定警報上限
  ,null as war_dev_a_0133 -- HD/ECUMTMP固定警報下限
  ,null as war_dev_a_0126 -- HD/ECUMTMP自動追従警報幅上限
  ,null as war_dev_a_0127 -- HD/ECUMTMP自動追従警報幅下限
  ,null as war_dev_a_0146 -- HD/ECUMダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0147 -- HD/ECUMダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0148 -- HD/ECUMダイアライザ差圧固定警報上限
  ,null as war_dev_a_0149 -- HD/ECUMダイアライザ差圧固定警報下限
  ,null as war_dev_a_0106 -- HDF/HF静脈圧自動設定警報幅上限
  ,null as war_dev_a_0107 -- HDF/HF静脈圧自動設定警報幅下限
  ,null as war_dev_a_0158 -- HDF/HFダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0159 -- HDF/HFダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0118 -- HDF/HF液圧自動設定警報幅上限
  ,null as war_dev_a_0119 -- HDF/HF液圧自動設定警報幅下限
  ,null as war_dev_a_0136 -- HDF/HFTMP自動設定警報幅上限
  ,null as war_dev_a_0137 -- HDF/HFTMP自動設定警報幅下限
  ,null as war_dev_a_0134 -- HDF/HFTMP自動追従警報幅上限
  ,null as war_dev_a_0135 -- HDF/HFTMP自動追従警報幅下限
  ,null as war_dev_a_0150 -- HDF/HFダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0151 -- HDF/HFダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0110 -- SN静脈圧固定警報上限
  ,null as war_dev_a_0111 -- SN静脈圧固定警報下限
  ,null as war_dev_a_0162 -- SNダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0163 -- SNダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0120 -- SN液圧自動設定警報幅上限
  ,null as war_dev_a_0121 -- SN液圧自動設定警報幅下限
  ,null as war_dev_a_0122 -- SN液圧自動設定警報限界上限
  ,null as war_dev_a_0123 -- SN液圧自動設定警報限界下限
  ,null as war_dev_a_0124 -- SN液圧固定警報上限
  ,null as war_dev_a_0125 -- SN液圧固定警報下限
  ,null as war_dev_a_0140 -- SNTMP自動設定警報幅上限
  ,null as war_dev_a_0141 -- SNTMP自動設定警報幅下限
  ,null as war_dev_a_0142 -- SNTMP自動設定警報限界上限
  ,null as war_dev_a_0143 -- SNTMP自動設定警報限界下限
  ,null as war_dev_a_0144 -- SNTMP固定警報上限
  ,null as war_dev_a_0145 -- SNTMP固定警報下限
  ,null as war_dev_a_0138 -- SNTMP自動追従警報幅上限
  ,null as war_dev_a_0139 -- SNTMP自動追従警報幅下限
  ,null as war_dev_a_0108 -- 準備回収静脈圧固定警報上限
  ,null as war_dev_a_0109 -- 準備回収静脈圧固定警報下限
  ,null as war_dev_a_0160 -- 準備回収ダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0161 -- 準備回収ダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0254 -- Na濃度自動警報幅上限値
  ,null as war_dev_a_0255 -- Na濃度自動警報幅下限値
  ,null as war_dev_a_0256 -- Na濃度固定警報幅上限値
  ,null as war_dev_a_0257 -- Na濃度固定警報幅下限値
  ,null as bp_dev_a_0211 -- 血圧警報点最高血圧上限
  ,null as bp_dev_a_0212 -- 血圧警報点最高血圧下限
  ,null as bp_dev_a_0213 -- 血圧警報点最低血圧上限
  ,null as bp_dev_a_0214 -- 血圧警報点最低血圧下限
  ,null as bp_dev_a_0215 -- 血圧警報点平均血圧上限
  ,null as bp_dev_a_0216 -- 血圧警報点平均血圧下限
  ,null as bp_dev_a_0217 -- 血圧警報点脈拍数上限
  ,null as bp_dev_a_0218 -- 血圧警報点脈拍数下限
  ,null as bp_dev_a_0219 -- 最高血圧上限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0227 -- 最高血圧上限警報_血液ポンプ_速度
  ,null as bp_dev_a_0220 -- 最高血圧下限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0228 -- 最高血圧下限警報_血液ポンプ_速度
  ,null as bp_dev_a_0221 -- 最高血圧上限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0229 -- 最高血圧上限警報_除水ポンプ_速度
  ,null as bp_dev_a_0222 -- 最高血圧下限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0230 -- 最高血圧下限警報_除水ポンプ_速度
  ,null as bp_dev_a_0223 -- 最高血圧上限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0231 -- 最高血圧上限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0224 -- 最高血圧下限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0225 -- 最高血圧上限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0233 -- 最高血圧上限警報_補液ポンプ_速度
  ,null as bp_dev_a_0226 -- 最高血圧下限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0234 -- 最高血圧下限警報_補液ポンプ_速度
  ,null as bp_dev_a_0191 -- 血圧カフ選択
  ,null as bp_dev_a_0190 -- 血圧自動測定間隔
  ,null as bp_dev_a_0192 -- 昇圧値
  ,null as bp_dev_a_0193 -- 昇圧方法選択
  ,null as bp_dev_a_0195 -- 血圧測定方法選択
  ,null as bp_dev_a_0239 -- 高速測定選択
  ,null as bp_dev_a_0194 -- 血圧連続測定動作選択
  ,null as bp_dev_a_0235 -- 警報連動測定開始時間
  ,null as bp_dev_a_0236 -- 治療条件連動測定時間
  ,null as bp_dev_a_0237 -- 静脈圧警報発生時の血圧測定
  ,null as bp_dev_a_0238 -- 血流量または除水速度変更時の血圧測定
  ,null as bv_dev_a_0267 -- BV計使用選択
  ,null as bv_dev_a_0260 -- ⊿BV低下警報点1
  ,null as bv_dev_a_0261 -- ⊿BV低下警報点2
  ,null as bv_dev_a_0262 -- ⊿BV変化率警報点
  ,null as bv_dev_a_0277 -- ⊿BV除水低下速度
  ,null as bv_dev_a_0278 -- ⊿BV除水低下遅延時間
  ,null as bv_dev_a_0258 -- アクセス再循環測定使用選択
  ,null as bv_dev_a_0259 -- アクセス再循環自動測定1
  ,null as bv_dev_a_0263 -- アクセス再循環自動測定2
  ,null as bv_dev_a_0264 -- アクセス再循環自動測定3
  ,null as bv_dev_a_0265 -- アクセス再循環自動測定4
  ,null as bv_dev_a_0266 -- アクセス再循環自動測定5
  ,null as dfas_dev_a_0270 -- 動脈側返血使用選択
  ,null as bv_dev_a_0281 -- アクセス再循環再循環率報知
  ,null as pri_pat_a_0219 -- プライミング補助動脈充填液量
  ,null as pri_pat_a_0220 -- プライミング補助動脈充填流速
  ,null as pri_pat_a_0225 -- プライミング補助動脈充填後継続の有無
  ,null as pri_pat_a_0221 -- プライミング補助静脈充填液量
  ,null as pri_pat_a_0222 -- プライミング補助静脈充填流速
  ,null as pri_pat_a_0226 -- プライミング補助静脈充填後継続の有無
  ,null as pri_pat_a_0223 -- プライミング補助気泡抜き液量
  ,null as pri_pat_a_0224 -- プライミング補助気泡抜き流速
  ,null as pri_pat_a_0227 -- プライミング補助気泡抜き間欠動作選択
  ,null as pri_pat_a_0228 -- プライミング補助液交換量
  ,null as pri_pat_a_0229 -- プライミング補助間欠動作動作時間
  ,null as pri_pat_a_0230 -- プライミング補助間欠動作停止時間
  ,null as pri_pat_a_0232 -- 自動プライミング落差時間
  ,null as pri_pat_a_0238 -- 自動プライミング総量
  ,null as pri_pat_a_0231 -- 自動プライミング開始時間
  ,null as pri_pat_a_0233 -- 自動プライミング送液液量
  ,null as pri_pat_a_0234 -- 自動プライミング送液流速1回目
  ,null as pri_pat_a_0235 -- 自動プライミング送液流速2回目以降
  ,null as pri_pat_a_0236 -- 自動プライミング循環流速
  ,null as pri_pat_a_0237 -- 自動プライミング循環時間
  ,null as pri_dev_a_0370 -- 自動回収_使用液量
  ,null as pri_dev_a_0371 -- 自動回収_流速
  ,null as pri_dev_a_0372 -- 自動回収_血液判別器による終了選択
  ,null as pri_pat_b_0051 -- オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  ,null as pri_pat_b_0032 -- オンラインプライミング_動脈チャンバ液面作成時間_前補液
  ,null as pri_pat_b_0052 -- オンラインプライミング_動脈チャンバ液面作成時間_後補液
  ,null as pri_pat_b_0033 -- オンラインプライミング_循環洗浄時間_前補液
  ,null as pri_pat_b_0053 -- オンラインプライミング_循環洗浄時間_後補液
  ,null as ufr_dev_a_0290 -- UFRプログラム使用選択
  ,null as na_dev_a_0315 -- Na注入プログラム使用選択
  ,null as na_dev_a_0184 -- Na注入濃度最大値
  ,null as dc_dev_a_0340 -- 透析液濃度プログラム使用選択
  ,null as ecum_dev_a_0016 -- ECUM選択
  ,null as ecum_dev_a_0017 -- ECUM量
  ,null as ecum_dev_a_0018 -- ECUM時間
  ,null as ecum_dev_a_0019 -- ECUM時間カウント選択
  ,null as cpro_dev_a_0252 -- Ｂ液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0253 -- Ｂ液濃度プログラム自動設定警報幅下限
  ,null as cpro_dev_a_0250 -- 透析液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0251 -- 透析液濃度プログラム自動設定警報幅下限
  ,null as dfas_pat_b_0001 -- IPラインプライミング使用選択
  ,dialyzer_record.gas_purge_time -- ガスパージ時間
  ,dialyzer_record.substituent_wash_amt-- 置換洗浄量（透析液）
  ,dialyzer_record.membrane_wash -- 膜洗浄（中空糸）
  ,null as dfas_pat_b_0005 -- 中空糸_プライミング時のBP速度
  ,null as dfas_pat_b_0007 -- 中空糸_送液最大時間
  ,null as dfas_pat_b_0008 -- 中空糸_回路内洗浄送液量
  ,null as dfas_pat_b_0009 -- 中空糸_気泡抜き動作実行回数
  ,null as dfas_pat_b_0010 -- 中空糸_気泡抜き圧力上限
  ,null as dfas_pat_b_0059 -- 積層_プライミング時のBP速度
  ,null as dfas_pat_b_0054 -- 積層_送液最大時間
  ,null as dfas_pat_b_0055 -- 積層_回路内洗浄送液量
  ,null as dfas_pat_b_0056 -- 積層_気泡抜き動作実行回数
  ,null as dfas_pat_b_0057 -- 積層_気泡抜き圧力上限
  ,null as dfas_pat_b_0058 -- 積層_除水ポンプ速度
  ,null as dfas_dev_a_0339 -- 脱血方法選択
  ,null as dfas_dev_a_0333 -- 脱血速度
  ,null as dfas_dev_a_0331 -- 同時脱血_脱血量
  ,null as dfas_dev_a_0334 -- 片側脱血(除水なし)_脱血量
  ,null as dfas_dev_a_0338 -- 片側脱血（除水あり）_脱血量
  ,null as dfas_dev_a_0332 -- 片側脱血への切替え透析液圧
  ,treat_condition->>''335'' as ord_treat_condition_335 -- 治療開始時_血液ポンプ速度
  ,null as dfas_dev_a_0373 -- 静脈側返血速度
  ,null as dfas_dev_a_0374 -- 静脈側最大返血量
  ,null as dfas_dev_a_0377 -- 静脈側返血_血液判別器使用選択
  ,null as dfas_dev_a_0376 -- 動脈側最大返血量
  ,null as dfas_dev_a_0378 -- 動脈側返血_血液判別器使用選択
  ,null as dia_dev_a_0282 -- 透析量プログラム使用選択
  ,treat_condition->>''283'' as ord_treat_condition_283 -- 体液量計算時後体重
  ,treat_condition->>''284'' as ord_treat_condition_284 -- 体液量+補正値
  ,treat_condition->>''285'' as ord_treat_condition_285 -- 目標後体重
  ,treat_condition->>''286'' as ord_treat_condition_286 -- 標準血流量
  ,treat_condition->>''287'' as ord_treat_condition_287 -- KoA
  ,null as dia_dev_a_0288 -- 目標Kt/V
  ,treat_condition->>''187'' as ord_treat_condition_187 -- ダイアライザ 尿素クリアランス
  ,treat_condition->>''188'' as ord_treat_condition_188 -- ダイアライザ 血流量
  ,treat_condition->>''189'' as ord_treat_condition_189 -- ダイアライザ 透析液流量
  ,null as bvufc_dev_a_0196 -- BV-UFC使用選択
  ,null as bvufc_dev_a_0197 -- UFC期間除水速度上限
  ,null as bvufc_dev_a_0198 -- UFC期間除水速度下限
  ,null as bvufc_dev_a_0199 -- 開始期間 時間
  ,null as bvufc_dev_a_0206 -- 開始期間 除水速度倍率
  ,null as bvufc_dev_a_0207 -- 固定倍率除水期間 時間
  ,null as bvufc_dev_a_0208 -- 固定倍率除水期間 除水速度倍率
  ,null as bvufc_dev_a_0209 -- 固定倍率除水終了条件　最高血圧
  ,null as bvufc_dev_a_0210 -- 固定倍率除水終了条件　脈拍
  ,null as bvufc_dev_a_0248 -- 固定倍率除水終了条件　ΔBV
  ,null as bvufc_dev_a_0249 -- 終了前期間 時間
  ,null as ope_dev_a_0268 -- 透析液流量　設定方法
  ,null as ope_dev_a_0269 -- 透析液流量　比率設定
  ,null as bvufc_dev_a_0271 -- 開始時ΔBV基準値
  ,null as bvufc_dev_a_0272 -- ΔBV基準線　指数1
  ,null as bvufc_dev_a_0273 -- ΔBV基準線　指数2
  ,null as bvufc_dev_a_0274 -- ΔBV基準線　指数3
  ,null as bvufc_dev_a_0275 -- 終了時ΔBV基準値
  ,null as qbqd_dev_a_0400 -- QBプログラム血流量1
  ,null as qbqd_dev_a_0401 -- QBプログラム血流量2
  ,null as qbqd_dev_a_0402 -- QBプログラム血流量3
  ,null as qbqd_dev_a_0403 -- QBプログラム血流量4
  ,null as qbqd_dev_a_0404 -- QBプログラム血流量5
  ,null as qbqd_dev_a_0405 -- QBプログラム血流量6
  ,null as qbqd_dev_a_0406 -- QBプログラム血流量7
  ,null as qbqd_dev_a_0407 -- QBプログラム血流量8
  ,null as qbqd_dev_a_0408 -- QBプログラム血流量9
  ,null as qbqd_dev_a_0409 -- QBプログラム血流量10
  ,null as qbqd_dev_a_0410 -- QDプログラム透析液流量1
  ,null as qbqd_dev_a_0411 -- QDプログラム透析液流量2
  ,null as qbqd_dev_a_0412 -- QDプログラム透析液流量3
  ,null as qbqd_dev_a_0413 -- QDプログラム透析液流量4
  ,null as qbqd_dev_a_0414 -- QDプログラム透析液流量5
  ,null as qbqd_dev_a_0415 -- QDプログラム透析液流量6
  ,null as qbqd_dev_a_0416 -- QDプログラム透析液流量7
  ,null as qbqd_dev_a_0417 -- QDプログラム透析液流量8
  ,null as qbqd_dev_a_0418 -- QDプログラム透析液流量9
  ,null as qbqd_dev_a_0419 -- QDプログラム透析液流量10
  ,null as qbqd_dev_a_0420 -- QB、QDプログラム切替時間1
  ,null as qbqd_dev_a_0421 -- QB、QDプログラム切替時間2
  ,null as qbqd_dev_a_0422 -- QB、QDプログラム切替時間3
  ,null as qbqd_dev_a_0423 -- QB、QDプログラム切替時間4
  ,null as qbqd_dev_a_0424 -- QB、QDプログラム切替時間5
  ,null as qbqd_dev_a_0425 -- QB、QDプログラム切替時間6
  ,null as qbqd_dev_a_0426 -- QB、QDプログラム切替時間7
  ,null as qbqd_dev_a_0427 -- QB、QDプログラム切替時間8
  ,null as qbqd_dev_a_0428 -- QB、QDプログラム切替時間9
  ,null as qbqd_dev_a_0429 -- QB、QDプログラム最大ステップ数
  ,null as qbqd_dev_a_0430 -- QBプログラム電源
  ,null as qbqd_dev_a_0431 -- QDプログラム電源
  ,null as ihdf_dev_a_0432 -- I-HDFプログラム使用選択
  ,null as ihdf_dev_a_0433 -- 予定補液回数
  ,null as ihdf_dev_a_0434 -- 補液バランス制限
  ,null as ihdf_dev_a_0435 -- 補液量01
  ,null as ihdf_dev_a_0436 -- 補液量02
  ,null as ihdf_dev_a_0437 -- 補液量03
  ,null as ihdf_dev_a_0438 -- 補液量04
  ,null as ihdf_dev_a_0439 -- 補液量05
  ,null as ihdf_dev_a_0440 -- 補液量06
  ,null as ihdf_dev_a_0441 -- 補液量07
  ,null as ihdf_dev_a_0442 -- 補液量08
  ,null as ihdf_dev_a_0443 -- 補液量09
  ,null as ihdf_dev_a_0444 -- 補液量10
  ,null as ihdf_dev_a_0445 -- 補液量11
  ,null as ihdf_dev_a_0446 -- 補液量12
  ,null as ihdf_dev_a_0447 -- 補液量13
  ,null as ihdf_dev_a_0448 -- 補液量14
  ,null as ihdf_dev_a_0449 -- 補液量15
  ,null as ihdf_dev_a_0450 -- 補液量16
  ,null as ihdf_dev_a_0451 -- 回収量01
  ,null as ihdf_dev_a_0452 -- 回収量02
  ,null as ihdf_dev_a_0453 -- 回収量03
  ,null as ihdf_dev_a_0454 -- 回収量04
  ,null as ihdf_dev_a_0455 -- 回収量05
  ,null as ihdf_dev_a_0456 -- 回収量06
  ,null as ihdf_dev_a_0457 -- 回収量07
  ,null as ihdf_dev_a_0458 -- 回収量08
  ,null as ihdf_dev_a_0459 -- 回収量09
  ,null as ihdf_dev_a_0460 -- 回収量10
  ,null as ihdf_dev_a_0461 -- 回収量11
  ,null as ihdf_dev_a_0462 -- 回収量12
  ,null as ihdf_dev_a_0463 -- 回収量13
  ,null as ihdf_dev_a_0464 -- 回収量14
  ,null as ihdf_dev_a_0465 -- 回収量15
  ,null as ihdf_dev_a_0466 -- 回収量16
from
  ord_main
  inner join latest_otc on ord_main.ord_no = latest_otc.ord_no
  cross join dialyzer_record
where ord_main.ord_no = @ordNo and ord_main.is_del = ''0''
 and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''

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
	', 2, '[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "0", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "0", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "0", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "1", "disp": "使用しない", "item": "使用しない"}, {"code": "2", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "52", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.7", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "0", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "0", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "0", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "2", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "0", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "1", "disp": "降圧測定", "item": "降圧測定"}, {"code": "2", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "0", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2:34", "can_calc": "0", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3:45", "can_calc": "0", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "0", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "0", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "ufr_dev_a_0290", "data_name": "UFRプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "07:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血（除水なし）", "can_calc": "0", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血（除水あり）", "item": "片側脱血（除水あり）"}, {"code": "2", "disp": "片側脱血（除水なし）", "item": "片側脱血（除水なし）"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ord_treat_condition_335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_335", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dia_dev_a_0282", "data_name": "透析量プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dia_dev_a_0282", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.90", "can_calc": "1", "data_code": "ord_treat_condition_283", "data_name": "体液量計算時後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_283", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.00", "can_calc": "1", "data_code": "ord_treat_condition_284", "data_name": "体液量+補正値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_284", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "ord_treat_condition_285", "data_name": "目標後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_285", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "ord_treat_condition_286", "data_name": "標準血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_286", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "ord_treat_condition_287", "data_name": "KoA", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_287", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "ord_treat_condition_187", "data_name": "ダイアライザ 尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_187", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ord_treat_condition_188", "data_name": "ダイアライザ 血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_188", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "ord_treat_condition_189", "data_name": "ダイアライザ 透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_189", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "0", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "1", "disp": "流量設定", "item": "流量設定"}, {"code": "2", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：装置設定 @ordNo 使用', '2005-08-01 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (172, 'WITH DATA AS (

with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main
  where
    ord_main.pat_id = (select pat_id from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6'')
    and rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and rst_start_date <= (select rst_start_date from ord_main where ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state >''0'' and rst_dialysis_state < ''6'' and rst_dialysis_state < ''6'')
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_mae as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date as before_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as before_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as before_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as before_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as before_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 5
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_hist_ato as (
  select
    ord_main.ord_no
    ,rst_start_date
    ,occur_date  as after_vital_measure_date
    ,to_number(monitor_data->>''90'', ''999'') as after_bp_high
    ,to_number(monitor_data->>''91'', ''999'') as after_bp_low
    ,to_number(monitor_data->>''92'', ''999'') as after_bp_ave
    ,to_number(monitor_data->>''93'', ''999'') as after_pulse
  from
    ord_main
    left outer join (select * from mni_monitor where is_del = ''0'') as mni_monitor
      on ord_main.ord_no = mni_monitor.ord_no and mni_monitor.data_type = 6
  where
    ord_main.ord_no in (select ord_no from hist_ord_nos) and ord_main.is_del = ''0''
), ord_array_tbl as (
  select
    array_agg(ord_hist_mae.ord_no order by ord_hist_mae.rst_start_date desc) as array_ord_no
    ,array_agg(ord_hist_mae.rst_start_date order by ord_hist_mae.rst_start_date desc) as array_rst_start_date

    ,array_agg(before_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_before_vital_measure_date
    ,array_agg(before_bp_high order by ord_hist_mae.rst_start_date desc) as array_before_bp_high
    ,array_agg(before_bp_low order by ord_hist_mae.rst_start_date desc) as array_before_bp_low
    ,array_agg(before_bp_ave order by ord_hist_mae.rst_start_date desc) as array_before_bp_ave
    ,array_agg(before_pulse order by ord_hist_mae.rst_start_date desc) as array_before_pulse

    ,array_agg(after_vital_measure_date order by ord_hist_mae.rst_start_date desc) as array_after_vital_measure_date
    ,array_agg(after_bp_high order by ord_hist_mae.rst_start_date desc) as array_after_bp_high
    ,array_agg(after_bp_low order by ord_hist_mae.rst_start_date desc) as array_after_bp_low
    ,array_agg(after_bp_ave order by ord_hist_mae.rst_start_date desc) as array_after_bp_ave
    ,array_agg(after_pulse order by ord_hist_mae.rst_start_date desc) as array_after_pulse
  from
    ord_hist_mae
    inner join ord_hist_ato
      on ord_hist_mae.ord_no = ord_hist_ato.ord_no
)

select
  @ordNo as ord_no_t
  ,array_ord_no[1] as ord_no_prev
  ,array_ord_no[2] as ord_no_prev_prev
  ,array_rst_start_date[1] as rst_start_date_prev
  ,array_rst_start_date[2] as rst_start_date_prev_prev

  ,array_before_vital_measure_date[1] as before_vital_measure_date_prev
  ,array_before_vital_measure_date[2] as before_vital_measure_date_prev_prev
  ,array_before_bp_high[1] as before_bp_high_prev
  ,array_before_bp_high[2] as before_bp_high_prev_prev
  ,array_before_bp_low[1] as before_bp_low_prev
  ,array_before_bp_low[2] as before_bp_low_prev_prev
  ,array_before_bp_ave[1] as before_bp_ave_prev
  ,array_before_bp_ave[2] as before_bp_ave_prev_prev
  ,array_before_pulse[1] as before_pulse_prev
  ,array_before_pulse[2] as before_pulse_prev_prev

  ,array_after_vital_measure_date[1] as after_vital_measure_date_prev
  ,array_after_vital_measure_date[2] as after_vital_measure_date_prev_prev
  ,array_after_bp_high[1] as after_bp_high_prev
  ,array_after_bp_high[2] as after_bp_high_prev_prev
  ,array_after_bp_low[1] as after_bp_low_prev
  ,array_after_bp_low[2] as after_bp_low_prev_prev
  ,array_after_bp_ave[1] as after_bp_ave_prev
  ,array_after_bp_ave[2] as after_bp_ave_prev_prev
  ,array_after_pulse[1] as after_pulse_prev
  ,array_after_pulse[2] as after_pulse_prev_prev

  ,array_before_bp_high[1]::text || ''/'' || array_before_bp_low[1]::text || ''/'' || array_before_bp_ave[1] || ''('' || array_before_pulse[1]::text || '')'' as before_bp_summary_prev
  ,array_before_bp_high[2]::text || ''/'' || array_before_bp_low[2]::text || ''/'' || array_before_bp_ave[2] || ''('' || array_before_pulse[2]::text || '')'' as before_bp_summary_prev_prev

  ,array_after_bp_high[1]::text || ''/'' || array_after_bp_low[1]::text || ''/'' || array_after_bp_ave[1] || ''('' || array_after_pulse[1]::text || '')'' as after_bp_summary_prev
  ,array_after_bp_high[2]::text || ''/'' || array_after_bp_low[2]::text || ''/'' || array_after_bp_ave[2] || ''('' || array_after_pulse[2]::text || '')'' as after_bp_summary_prev_prev
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
  ', 2, '[{"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev", "data_name": "前血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev", "data_name": "前血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev", "data_name": "前血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev", "data_name": "前脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev", "data_name": "前血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev", "data_name": "後血圧（最高）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev", "data_name": "後血圧（最低）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev", "data_name": "後血圧（平均）(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev", "data_name": "後脈拍(前回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev", "data_name": "後血圧測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high_prev_prev", "data_name": "前血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low_prev_prev", "data_name": "前血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave_prev_prev", "data_name": "前血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse_prev_prev", "data_name": "前脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary_prev_prev", "data_name": "前血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date_prev_prev", "data_name": "前血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "before_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high_prev_prev", "data_name": "後血圧（最高）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_high_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low_prev_prev", "data_name": "後血圧（最低）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_low_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave_prev_prev", "data_name": "後血圧（平均）(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_ave_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse_prev_prev", "data_name": "後脈拍(前々回)", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_pulse_prev_prev", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary_prev_prev", "data_name": "後血圧（最高/最低/平均(脈拍)）(前々回)", "data_type": "string", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_bp_summary_prev_prev", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date_prev_prev", "data_name": "後血圧測定日時(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報(過去実績)", "field_name": "after_vital_measure_date_prev_prev", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：血圧情報(過去実績) @ordNo 使用', '2021-08-05 13:30:00', '2024-09-04 20:45:55.223', NULL);
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
	', 2, '[{"preview": "55.00", "can_calc": "1", "data_code": "water_removal_target", "data_name": "目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_target", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "1", "data_code": "water_removal_rst", "data_name": "実績除水量", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "water_removal_rst", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.70", "can_calc": "1", "data_code": "add_water_total", "data_name": "補液積算値", "data_type": "decimal", "conv_table": [], "data_class": "除水情報", "field_name": "add_water_total", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "before_tare_name_1", "data_name": "風袋名称１（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_tare_weight_1", "data_name": "風袋重量１（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "before_tare_name_2", "data_name": "風袋名称２（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "before_tare_weight_2", "data_name": "風袋重量２（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "before_tare_name_3", "data_name": "風袋名称３（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "before_tare_weight_3", "data_name": "風袋重量３（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "before_tare_name_4", "data_name": "風袋名称４（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_4", "data_name": "風袋重量４（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "before_tare_name_5", "data_name": "風袋名称５（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "before_tare_weight_5", "data_name": "風袋重量５（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "before_wheel_chair_name", "data_name": "車椅子名称（透析前）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "before_wheel_chair_weight", "data_name": "車椅子重量（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "before_tare_total", "data_name": "風袋重量合計（透析前）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "before_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "after_tare_name_1", "data_name": "風袋名称１（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "after_tare_weight_1", "data_name": "風袋重量１（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "after_tare_name_2", "data_name": "風袋名称２（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "after_tare_weight_2", "data_name": "風袋重量２（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "after_tare_name_3", "data_name": "風袋名称３（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "1", "data_code": "after_tare_weight_3", "data_name": "風袋重量３（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "after_tare_name_4", "data_name": "風袋名称４（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_4", "data_name": "風袋重量４（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "after_tare_name_5", "data_name": "風袋名称５（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "after_tare_weight_5", "data_name": "風袋重量５（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "after_wheel_chair_name", "data_name": "車椅子名称（透析後）", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "after_wheel_chair_weight", "data_name": "車椅子重量（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_wheel_chair_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16800", "can_calc": "1", "data_code": "after_tare_total", "data_name": "風袋重量合計（透析後）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "after_tare_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "off_water_weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_1", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "off_water_weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_2", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_3", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "off_water_weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_4", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "off_water_weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_5", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "1", "data_code": "off_water_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_total", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：除水情報/風袋・除水補正 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (175, 'WITH DATA AS (

with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
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
, tmp2 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treat_staff_info) as rtsi
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state >''0'' and rst_dialysis_state <''6''
)
, staff_tbl as
(
  select
    *
    ,date_trunc(''minute'', (rtsi->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp2
)

select
oxygen_tbl.ord_no as ord_no_t,
  oxygen_tbl.ord_no
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then occur_date else null -- 開始
  end as start_date
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then occur_date else null -- 終了
  end as end_date
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then rtsi->>''treat_staff_name'' else null -- 開始
  end as start_staff
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rtsi->>''treat_staff_name'' else null -- 終了
  end as end_staff
  ,case
    when bit_length(rti->>''oxygen_speed'') <> 0 then rti->>''oxygen_speed'' else null
  end as speed
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rti->>''oxygen_amount'' else null
  end as amount
from
  oxygen_tbl
  left outer join staff_tbl
    on oxygen_tbl.ord_no = staff_tbl.ord_no and oxygen_tbl.date_trunc_occur_date = staff_tbl.date_trunc_occur_date
order by
  ord_no, occur_date

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
	', 2, '[{"preview": "09:47", "can_calc": "0", "data_code": "start_date", "data_name": "開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:00", "can_calc": "0", "data_code": "end_date", "data_name": "終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦２", "can_calc": "0", "data_code": "start_staff", "data_name": "開始者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "start_staff", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護婦３", "can_calc": "0", "data_code": "end_staff", "data_name": "終了者", "data_type": "string", "conv_table": [], "data_class": "酸素吸入", "field_name": "end_staff", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "speed", "data_name": "吸入速度", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "speed", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15", "can_calc": "1", "data_code": "amount", "data_name": "吸入量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入", "field_name": "amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：酸素吸入 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
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
	', 2, '[{"preview": "16", "can_calc": "1", "data_code": "total_amount", "data_name": "吸入総量", "data_type": "decimal", "conv_table": [], "data_class": "酸素吸入総量", "field_name": "total_amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：酸素吸入総量 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (177, 'WITH DATA AS (

with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state >''0'' and rst_dialysis_state < ''6''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
  from
    addition_info_expand
)

select
ord_no as ord_no_t,
  ord_no
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
	end as addition_class_name
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
	', 2, '[{"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算・管理料", "field_name": "addition_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算・管理料連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算・管理料連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算・管理料連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算・管理料", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：加算 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (179, 'WITH DATA AS (

select
    @ordNo as ord_no_t
		,s.rst_weight_info ->> ''ctr'' as last_ctr
  , s.rst_weight_info ->> ''ctr_weight'' as last_ctr_weight
  , s.rst_weight_info ->> ''weight_before'' as last_weight_before
  , s.rst_weight_info ->> ''weight_after'' as last_weight_after
  , s.rst_weight_info ->> ''weight_decreased'' as last_weight_decreased
  , substr(to_char(cast( s.rst_weight_info ->> ''ctr_measure_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_ctr_measure_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_after_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_after_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_before_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_before_date
  , (s.rst_puncture_user_info ->> ''user_last_name_1'') || (s.rst_puncture_user_info ->> ''user_first_name_1'') as last_puncture_user_name
from
  ord_main as ord   LEFT OUTER JOIN ord_main s ON (
    ord.ord_no <> s.ord_no
    AND ord.pat_id = s.pat_id
    AND ord.facility_cd = s.facility_cd
    AND ord.rst_start_date > s.rst_start_date
    AND s.is_del = ''0''
  )
WHERE
  ord.ord_no = @ordNo
AND
  ord.is_del = ''0''
AND ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''

ORDER BY
  s.rst_start_date DESC

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
	', 2, '[{"preview": "56.78", "can_calc": "1", "data_code": "last_weight_before", "data_name": "前体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_before_date", "data_name": "前体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_weight_after", "data_name": "後体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_after_date", "data_name": "後体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "last_ctr", "data_name": "CTR(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_ctr_measure_date", "data_name": "CTR測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_ctr_weight", "data_name": "CTR測定時体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_weight", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）(前回体重)', '2021-08-05 13:30:00', '2024-07-31 19:50:36.869', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (187, 'WITH DATA AS (

with dat as
(
SELECT
	rst_rounds_info ->> ''content'' AS CONTENT,
	rst_rounds_info ->> ''round_type_name'' AS round_type,
	rst_rounds_info ->> ''round_type_cd'' AS round_type_cd,
	CAST(rst_rounds_info ->> ''reg_date_time'' as TIMESTAMP) AS reg_date_time1,
	rst_rounds_info ->> ''ind_user_id'' AS ind_user_id,
	( rst_rounds_info ->> ''ind_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''ind_user_first_name'' ) AS ind_user_name,
	rst_rounds_info ->> ''reg_user_id'' AS reg_user_id,
	( rst_rounds_info ->> ''reg_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''reg_user_first_name'' ) AS reg_user_name,
CASE
		rst_rounds_info ->> ''is_ind_comment_post''
		WHEN ''0'' THEN
		''転記しない'' ELSE''転記する''
	END AS is_ind_comment_post,
	rst_rounds_info ->> ''ind_comment_no'' AS ind_comment_no,
CASE
		rst_rounds_info ->> ''posting_class''
		WHEN ''0'' THEN
		''継続'' ELSE''当日のみ''
	END AS posting_class,
	rst_rounds_info ->> ''created_user_id'' AS created_user_id,
	( rst_rounds_info ->> ''created_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''created_user_first_name'' ) AS created_user_name,
	rst_rounds_info ->> ''updated_user_id'' AS updated_user_id,
	( rst_rounds_info ->> ''updated_user_last_name'' ) || ''　'' || ( rst_rounds_info ->> ''updated_user_first_name'' ) AS updated_user_name
FROM
	ord_main
WHERE
	ord_no = @ordNo
	AND is_del = ''0''
	AND rst_dialysis_state > ''0''
	AND rst_dialysis_state < ''6''
)

SELECT
@ordNo as ord_no_t,
CONTENT,
round_type,
round_type_cd,
substr(to_char(reg_date_time1,''YYYY-MM-DD hh24:mi:ss''), 0,17) as reg_date_time,
ind_user_id,
ind_user_name,
reg_user_id,
reg_user_name,
is_ind_comment_post,
ind_comment_no,
posting_class,
created_user_id,
created_user_name,
updated_user_id,
updated_user_name
FROM
	dat

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
	', 2, '[{"preview": "001", "can_calc": "1", "data_code": "round_type", "data_name": "種別名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "002", "can_calc": "1", "data_code": "content", "data_name": "種別内容", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "content", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "003", "can_calc": "1", "data_code": "round_type_cd", "data_name": "種別コード", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type_cd", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20 12:30", "can_calc": "1", "data_code": "reg_date_time", "data_name": "起票日時", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_date_time", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "005", "can_calc": "1", "conv_sql": {"sql_cd": 196, "field_name": "disp_user_id", "target_var": "@indUserId"}, "data_code": "ind_user_id", "data_name": "指示者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "006", "can_calc": "1", "data_code": "ind_user_name", "data_name": "指示者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "007", "can_calc": "1", "conv_sql": {"sql_cd": 193, "field_name": "disp_user_id", "target_var": "@regUserId"}, "data_code": "reg_user_id", "data_name": "起票者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "008", "can_calc": "1", "data_code": "reg_user_name", "data_name": "起票者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "009", "can_calc": "1", "data_code": "is_ind_comment_post", "data_name": "指示コメントに転記", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "is_ind_comment_post", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "010", "can_calc": "1", "data_code": "ind_comment_no", "data_name": "指示コメント番号", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_comment_no", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "011", "can_calc": "1", "data_code": "posting_class", "data_name": "転記区分", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "posting_class", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "012", "can_calc": "1", "conv_sql": {"sql_cd": 194, "field_name": "disp_user_id", "target_var": "@createdUserId"}, "data_code": "created_user_id", "data_name": "登録者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "013", "can_calc": "1", "data_code": "created_user_name", "data_name": "登録者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "014", "can_calc": "1", "conv_sql": {"sql_cd": 195, "field_name": "disp_user_id", "target_var": "@updatedUserId"}, "data_code": "updated_user_id", "data_name": "更新者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_id", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "015", "can_calc": "1", "data_code": "updated_user_name", "data_name": "更新者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：回診記録 @ordNo 使用', '2020-07-31 18:29:49', '2024-07-31 19:50:36.869', NULL);
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
      ord.facility_cd,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''unit'' as medi_unit,
      cast(medi ->> ''amount'' AS NUMERIC) as medi_amount,
      medi ->> ''class_cd'' :: text as medi_class_cd,
      medi ->> ''class_name'' as medi_class_name,
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
      where
      ord.medi->>''medicine_type'' = ''1''
    union
    select
      json_idx,
      ord_no,
      ord.facility_cd,
      mixtemp.medi_cd  :: text  as medi_cd,
      mstMedic.medicine_name as medi_name,
      mstMedic.unit  as medi_unit,
      (medi ->> ''amount'') :: NUMERIC *  mixtemp.amount :: NUMERIC as medi_amount,
      mstMedic.class_cd :: text as  medi_class_cd,
      classtemp.class_name as medi_class_name,
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
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dia_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "dia_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dia_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dia_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dia_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dia_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dia_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dia_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dia_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dia_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "dia_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬（分解）", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', '2024-11-02 23:10:42.749', NULL);
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
	', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', '2024-03-07 01:36:29.181', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (199, 'WITH DATA AS (

with mstcp_tbl as (
select
    comp_treatment_cd
		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
			 else ''''
		 end as comptreat_in_hospital_cd_1
 		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
			 else ''''
		 end as comptreat_in_hospital_cd_2
  	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
			 else ''''
		 end as comptreat_in_hospital_cd_3
   	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
			 else ''''
		 end as comptreat_in_hospital_cd_4
    from ord_main as ord		
		cross join lateral
      json_array_elements (ord.rst_treatment_info::json) info		
    inner join mst_comp_treatment as mstCpt on (info ->> ''treat_cd'' = mstCpt.comp_treatment_cd ::text and ord.is_del = ''0'')
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
		 and ord.ord_no = @ordNo
)

select
	@ordNo as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'')as occur_date,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
	b.comptreat_in_hospital_cd_1,
	b.comptreat_in_hospital_cd_2,
	b.comptreat_in_hospital_cd_3,
	b.comptreat_in_hospital_cd_4,		
  b.amount,
  b.unit,
  b.receipt_value,
  b.unit_second,
  b.procedure_name,
  c.treat_staff_name,
  c.treat_staff_cd
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord.ord_no = @ordNo
    and complaint->>''checkFlag'' = ''1''
order by
      ord_no,
      occur_date) a
  full outer join
  (
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      case
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is not null then ''心電図測定開始''
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is null then ''心電図測定終了''
        else treatment->>''treat_name'' end
      as treat_name,
      treatment->>''treat_medicine_name'' as treat_medicine,
      treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,
      save.receipt_value,
      mstMedic.unit_second
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      left join mst_medicine as  mstMedic  on (treatment->>''treat_medicine_cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treatment->>''checkFlag'' = ''1''
    and treatment->>''medicine_type'' = ''1''
union all
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      case
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is not null then ''心電図測定開始''
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is null then ''心電図測定終了''
        else treatment->>''treat_name'' end
      as treat_name,
      mstMedic.medicine_name as treat_medicine,
      save.ind_rst_value as amount,
      mstMedic.unit as unit,
      treatment->>''procedure_name'' as procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,			
      save.receipt_value,
      mstMedic.unit_second
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.medicine_mix_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      left join mst_medicine as  mstMedic  on (save.supplies_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treatment->>''checkFlag'' = ''1''
    and treatment->>''medicine_type'' = ''2''
union all
select
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
    , machine_record_message as treat_name
    ,'''' as treat_medicine
    ,'''' as amount
    ,'''' as unit
    ,'''' as procedure_name
    ,'''' as treatMdeci_in_hospital_cd_1
    ,'''' as treatMdeci_in_hospital_cd_2
    ,'''' as treatMdeci_in_hospital_cd_3
		,'''' as comptreat_in_hospital_cd_1
    ,'''' as comptreat_in_hospital_cd_2
    ,'''' as comptreat_in_hospital_cd_3
    ,'''' as comptreat_in_hospital_cd_4
    ,'''' as receipt_value
    ,'''' as unit_second
from
    mnt_motion_record as mnt
where
    mnt.ord_no = @ordNo
    and mnt.report_disp_flg = ''1''

order by
ord_no,
occur_date,
row_no

     ) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
  full outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treat_staff->>''checkFlag'' = ''1''
    order by
      ord_no,
      occur_date,
      row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')

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
	', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：愁訴処置（分解） @ordNo 使用', '2021-11-29 13:29:36.254', '2023-11-13 21:57:42.093', NULL);
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
)
select
    @ordNo as ord_no_t
		,sv.supplies_cd
    , med.medicine_name as medicine_name
    , md.medicine_cd_order
    , med_clss.class_name as medi_class_name
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
    ord_material_save sv
        left join ord_tbl as ord_tbl
        on (sv.supplies_cd = ord_tbl.medi ->> ''cd'' ::text)
    left join medicine_order md
        on (
            sv.supplies_base_no = sv.supplies_base_no
            and sv.supplies_cd = md.medicine_cd
        )
    left join mst_medicine as med
        on (sv.supplies_cd = med.medicine_cd ::text)
    left join mst_medicine_class as med_clss
        on (med_clss.class_cd = med.class_cd)
where
    sv.supplies_base_no = @ordNo
    and sv.supplies_source_class in (''1'', ''3'')
    and sv.ind_rst_class = ''2''
group by
    sv.supplies_cd
    , medicine_name
    , medicine_cd_order
    , class_name
    , unit
    ,unit_second
        , medi_class_cd--
        , medicine_type--
    , med_in_hospital_cd_1
    , med_in_hospital_cd_2
    , med_in_hospital_cd_3

order by
    medicine_cd_order asc


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
	', 2, '[{"preview": "実施薬剤１", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "錠", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_1", "data_name": "実施薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_2", "data_name": "実施薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_3", "data_name": "実施薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_4", "data_name": "実施薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：実施薬剤（分解） @ordNo 使用', '2021-11-05 11:30:03', '2023-07-17 21:02:00.634', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (225, 'WITH b AS (
select ord_main.* from ord_main
     where facility_cd = @facilityCd
 and rst_dialysis_state between ''1'' and ''5''
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate
 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate
 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
     and
       is_del = ''0''
             and pat_id IS NULL
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = @facilityCd
    group by b.ord_no
    , mni_monitor.data_type
        LIMIT 1
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 予測時間_除水
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 予測時間_透析
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd
), f AS (
    select e.*
--     to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
--     , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
--     , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_除水完了,0) AS 予測時間_除水
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_透析完了,0) AS 予測時間_透析
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_補液完了,0) AS 予測時間_補液 
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
),j as(
    select pat_event.pat_id, count(*) as observation_records_num 
        from  pat_event INNER JOIN b on (pat_event.pat_id = b.pat_id) AND (pat_event.ord_no = b.ord_no)
        WHERE pat_event.ord_no > 0 AND pat_event.facility_cd <> ''null'' AND pat_event.use_type = 2 AND  pat_event.event_status = ''1'' AND pat_event.is_newest = ''1'' AND pat_event.is_del = ''0''
        GROUP BY pat_event.pat_id
)
,k as (select h.ord_no, machine_status as machine_status , machine_serial from mnt_machine_state INNER JOIN h on mnt_machine_state.bed_cd = h.bed_cd)
,q as (
   select
     e.ord_no,
     to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
     from e
     inner join mnt_machine_state on
     e.facility_cd = mnt_machine_state.facility_cd and
     e.machine_type_cd = mnt_machine_state.machine_type_cd and
     e.machine_serial = mnt_machine_state.machine_type_cd and
     e.ord_no = mnt_machine_state.ord_no and
     e.pat_id = mnt_machine_state.pat_id
)
,p as (select com_format_cd,com_type,h.ord_no from mst_machine INNER JOIN h on h.machine_no = mst_machine.machine_no)
,l as (select pat_ind_approve.ord_no, pat_ind_approve.is_content_changed_for_map as is_content_changed_for_map from pat_ind_approve INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as dosing_status
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
 ,bed_group as (
 SELECT
        index_no AS bed_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_group_code,
        order_cd ->> ''name'' AS bed_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
        AND master_physical_name = ''mst_room_bed_group''
 )
  ,bed as (
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
 )
,kur as (
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
 )
 ,mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 )
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
, b.rst_cond_info::json#>>''{3, value}'' AS target_weight
, CASE WHEN b.rst_cond_info::json#>>''{3, value}'' is not null AND b.rst_cond_info::json#>>''{3, value}'' <> ''null'' THEN CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) 
  ELSE CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - b.rst_dw 
  END AS target_weight_2
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS forecast_end_water_removal_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS forecast_end_dialysis_end
, b.rst_end_date
, b.rst_cond_info#>>''{1, value}'' AS treatment_minute
, b.rst_cond_info#>>''{1, value}'' AS treatment_time
, CASE WHEN b.rst_dialysis_state <> ''3'' THEN 0
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN f.予測時間_除水 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN f.予測時間_透析 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
       ELSE COALESCE(f.予測時間_補液,0) - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
  END AS delay_time
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = ''0'' THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
             WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
             END AS progress_rate 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->''90'' AS bpbefore_max
, BpBefore.monitor_data->''91'' AS bpbefore_min
, BpBefore.monitor_data->''92'' AS bpbefore_avg
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS bpbefore
, BpBefore.monitor_data->''93'' AS pulse_before
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS bpcurrent
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
, BpAfter.monitor_data->''90'' AS bpafter_max
, BpAfter.monitor_data->''91'' AS bpafter_min
, BpAfter.monitor_data->''92'' AS bpafter_avg
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS bpafter
, BpAfter.monitor_data->''93'' AS pulse_after
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS pat_confirm
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS plan_end
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS rounds_status
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS rounds_data
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS water_removal_limit
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS dialyzer
, b.rst_cond_info#>>''{6, value_name_1}'' AS adsorption_column
, b.rst_cond_info#>>''{7, value_name_1}'' AS primary_membrane
, b.rst_cond_info#>>''{8, value_name_1}'' AS Second_membrane
, b.rst_cond_info#>>''{9, value_name_1}'' AS needles_a
, b.rst_cond_info#>>''{10, value_name_1}'' AS needles_v
, b.rst_cond_info#>>''{11, value_name_1}'' AS needles_sn
, CASE WHEN b.rst_cond_info#>>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS single_needle_use
, b.rst_cond_info#>>''{13, value_name_1}'' AS blood_circuit
, b.rst_cond_info#>>''{14, value}'' AS blood_flow
, b.rst_cond_info#>>''{15, value_name_1}'' AS dialysate
, b.rst_cond_info#>>''{16, value}'' AS dialysate_flow
, b.rst_cond_info#>>''{17, value}'' AS dialysate_volume
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS dialysate_temperature
, b.rst_cond_info#>>''{19, value_name_1}'' AS fluid_replenishment
, b.rst_cond_info#>>''{20, value}'' AS fr_volume
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS fr_selection
, b.rst_cond_info#>>''{22, value}'' AS fr_use_num
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS fr_temperature
, b.rst_cond_info#>>''{24, value}'' AS fr_velocity
, b.rst_cond_info#>>''{25, value_name_1}'' AS anticoagulants
, b.rst_cond_info#>>''{26, value}'' AS anticoagulants_oneshot_quantity
, b.rst_cond_info#>>''{27, value}'' AS anticoagulants_duration_rate
, b.rst_cond_info#>>''{28, value}'' AS anticoagulants_total_volume
-- , CASE WHEN b.rst_cond_info#>>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip_usage_selection
, b.rst_cond_info#>>''{29, value}'' AS ip_usage_selection
-- , null AS ip_start
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ip_start
, b.rst_cond_info#>>''{30, value}'' AS ip_start
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ip_oneshot_quantity
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip_velocity
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip_velocity_max
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ip_oneshot_quantity
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip_velocity
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip_velocity_max
-- , CASE WHEN b.rst_cond_info#>>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS auto_oneshot
, b.rst_cond_info#>>''{34, value}'' AS auto_oneshot
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_auto_off
, b.rst_cond_info#>>''{35, value}'' AS ip_auto_off
, b.rst_cond_info#>>''{36, value}'' AS ip_auto_cycle_time
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{37, value}'' AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{38, value}'' AS ip_power_ok_monitor_off_time
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
, BpBefore.monitor_data
--, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS leftovers
, b.pat_id AS hosp_pat_id
, b.rst_end_date as treatment_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end_fr_end
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS sttc_vns_prssr
, b.rst_dw AS last_weight_after
, b.rst_weight_info #>> ''{ihdf_pll}'' AS ihdf_pll
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS off_water_total
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,f.monitor_data->''Z212'' AS device_self_diagnosis
,b.rst_bed_name AS bed_name
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS weight_before_tare_total
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS weight_after_tare_total
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS complaint_latest
, o.treatment AS treatment_latest
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as dialysates_used_num
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS weight_before_dw
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS weight_before_weight_target
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS weight_before_weight_after
,CASE WHEN b.rst_dw is NULL OR b.rst_dw = 0 THEN 0 ELSE(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 END AS per_increase
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as amount_increase
,CASE WHEN CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL) > 0 THEN round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  ELSE 0 END as achievement_rate
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as leftovers_expected 
,COALESCE(j.observation_records_num,0) as observation_records_num
,k.machine_status
,l.is_content_changed_for_map
,m.dosing_status
,n.rate as recirculation_rate_eff 
,bed.bed_order
,kur.kur_order
,kur.kur_name as ind_kur_name
,MIN(rb1.bed_group_order) as bed_group_order
,b.rst_start_date as start_time
,b.rst_end_date as end_time
-- 終了予定
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS  ind_end_date
-- 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
END AS ind_end_date_time
from b
LEFT outer JOIN j on (b.pat_id = j.pat_id)
LEFT JOIN d on (b.ord_no = d.ord_no)
LEFT JOIN e on (b.ord_no = e.ord_no)
LEFT JOIN k on (b.ord_no = k.ord_no)
LEFT JOIN q on (b.ord_no = q.ord_no)
LEFT JOIN p on (b.ord_no = p.ord_no)
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
    -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || b.rst_bed_cd) :: jsonb
            LEFT OUTER JOIN bed_group AS rb1 ON rbg1.room_bed_group_cd = rb1.bed_group_code
            LEFT OUTER JOIN bed ON bed.bed_code = b.rst_bed_cd
            LEFT OUTER JOIN kur ON kur.kur_code = b.rst_kur_cd
group by 
b.ord_no
, b.treat_date
, b.pat_id
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw
, mnt_machine_state.process_state
, b.rst_cond_info
, b.rst_weight_info
, b.rst_dialysis_state
, f.残り時間_除水完了
, f.残り時間_透析完了
, f.残り時間_補液完了
, f.予測時間_除水
, f.予測時間_透析
, f.予測時間_補液
, p.com_format_cd
, p.com_type
, d.data_type
, q.残り時間_透析完了
, e.残り時間_透析完了
, bpbefore.monitor_data
, bpcurrent.monitor_data
, b.rst_charge_user_info
, b.rst_puncture_user_info
, b.rst_return_user_info
, bpafter.monitor_data
, b.rst_rounds_info
, f.monitor_data
, bpbefore.ord_no
, b.rst_off_water_info
, b.rst_tare_info
, b.rst_bed_name
, b.rst_complaint_info
, o.treatment
, j.observation_records_num
, k.machine_status
, l.is_content_changed_for_map
, m.dosing_status
, n.rate
, bed.bed_order
, kur.kur_order
, e.経過時間
, f.bio_moni_ctl_no
, kur.kur_name
, b.rst_start_date
, b.rst_end_date            
order by b.treat_date, b.ord_no, f.bio_moni_ctl_no', 2, '[]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト(「？？？？」患者)', '2024-04-26 14:31:38', '2024-05-11 18:08:28.164', NULL);