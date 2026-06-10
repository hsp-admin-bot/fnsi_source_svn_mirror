INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：施設内職員ID(共通部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -8, "field_name": "staff_cd_comm", "replace_var": "@userId"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-67, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：施設内職員ID(伝票情報部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -8, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
