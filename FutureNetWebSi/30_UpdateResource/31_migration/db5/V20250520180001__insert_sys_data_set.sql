DELETE FROM	sys_data_set WHERE sql_cd =-1104003;

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104003, 'WITH receiptinfo_file_name AS (
SELECT
	COALESCE(NULLIF(info ->> ''value'',
	''''),
	info ->> ''default_v'') AS value
FROM
	MST_COOP_INI ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
	1 = 1
	AND ini.FACILITY_CD = @facilityCd
	AND ini.IS_DEL = ''0''
	AND info ->> ''key1'' = ''SCM_RECEIPTINFO_SEND''
	AND info ->> ''key2'' = ''RECEIPTINFO_FILE_NAME'' )
SELECT
	receiptinfo_file_name.value || TO_CHAR(scj.reg_date,
	''YYYYMMDDHH24MISS'') || ''.csv'' AS filename
FROM
	receiptinfo_file_name
JOIN sys_coop_journal scj ON
	scj.ORD_NO = @ordNo
	AND scj.FACILITY_CD = @facilityCd
	AND scj.COOP_CD = ''accept''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'セコム連携 再来受付ファイル名', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', NULL);