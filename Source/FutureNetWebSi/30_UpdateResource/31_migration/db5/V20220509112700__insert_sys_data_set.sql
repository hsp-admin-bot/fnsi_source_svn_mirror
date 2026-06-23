INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400004, '  SELECT
    dialysis_difficulty_name as dial_diff_name
  FROM
    mst_dialysis_difficulty
  WHERE
    facility_cd =@facilityCd
    AND is_del = ''0''
    AND dialysis_difficulty_cd = @cd', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -16, "field_name": "cd", "replace_var": "cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400003, '  SELECT
   COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS padding_side
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd =@facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONV_PADDING_TO_FNW''
    AND info ->> ''key2'' = ''SIDE'' ', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400002, 'SELECT
CASE
		@paddingSide
		WHEN ''0'' THEN
		lpad( hosp_pat_id, 12, ''0'' ) ELSE rpad( hosp_pat_id, 12, ''0'' )
	END AS hosp_pat_id
FROM
	pat_personal_main
WHERE
	is_del = ''0''
	AND pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -400003, "field_name": "padding_side", "replace_var": "@paddingSide"}]');
