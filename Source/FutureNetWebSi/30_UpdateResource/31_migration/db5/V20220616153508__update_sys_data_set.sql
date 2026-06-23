DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN ('7204', '9610');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9610, 'SELECT implant_cd FROM mst_implant WHERE facility_cd = @facilityCd AND implant_cd = @implantInfo.implantCd;', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '(受信用)日機装の患者プロファイル(インプラント情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7204, 'UPDATE pat_main 
SET implant_info =
CASE WHEN (''@implantInfoFlg'' = '''') THEN
    ''@implantInfoValue'' 
ELSE
    CASE WHEN json_array_contains_array_value(COALESCE(implant_info, ''[]''), ''content'',  ''@implantInfo.content'') THEN
	  implant_info
	ELSE
	  implant_info || ''[{"ctl_no":"@nextCtlNo5", "disp_order":"@implantInfo.dispOrder", "implant_cd":"@implantInfo.implantCd", "reg_date":"@implantInfo.regDate", "remove_date":"@implantInfo.removeDate"}]'' :: jsonb 
	END 
END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(インプラント情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 9610, "field_name": "implant_cd", "replace_var": "@implantInfo.implantCd"}]');
