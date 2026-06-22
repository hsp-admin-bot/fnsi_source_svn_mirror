DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1107005;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107005, 'WITH coop_ini_info AS (
    SELECT CASE
             WHEN @key2 = ''NULL'' THEN ''NULL''
             ELSE coop_info ->> ''value''
           END AS value
    FROM   json_array_elements(@coop_ini_info::json) AS coop_info
    WHERE  (
              @key2 = ''NULL''
              OR (
                   COALESCE(coop_info ->> ''key1'', '''') = @key1
                   AND COALESCE(coop_info ->> ''key2'', '''') = @key2
                 )
           )
    LIMIT  1
),
input_values AS (
    SELECT LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text                 AS hospital_id,
           (SELECT value FROM coop_ini_info)::text                    AS ini_value,
           TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD_HH24MISS'')            AS timestamp
),
folder_values AS (
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM   mst_coop_ini AS ini
           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) AS info
    WHERE  facility_cd              = @facilityCd
      AND  is_del                   = ''0''
      AND  COALESCE(info ->> ''key0'', '''') = @key0
      AND  info ->> ''key1''           = @key1
      AND  info ->> ''key2'' IN (''TREAT_FOLDER'', ''INJECT_FOLDER'')
),
folder_check AS (
    SELECT COUNT(DISTINCT value) = 1 AS is_same_folder
    FROM   folder_values
),
params AS (
    SELECT CASE
             WHEN @fileKind = ''treatment''
                  AND (SELECT is_same_folder FROM folder_check) THEN 1
             WHEN @fileKind = ''injection''
                  AND (SELECT is_same_folder FROM folder_check) THEN 2
             WHEN @fileKind = ''medical'' THEN 1
             ELSE 1
           END AS increment
),
target_pattern AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp AS base_name
    FROM   input_values AS i
),
used_suffixes AS (
    SELECT SUBSTRING(j.dump_path FROM ''\\.([0-9]+)\\.txt$'')::int AS suffix
    FROM   sys_coop_journal AS j
           JOIN target_pattern AS p ON TRUE
    WHERE  j.dump_path LIKE p.base_name || ''.%''
      AND  facility_cd = @facilityCd
      AND  pat_id      = @patId
),
next_suffix_raw AS (
    SELECT COALESCE(MAX(suffix), 0) AS max_suffix
    FROM   used_suffixes
),
next_suffix AS (
    SELECT ''.'' || LPAD((r.max_suffix + p.increment)::text, 3, ''0'') AS next_suffix
    FROM   next_suffix_raw AS r
           CROSS JOIN params AS p
),
filename AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp
           || n.next_suffix || ''.'' || @file_extension      AS filename
    FROM   input_values AS i
           CROSS JOIN next_suffix AS n
)
SELECT *
FROM   filename;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　指示変更履歴 ファイル名取得', '2025-06-16 02:18:28.215', '2025-06-16 02:18:28.215', '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);