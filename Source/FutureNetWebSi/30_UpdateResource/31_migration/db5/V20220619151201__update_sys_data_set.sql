DELETE FROM "ntss"."sys_data_set" where "sql_cd" = -400012;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400012, 'WITH dialysateSql AS (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as dialysateTransCd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
SELECT
	CASE when (ord.rst_cond_info -> ''17'' ->> ''value'') ISNULL
	THEN (case dialysateSql.dialysateTransCd
	   WHEN 0 THEN ''0''
	   WHEN 1 THEN ''000'' END)
  WHEN
  (ord.rst_cond_info -> ''17'' ->> ''value'')::numeric >= 1
	THEN (case when strpos((ord.rst_cond_info -> ''17'' ->> ''value''), ''.'') <= 0 then
	     trim(to_char(((ord.rst_cond_info -> ''17'' ->> ''value'')::numeric)*100,''999999''))
	     else trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,strpos((ord.rst_cond_info -> ''17'' ->> ''value''), ''.'')+3)::numeric)*100,''999999'')) end )
	ELSE (case dialysateSql.dialysateTransCd
	WHEN 0 THEN trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,5)::numeric)*100,''99''))
	WHEN 1 THEN trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,5)::numeric)*100,''000''))
  END )
	END AS dialysate_amount
	from ord_main ord,dialysateSql
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-11 06:40:08.234', CURRENT_TIMESTAMP, NULL);
