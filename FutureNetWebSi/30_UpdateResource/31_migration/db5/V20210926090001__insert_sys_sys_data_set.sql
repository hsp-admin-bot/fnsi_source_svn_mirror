DELETE FROM "sys_data_set" WHERE "sql_cd" = -443 OR "sql_cd" = -442;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-443, 'SELECT

	''検査項目'' AS detail_id,

	info ->> ''item_cd'' AS item_cd,

	info ->> ''item_name'' AS item_name,

	item.exam_item_name AS exam_item_name,

	P.reg_exam_date AS reg_exam_date,

	item.in_hospital_cd1 AS in_hospital_cd1,

	COALESCE ( item.sbt_cd1, ''ET1'' ) AS sbt_cd1,

	item.in_hospital_cd2 AS in_hospital_cd2,

	item.sbt_cd2 AS sbt_cd2,

	item.in_hospital_cd3 AS in_hospital_cd3,

	item.sbt_cd3 AS sbt_cd3,

	item.unit AS unit,

	TRIM ( to_char( item.spitz_cd, ''999999999'' ) ) AS spitz_cd,

	spitz.spitz_name AS spitz_name

FROM

	(

	SELECT M

		.* 

	FROM

		pat_exam_main AS M 

	WHERE

		M.is_del = ''0'' 

		AND M.exam_status = ''0''

		AND jsonb_array_length ( M.order_exam_set_info ) > 0 

		AND M.exam_main_cd = @ordNo  

	)

	P CROSS JOIN LATERAL json_array_elements ( P.exam_order_info :: json ) info

	LEFT OUTER JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' )

	LEFT OUTER JOIN mst_spitz AS spitz ON item.spitz_cd = spitz.spitz_cd 

WHERE

	COALESCE ( item.in_hospital_cd1, ''no_cd'' ) <> ''no_cd''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI検査オーダ(連携電文の検査項目)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-442, 'SELECT

	M1.reg_order_class,

	TO_CHAR( M1.reg_exam_date, ''YYYYMMDD'' ) AS reg_exam_date,

	M1.ind_user_id,

	M1.reg_staff,

	M1.up_staff,

	TO_CHAR( M1.up_date, ''YYYY-MM-DD HH24:MI'' ) AS up_date,

-- 診療科マスタ

	pat.medical_care_info ->> ''main_course_cd'' AS course_cd,

	course.course_name AS course_name,

	COALESCE ( TRIM ( course.in_hospital_cd_1 ), CAST ( course.course_cd AS VARCHAR ) ) AS course_cd1,

-- 透析前/透析後開始時刻

	'''' AS standard_start_time,

-- 透析後予定透析時間

	'''' AS ind_dialysis_time,

-- その他開始時刻

	'''' AS other_exam_time,

-- 血液検査セットコード

	info ->> ''set_cd'' AS exam_set_cd 

FROM

	pat_exam_main AS M1

	LEFT JOIN LATERAL json_array_elements ( M1.order_exam_set_info :: json ) info ON info ->> ''set_name'' LIKE''%血液%''

	INNER JOIN pat_main AS pat ON pat.pat_id = M1.pat_id

	LEFT JOIN mst_course AS course ON course.course_cd :: TEXT = pat.medical_care_info ->> ''main_course_cd'' 

WHERE

	M1.is_del = ''0'' 

	AND M1.exam_status = ''0'' 

	AND M1.exam_main_cd = @ordNo   

	LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI検査オーダ(連携電文の検査スケジュール)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
