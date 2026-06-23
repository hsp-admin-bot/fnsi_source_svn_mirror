DELETE FROM "ntss"."sys_data_set" where "sql_cd" = 1888;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1888, 'select
	transport_cd
from
	pat_personal_main 
where
	pat_id = @patId
	and 
	is_del = ''0''
	', 3, '[{}]', '0', '{"applications": [4]}', NULL, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where "sql_cd" = 1999;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1999, 'update pat_personal_main
set transport_cd = @transportCd
where
pat_id = @patId

', 3, '[{}]', '0', '{"applications": [4]}', NULL, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
