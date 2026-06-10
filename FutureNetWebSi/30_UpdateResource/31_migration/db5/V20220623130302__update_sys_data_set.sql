delete from sys_data_set where sql_cd = 9612; 
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9612, 'update pat_personal_main 
set severity_cd = case when @severityCd is null then null else @severityCd::integer end
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', '2022-06-22 07:10:58.039', CURRENT_TIMESTAMP, NULL);
