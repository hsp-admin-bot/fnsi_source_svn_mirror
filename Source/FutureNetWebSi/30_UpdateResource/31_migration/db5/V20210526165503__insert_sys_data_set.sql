INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11042, 'WITH A AS (
	SELECT
		pat_id,
		MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
	GROUP BY
		pat_id 
	),
	B AS (
	SELECT
		pat_id,
		inOutInfo ->> ''ctl_no'' AS ctl_no,
		inOutInfo ->> ''in_out'' AS in_out 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
	),
	in_out AS (
	SELECT
		B.pat_id,
		B.in_out
		
	FROM
		A INNER JOIN B ON A.pat_id = B.pat_id 
		AND A.ctl_no = B.ctl_no 
	)
SELECT COUNT
	( * ) AS COUNT 
FROM
	ord_main
	LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
	ord_main.treat_date BETWEEN @dateFrom 
	AND @dateTo 
	AND in_out.in_out = ''0''
	AND ord_main.facility_cd = @facilityCd 
	AND ord_main.is_del = ''0''
	;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', '2020-05-26 16:49:21', NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11041, 'WITH A AS (
	SELECT
		pat_id,
		MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
	GROUP BY
		pat_id 
	),
	B AS (
	SELECT
		pat_id,
		inOutInfo ->> ''ctl_no'' AS ctl_no,
		inOutInfo ->> ''in_out'' AS in_out 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
	),
	in_out AS (
	SELECT
		B.pat_id,
		B.in_out
		
	FROM
		A INNER JOIN B ON A.pat_id = B.pat_id 
		AND A.ctl_no = B.ctl_no 
	)
SELECT COUNT
	( * ) AS COUNT 
FROM
	ord_main
	LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
	ord_main.treat_date BETWEEN @dateFrom 
	AND @dateTo 
	AND in_out.in_out = ''1''
	AND ord_main.facility_cd = @facilityCd 
	AND ord_main.is_del = ''0''
	;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', '2020-05-26 16:49:21', NULL);