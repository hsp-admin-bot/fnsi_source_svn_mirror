delete from ntss.sys_data_set where sql_cd in (-71, -72);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-71, '
SELECT
	( CASE @userId::text 
	WHEN '''' THEN 
	  @defaultStaffCd
	ELSE 
	(SELECT disp_user_id
	FROM mst_user_authentication 
	WHERE user_id::text = @userId )
	END ) AS disp_user_id ', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：施設内職員ID(共通部)取得', '2022-05-09 13:19:29.676', CURRENT_TIMESTAMP, '[{"sql_cd": -666, "field_name": "default_staff_cd", "replace_var": "@defaultStaffCd"}, {"sql_cd": -666, "field_name": "staff_cd_comm", "replace_var": "@userId"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-72, '
SELECT
	( CASE @userId::text 
	WHEN '''' THEN 
	  @defaultStaffCd
	ELSE 
	(SELECT disp_user_id
	FROM mst_user_authentication 
	WHERE user_id::text = @userId )
	END ) AS disp_user_id 
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：施設内職員ID(内容部)取得', '2022-05-09 13:19:29.676', CURRENT_TIMESTAMP, '[{"sql_cd": -666, "field_name": "default_staff_cd", "replace_var": "@defaultStaffCd"}, {"sql_cd": -666, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
