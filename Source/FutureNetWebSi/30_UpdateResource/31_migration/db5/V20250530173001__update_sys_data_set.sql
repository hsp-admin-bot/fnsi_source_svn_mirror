DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201020,-1200002,-1200003,-1200001,-1201007,-1201008,-1201009);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201020, 'SELECT
  ''DIAJSK-'' || 
  coalesce(journal.coop_ord_no, '''')  ||
  ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISSMS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_透析実績[送信]ファイル名取得', '2025-05-30 16:50:14.617', '2025-05-30 16:50:14.617', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1200002, 'SELECT COALESCE(
  (
SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' )
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND COALESCE(info->>''key0'','''') = @key0
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''PAT_ALIGN''
    LIMIT 1
  ),
  ''0'' -- ← データが存在しない場合、0
) AS aligh;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1200003, 'SELECT COALESCE(
  (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND COALESCE(info->>''key0'','''') = @key0
	AND info ->> ''key1'' = ''SX_PAT_INFO''
	AND info ->> ''key2'' = ''PAT_LENGTH''
    LIMIT 1
  ),
  ''12'' -- ← データが存在しない場合、12
) AS len;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1200001, 'SELECT
CASE
		@aligh
		WHEN ''0'' THEN
	lpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'') else rpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'')
	END AS hosp_pat_id
FROM
	pat_personal_main
WHERE
	is_del = ''0''
	AND pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": -1200003, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -1200002, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);
