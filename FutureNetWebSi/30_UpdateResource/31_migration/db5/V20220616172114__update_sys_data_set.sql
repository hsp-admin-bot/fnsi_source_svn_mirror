delete from sys_data_set where sql_cd = 9611;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9611, 'select severity_cd from pat_personal_main where
  pat_id = @patId 
  and is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


delete from sys_data_set where sql_cd = 9612;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9612, 'update pat_personal_main 
set severity_cd = @severityCd 
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




