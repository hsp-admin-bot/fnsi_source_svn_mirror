DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in(-67,-197);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-67, '--67
SELECT
	( CASE @userId::text 
	WHEN '''' THEN 
	  @defaultStaffCd
	ELSE 
	(SELECT disp_user_id
	FROM mst_user_authentication 
	WHERE user_id::text = @userId )
	END ) AS disp_user_id ', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：施設内職員ID(伝票情報部)取得', '2022-05-02 13:29:17.912',CURRENT_TIMESTAMP, '[{"sql_cd": -8, "field_name": "default_staff_cd", "replace_var": "@defaultStaffCd"}, {"sql_cd": -8, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-197, '--197
SELECT
	( CASE @userId::text 
	WHEN '''' THEN 
	  @defaultStaffCd
	ELSE 
	(SELECT disp_user_id
	FROM mst_user_authentication 
	WHERE user_id::text = @userId )
	END ) AS disp_user_id ', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：施設内職員ID(伝票情報部)取得', '2022-10-08 02:24:54.732',CURRENT_TIMESTAMP, '[{"sql_cd": -195, "field_name": "default_staff_cd", "replace_var": "@defaultStaffCd"}, {"sql_cd": -195, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
