DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" in (-400013);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400013, 'WITH
query1 AS (
	SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue1
	FROM
		( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main ord WHERE ord.ord_no = @ordNo
 ) T
	),
query2 AS (
	SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue2
	FROM
		(
		SELECT A
			.result_value
		FROM
			(
			SELECT
				jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''amount'' AS result_value,
				jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''treat_name'' AS treat_name
			FROM
				ord_main ord
			WHERE
				ord.ord_no = @ordNo

			) A
		WHERE
			A.treat_name = ''酸素吸入''
		) T
	) ,
query3 AS (
SELECT
case when 	query2.sumResultValue2 is null
THEN query1.sumResultValue1
ELSE ( query1.sumResultValue1 + query2.sumResultValue2) END AS oxygen_amount
FROM
	query1,
	query2)
SELECT
	trim(to_char((query3.oxygen_amount)*100,''999999'')) AS oxygen_amount
	from query3', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
