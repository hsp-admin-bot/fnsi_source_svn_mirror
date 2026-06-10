delete from sys_data_set where sql_cd = 9999;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9999, 'select severity_cd as s_cd from mst_severity where
  in_hospital_cd_1 = @severityCd 
	and facility_cd = @facilityCd
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 9998;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9998, 'select transport_cd as t_cd from mst_transport where
  in_hospital_cd_1 = @transportCd 
	and facility_cd = @facilityCd
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（搬送区分）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
