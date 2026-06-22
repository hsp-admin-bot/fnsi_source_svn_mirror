DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106001,-1106002,-1106003,-1106004,-1100006,-1100008,-1100013);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100006, 'WITH coop_ini_info AS (
    -- 連携設定取得(pre_sqlにて取得)
    SELECT coop_info->>''key1'' AS key1,
        coop_info->>''key2'' AS key2,
        coop_info->>''value'' AS value
    FROM json_array_elements(@coopIniInfo::json) coop_info
)
, converted_in_out_class AS (
    -- in_out_class変換値の取得（なければ''1''をデフォルトにする）
    SELECT ppm.pat_id,
        ppm.hosp_pat_id,
        ppm.in_out_class,
        COALESCE((  
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''CONV_INOUT_TO_KARTE''
                AND key2 = CASE
                    WHEN ppm.in_out_class::text = ''3'' THEN ''0''
                    ELSE ppm.in_out_class::text
                END
            LIMIT 1
        ), ''1'') AS converted_in_out_class
    FROM pat_personal_main ppm
    WHERE ppm.pat_id = @patId
        AND ppm.is_del = ''0''
)
, ini_value AS (
    -- 患者ID桁数の取得
    SELECT (
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''SCM_COMMON''
                AND key2 = ''PATID_LEN''
            LIMIT 1
        ) AS patid_len
)
SELECT LPAD(
    RIGHT(converted.hosp_pat_id::text, ini_value.patid_len::integer),
    ini_value.patid_len::integer,''0'') AS hosp_pat_id,
    converted.converted_in_out_class AS in_out_class
FROM converted_in_out_class converted
    CROSS JOIN ini_value;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', '2025-05-27 13:22:20.351', '2025-07-14 23:20:26.229', '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coopIniInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100008, 'WITH coop_ini_info AS (
    --連携設定取得(pre_sqlにて取得)
    SELECT CASE
            WHEN @key2 = ''NULL'' THEN ''NULL''
            ELSE coop_info->>''value''
        END AS value
    FROM json_array_elements(@coop_ini_info::json) coop_info
    WHERE (
            @key2 = ''NULL''
            OR (
                COALESCE(coop_info->>''key1'', '''') = @key1
                AND COALESCE(coop_info->>''key2'', '''') = @key2
            )
        )
    LIMIT 1
), input_values AS (
    SELECT LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text AS hospital_id,
        (
            SELECT value
            FROM coop_ini_info
        )::text AS ini_value,
        TO_CHAR(@time::timestamptz, ''YYYYMMDD_HH24MISS'') AS timestamp
),
folder_values AS (
    SELECT COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' IN (''TREAT_FOLDER'', ''INJECT_FOLDER'')
),
folder_check AS (
    SELECT COUNT(DISTINCT value) = 1 AS is_same_folder
    FROM folder_values
),
params AS (
    SELECT CASE
            WHEN @fileKind = ''treatment''
            AND (
                SELECT is_same_folder
                FROM folder_check
            ) THEN 1
            WHEN @fileKind = ''injection''
            AND (
                SELECT is_same_folder
                FROM folder_check
            ) THEN 2
            WHEN @fileKind = ''medical'' THEN 1
            ELSE 1
        END AS increment,
        CASE
            WHEN @fileKind = ''medical'' THEN ''medical''
            ELSE ''other''
        END AS kind_group
),
regexp_patterns AS (
    SELECT CASE
            WHEN kind_group = ''medical'' THEN ''_([0-9]{3})\\.[a-z0-9]+$''
            ELSE ''_([0-9]+)\\.[a-z0-9]+$''
        END AS regex
    FROM params
),
target_pattern AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp AS base_name
    FROM input_values i
),
used_suffixes AS (
    SELECT SUBSTRING(
            path_part
            FROM ''_([0-9]+)\.txt$''
        )::integer AS suffix
    FROM sys_coop_journal j
        CROSS JOIN LATERAL regexp_split_to_table(j.dump_path, ''\|'') AS path_part
        JOIN target_pattern p ON TRUE
    WHERE path_part LIKE ''%'' || p.base_name || ''_%''
        AND path_part ~ (''_'' || ''[0-9]+'' || ''\.txt$'')
        AND facility_cd = @facilityCd
        AND pat_id = @patId
),
next_suffix_raw AS (
    SELECT COALESCE(MAX(suffix), 0) AS max_suffix
    FROM used_suffixes
),
next_suffix AS (
    SELECT CASE
            WHEN p.kind_group = ''medical'' THEN ''.'' || LPAD((r.max_suffix + p.increment)::text, 3, ''0'')
            ELSE ''_'' || (r.max_suffix + p.increment)::text
        END AS next_suffix
    FROM next_suffix_raw r
        CROSS JOIN params p
),
filename AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || n.next_suffix || ''.'' || @file_extension AS filename
    FROM input_values i
        CROSS JOIN next_suffix n
)
SELECT *
FROM filename;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_zzz.xxx形式のファイル名', '2025-06-23 23:41:19.590', '2025-07-14 23:20:26.524', '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106004, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_ファイル作成終了のdetail特定', '2025-06-19 10:57:13.141', '2025-07-14 23:20:26.958', '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106002, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_処方ヘッダーのdetail特定', '2025-06-25 16:30:15.736', '2025-07-14 23:20:26.958', '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106001, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_オーダーインデックスのdetail特定', '2025-06-25 16:30:15.736', '2025-07-14 23:20:26.958', '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106003, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_実施単位のdetail特定', '2025-06-25 16:30:15.736', '2025-07-14 23:20:26.958', '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100013, 'WITH forder_name AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' = CASE @fileKind
            WHEN ''treatment'' THEN ''TREAT_FOLDER''
            WHEN ''injection'' THEN ''INJECT_FOLDER''
            WHEN ''schedule'' THEN ''SCHE_FOLDER''
            WHEN ''medical'' THEN ''KARTE_FOLDER''
            WHEN ''xray'' THEN ''XRAY_FOLDER''
            ELSE NULL 
        END
)
SELECT COALESCE(
  (SELECT value FROM forder_name LIMIT 1),
  ''''
) AS folder_name;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（連携設定 フォルダ名取得用）', '2025-07-02 15:36:26.753', '2025-07-14 23:20:26.114', NULL);