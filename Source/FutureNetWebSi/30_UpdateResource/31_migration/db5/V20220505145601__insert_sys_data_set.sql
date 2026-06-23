INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-71, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：施設内職員ID(共通部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -9, "field_name": "staff_cd_comm", "replace_var": "@userId"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-72, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：施設内職員ID(内容部)取得',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -9, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
