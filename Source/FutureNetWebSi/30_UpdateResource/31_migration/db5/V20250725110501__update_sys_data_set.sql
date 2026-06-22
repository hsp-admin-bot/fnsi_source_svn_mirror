DELETE FROM ntss.sys_data_set WHERE sql_cd=-1102031;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102031, 'WITH raw_data AS (
  SELECT
    @contentJson::jsonb AS data
),
rows AS (
  SELECT jsonb_array_elements(data) AS row
  FROM raw_data
)
  SELECT 
    row->>19 AS medical_record_text
  FROM rows
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析指示連携 新規処理dump取得用', current_timestamp,current_timestamp, '[{"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]');