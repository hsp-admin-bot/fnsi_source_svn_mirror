DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1100008;

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
),
next_suffix_raw AS (
    SELECT COALESCE(MAX(suffix), 0) AS max_suffix
    FROM used_suffixes
),
next_suffix AS (
    SELECT CASE
            WHEN p.kind_group = ''medical'' THEN LPAD((r.max_suffix + p.increment)::text, 3, ''0'')
            ELSE (r.max_suffix + p.increment)::text
        END AS next_suffix
    FROM next_suffix_raw r
        CROSS JOIN params p
),
filename AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_'' || n.next_suffix || ''.'' || @file_extension AS filename
    FROM input_values i
        CROSS JOIN next_suffix n
)
SELECT *
FROM filename;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_zzz.xxx形式のファイル名', '2025-06-23 23:41:19.590', current_timestamp, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);