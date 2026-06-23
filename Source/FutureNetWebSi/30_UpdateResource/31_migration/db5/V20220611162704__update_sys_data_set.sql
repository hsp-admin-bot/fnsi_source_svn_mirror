DELETE FROM "ntss"."sys_data_set" where "sql_cd" in (1050);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1050, 'UPDATE pat_personal_main 
SET pat_contact_info =
CASE 
    (''@patContactInfo.memo1.title''||''@patContactInfo.memo1.content'')
		WHEN '''' THEN
		''@patContactInfoValue'' ELSE pat_contact_info||''{"memo1":"【@patContactInfo.memo1.title】@patContactInfo.memo1.content"}'' :: jsonb
	END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
	', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモの修正', '2022-06-11 07:38:42.336',  CURRENT_TIMESTAMP, NULL);
