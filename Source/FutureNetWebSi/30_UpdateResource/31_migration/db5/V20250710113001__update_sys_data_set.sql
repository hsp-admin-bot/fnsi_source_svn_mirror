DELETE FROM sys_data_set WHERE sql_cd IN 
(-1100015,-1105010,-1105009,-1105008);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100015, 'WITH coop_ini_info as (
--連携設定取得(pre_sqlにて取得)
SELECT
  CASE 
    WHEN @key2 = ''NULL'' THEN ''NULL''
    ELSE coop_info ->> ''value''
  END AS value
FROM
  json_array_elements(@coop_ini_info::json) coop_info
WHERE
  (
    @key2 = ''NULL''
    OR (
      COALESCE(coop_info ->> ''key1'', '''') = @key1
      AND COALESCE(coop_info ->> ''key2'', '''') = @key2
    )
)
LIMIT 1
)
,input_values AS (
    SELECT 
        LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text AS hospital_id,
        (SELECT value FROM coop_ini_info)::text AS ini_value,
        TO_CHAR(@time::timestamptz, ''YYYYMMDD_HH24MISS'') AS timestamp
)
,used_suffixes AS (
    SELECT 
        CAST(SUBSTRING(dump_path FROM ''_([0-9]+)\.[a-z0-9]+$'') AS INTEGER) AS suffix
    FROM 
        sys_coop_journal j
        JOIN input_values i 
          ON j.dump_path LIKE i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_%.%''
    WHERE
        dump_path ~ ''_[0-9]+\.[a-z0-9]+$''
)
,numbers_1_999 AS (
    SELECT n AS suffix
    FROM generate_series(1, 999) n
)
,next_suffix AS (
    SELECT n.suffix AS next_suffix
    FROM numbers_1_999 n
    LEFT JOIN used_suffixes u ON n.suffix = u.suffix
    WHERE u.suffix IS NULL
    ORDER BY n.suffix
    LIMIT 1
)
,filename AS (
    SELECT 
        i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_'' || n.next_suffix::text || ''.'' ||@file_extension AS filename
    FROM 
        input_values i
        CROSS JOIN next_suffix n
)
SELECT * FROM filename', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_z.xxx形式のファイル名', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105008, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの検体検査_オーダーインデックス出力', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100015, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105009, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの検体検査_検体検査出力', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100015, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105010, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの検体検査_検体検査依頼ファイル作成終了出力', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100015, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);

