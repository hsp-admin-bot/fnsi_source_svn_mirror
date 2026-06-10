DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in(-28,-47);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-47, 'SELECT 
 0 AS order_no
  ,disp_user_id   AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id ::TEXT = @userId
 UNION
SELECT 
1 AS order_no
, @default_user_no
 ORDER BY order_no ASC LIMIT 1', 1, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影依頼者 ★削除用data', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, '[{"sql_cd": -663, "field_name": "staff_cd_data", "replace_var": "@userId"}, {"sql_cd": -663, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-28, 'SELECT 
 0 AS order_no
  ,disp_user_id   AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id ::TEXT = @userId
 UNION
SELECT 
1 AS order_no
, @default_user_no
 ORDER BY order_no ASC LIMIT 1', 1, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影依頼者★削除用comm', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, '[{"sql_cd": -663, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -663, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
