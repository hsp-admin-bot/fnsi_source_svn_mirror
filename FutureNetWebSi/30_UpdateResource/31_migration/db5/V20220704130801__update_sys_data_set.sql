DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (1999);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1999, 'update pat_personal_main 
set transport_cd = (case when ''@transportCd'' = '''' then null else ''@transportCd'' end)::integer
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', '2022-06-23 03:50:33.382', '2022-07-04 02:25:08.867', NULL);
