delete from ntss.sys_data_set where sql_cd in (2020, 2021);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2020, '

	
SELECT 
(CASE
WHEN @dispUserId = '''' THEN
''''
ELSE
(SELECT
	COALESCE(NULLIF(user_id::TEXT, '''')) 
FROM
	mst_user_authentication
WHERE
	disp_user_id = @dispUserId
	AND 
	facility_cd = @facilityCd)
END) AS staff_cd
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 2021, "field_name": "disp_user_id", "replace_var": "@dispUserId"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2021, '
  SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS disp_user_id
  FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''ORDER_RECV'' 
	AND info ->> ''key2'' = ''ORDER_RECV_BBS_STAFF''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
