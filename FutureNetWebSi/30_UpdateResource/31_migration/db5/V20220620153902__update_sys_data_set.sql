delete from sys_data_set where sql_cd = 9612;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9612, 'update pat_personal_main set severity_cd = case when @sCd is null then null else @sCd::integer end where pat_id = @patId
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', '2022-06-19 07:42:57.567', CURRENT_TIMESTAMP, '[{"sql_cd": 9999, "field_name": "s_cd", "replace_var": "@sCd"}]');
delete from sys_data_set where sql_cd = 1999;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1999, 'update pat_personal_main set transport_cd = case when @tCd is null then null else @tCd::integer end where pat_id = @patId
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', '2022-06-19 07:42:57.47', CURRENT_TIMESTAMP, '[{"sql_cd": 9998, "field_name": "t_cd", "replace_var": "@tCd"}]');
