DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1201008);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201008, 'SELECT COALESCE(
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
	AND info ->> ''key1'' = ''SX_PAT_INFO''
	AND info ->> ''key2'' = ''PAT_ALIGN''
    LIMIT 1
  ),
  ''0'' -- ← データが存在しない場合、0
) AS aligh;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, NULL);
