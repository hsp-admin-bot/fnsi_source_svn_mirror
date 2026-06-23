DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-952);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-952, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -852, "field_name": "staff_cd", "replace_var": "@userId"}]');
