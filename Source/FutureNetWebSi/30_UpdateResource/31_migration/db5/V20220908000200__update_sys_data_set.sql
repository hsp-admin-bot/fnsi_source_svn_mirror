DELETE  FROM sys_data_set WHERE sql_cd IN (3, 12);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3, 'WITH monitorData AS (
    SELECT
        rst_weight_info,
        monitor_data,
        bio_moni_ctl_no,
        occur_date,
        data_type
    FROM
        ord_main A
        LEFT JOIN mni_monitor B ON A.ord_no = B.ord_no
        AND A.facility_cd = B.facility_cd
        AND B.facility_cd = @facilityCd
        AND B.is_del = ''0''
    WHERE
        A.facility_cd = @facilityCd
        AND A.ord_no = @ordNo
        AND A.is_del = ''0''
        AND A.rst_dialysis_state <> ''0''
    ),
    tmp AS (
    SELECT
        to_number( monitorData.rst_weight_info ->> ''weight_before'', ''999.99'' ) AS weight_before,
        ( monitorData.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP AS weight_before_date,
        to_number( monitorData.rst_weight_info ->> ''weight_after'', ''999.99'' ) AS weight_after,
        ( monitorData.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP AS weight_after_date,
        to_number( monitorData.rst_weight_info ->> ''ctr'', ''999.99'' ) AS ctr,
        ( monitorData.rst_weight_info ->> ''ctr_measure_date'' ) :: TIMESTAMP AS ctr_measure_date,
        to_number( monitorData.rst_weight_info ->> ''ctr_weight'', ''999.99'' ) AS ctr_weight,
        to_number( monitorData.rst_weight_info ->> ''kt_v_measure'', ''999.99'' ) AS kt_v_measure,
        to_number( monitorData.rst_weight_info ->> ''urr'', ''999.9'' ) AS urr,
        to_number( ( SELECT monitor_data FROM monitorData WHERE bio_moni_ctl_no :: TEXT = rst_weight_info ->> ''re_loop_rate_main'' ) ->> ''38'', ''999.99'' ) AS re_loop_rate,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''90'', ''999'' ) AS before_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''91'', ''999'' ) AS before_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''92'', ''999'' ) AS before_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''93'', ''999'' ) AS before_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 5 ) AS before_vital_measure_date,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''90'', ''999'' ) AS after_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''91'', ''999'' ) AS after_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''92'', ''999'' ) AS after_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''93'', ''999'' ) AS after_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 6 ) AS after_vital_measure_date
    FROM
        monitorData
        LIMIT 1
    )
    SELECT
    *,
    before_bp_high :: TEXT || ''/'' || before_bp_low :: TEXT || ''/'' || before_bp_ave || ''('' || before_pulse :: TEXT || '')'' AS before_bp_summary,
    after_bp_high :: TEXT || ''/'' || after_bp_low :: TEXT || ''/'' || after_bp_ave || ''('' || after_pulse :: TEXT || '')'' AS after_bp_summary
FROM
    tmp', 2, '[{"preview": "57.90", "can_calc": "1", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_before_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "weight_after_date", "data_name": "後体重測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "weight_after_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "34.12", "can_calc": "1", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "ctr_measure_date", "data_name": "CTR測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_measure_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.05", "can_calc": "1", "data_code": "ctr_weight", "data_name": "CTR測定時体重", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "ctr_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "1", "data_code": "kt_v_measure", "data_name": "Kt/V測定値(DDM)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "kt_v_measure", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "1", "data_code": "urr", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "urr", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "1", "data_code": "re_loop_rate", "data_name": "再循環率", "data_type": "decimal", "conv_table": [], "data_class": "体重情報", "field_name": "re_loop_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "140", "can_calc": "1", "data_code": "before_bp_high", "data_name": "前血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "before_bp_low", "data_name": "前血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "before_bp_ave", "data_name": "前血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "before_pulse", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "before_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "before_bp_summary", "data_name": "前血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "before_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:10", "can_calc": "0", "data_code": "before_vital_measure_date", "data_name": "前血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "before_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "after_bp_high", "data_name": "後血圧（最高）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82", "can_calc": "1", "data_code": "after_bp_low", "data_name": "後血圧（最低）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "101", "can_calc": "1", "data_code": "after_bp_ave", "data_name": "後血圧（平均）", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "76", "can_calc": "1", "data_code": "after_pulse", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "血圧情報", "field_name": "after_pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120/80/100(72)", "can_calc": "0", "data_code": "after_bp_summary", "data_name": "後血圧（最高/最低/平均(脈拍)）", "data_type": "string", "conv_table": [], "data_class": "血圧情報", "field_name": "after_bp_summary", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:53", "can_calc": "0", "data_code": "after_vital_measure_date", "data_name": "後血圧測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "血圧情報", "field_name": "after_vital_measure_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：体重情報/血圧情報 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (12, 'WITH rst_start_data_check AS (
    SELECT CASE WHEN rst_start_date IS NULL THEN up_date ELSE rst_start_date END AS rst_start_date
    FROM ord_main
    WHERE ord_no = @ordNo 
    AND is_del = ''0''
    AND rst_dialysis_state > ''0''
)
select
    s.rst_weight_info ->> ''ctr'' as last_ctr
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
    AND (SELECT rst_start_date FROM rst_start_data_check) > s.rst_start_date
    AND s.is_del = ''0''
  )
WHERE
  ord.ord_no = @ordNo 
AND
  ord.is_del = ''0''
AND ord.rst_dialysis_state > ''0''    
ORDER BY
  s.rst_start_date DESC
LIMIT
 1', 2, '[{"preview": "56.78", "can_calc": "1", "data_code": "last_weight_before", "data_name": "前体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_before_date", "data_name": "前体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_before_date", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_weight_after", "data_name": "後体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_weight_after_date", "data_name": "後体重測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_weight_after_date", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "last_ctr", "data_name": "CTR(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  8:21", "can_calc": "1", "data_code": "last_ctr_measure_date", "data_name": "CTR測定日時(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_measure_date", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.78", "can_calc": "1", "data_code": "last_ctr_weight", "data_name": "CTR測定時体重(前回)", "data_type": "decimal", "conv_table": [], "data_class": "体重情報（過去実績）", "field_name": "last_ctr_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績(前回体重)', '2021-10-06 09:47:33', CURRENT_TIMESTAMP, NULL);
