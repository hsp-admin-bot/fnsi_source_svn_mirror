DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-951,-952);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-951, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[{}]', '0', '{"applications": [4]}', NULL, '透析予約：施設内職員ID(共通部)取得', '2022-07-08 02:16:54.402', CURRENT_TIMESTAMP, '[{"sql_cd": -753, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -753, "field_name": "code", "replace_var": "@code"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-952, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-08 02:16:54.421', CURRENT_TIMESTAMP, '[{"sql_cd": -852, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -852, "field_name": "code", "replace_var": "@code"}]');
