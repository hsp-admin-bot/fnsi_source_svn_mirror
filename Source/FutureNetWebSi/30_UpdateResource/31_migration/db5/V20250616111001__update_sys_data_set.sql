delete from "sys_data_set" where sql_cd in (-1100007,-1100008,-1100009);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100009, 'WITH coop_ini_info as (
--連携設定取得(pre_sqlにて取得)
SELECT
  coop_info ->> ''key1'' as key1,
  coop_info ->> ''key2'' as key2,
  coop_info ->> ''value'' as value
FROM
  json_array_elements(@coop_ini_info::json) coop_info
  WHERE
  COALESCE(coop_info ->> ''key1'', '''') = @key1
  and COALESCE(coop_info ->> ''key2'', '''') = @key2
)

select 
(select value from coop_ini_info)||  TO_CHAR(current_timestamp,''YYYYMMDDHH24MISS'') || ''.csv'' AS filename
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_RCyyyymmddhhmmss.xxx', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100008, 'WITH coop_ini_info as (
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
        SUBSTRING(dump_path FROM ''_([0-9]{3})\.[a-z0-9]+$'') AS suffix
    FROM 
        sys_coop_journal j
        JOIN input_values i 
          ON j.dump_path LIKE i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_%.%''
    WHERE
        dump_path ~ ''_[0-9]{3}\.[a-z0-9]+$''
)
,numbers_001_999 AS (
    SELECT LPAD(n::text, 3, ''0'') AS suffix
    FROM generate_series(1, 999) n
)
,next_suffix AS (
    SELECT n.suffix AS next_suffix
    FROM numbers_001_999 n
    LEFT JOIN used_suffixes u ON n.suffix = u.suffix
    WHERE u.suffix IS NULL
    ORDER BY n.suffix
    LIMIT 1
)
,filename AS (
    SELECT 
        i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_'' || n.next_suffix || @file_extension AS generated_filename
    FROM 
        input_values i
        CROSS JOIN next_suffix n
)
SELECT * FROM filename', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_zzz.xxx形式のファイル名', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100007, 'WITH coop_ini_info as (
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
, input_values AS (
    SELECT 
        LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text AS hospital_id,
        (SELECT value FROM coop_ini_info) ::text AS ini_value,
        TO_CHAR(@time::timestamptz,''YYYYMMDD_HH24MISS'') AS timestamp
)
,select_file_name AS (--increment
    SELECT 
        dump_path,
        SUBSTRING(dump_path FROM ''_([0-9]+)\.[a-z0-9]+$'')::int AS increment
    FROM 
        sys_coop_journal j
        JOIN input_values i 
          ON j.dump_path LIKE i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_%.%''
)
,next_suffix AS (
    SELECT 
        COALESCE(MAX(increment), 0) + 1 AS next_number
    FROM 
        select_file_name
)
,filename AS (
    SELECT 
        i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_'' || n.next_number || @file_extension AS generated_filename
    FROM 
        input_values i
        CROSS JOIN next_suffix n
)
SELECT * FROM filename', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_z.xxx形式のファイル名', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);