DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" in (-400013);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400013, 'WITH
query0 AS (--酸素吸入用薬剤コード
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::text as oxygen_medi_cd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''OXYGEN_CODE''),
query1 AS (--酸素吸入量
	SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue1
	FROM
		( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main ord WHERE ord.ord_no = @ordNo
 ) T
	),
query2 AS (--愁訴処置の酸素吸入用薬剤量
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
				jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''treat_medicine_cd'' AS treat_medicine_cd
			FROM
				ord_main ord
			WHERE
				ord.ord_no =@ordNo
			) A ,mst_medicine mme ,query0
			WHERE A.treat_medicine_cd = mme.medicine_cd::text
      and 
			mme.in_hospital_cd_1 = query0.oxygen_medi_cd
		) T
	) ,
query3 AS (--投与薬剤の酸素吸入用薬剤量
		SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue3
	FROM
		(
		SELECT A
			.result_value
		FROM
			(
			SELECT
				jsonb_array_elements ( ord.rst_medi_info :: jsonb ) ->> ''amount'' AS result_value,
				jsonb_array_elements ( ord.rst_medi_info :: jsonb ) ->> ''cd'' AS medicine_cd
			FROM
				ord_main ord
			WHERE
				ord.ord_no =@ordNo
			) A ,mst_medicine mme,query0
			WHERE A.medicine_cd = mme.medicine_cd::text
      and 
			mme.in_hospital_cd_1 = query0.oxygen_medi_cd
		) T
	),
query4 AS (--合算値
SELECT
(COALESCE(query1.sumResultValue1,0)+ COALESCE(query2.sumResultValue2,0)+COALESCE(query3.sumResultValue3,0))  AS oxygen_amount
FROM
	query1,
	query2,
	query3)
SELECT
	trim(to_char((query4.oxygen_amount)*100,''999999'')) AS oxygen_amount
	from query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-15 08:44:53.101', CURRENT_TIMESTAMP, NULL);
