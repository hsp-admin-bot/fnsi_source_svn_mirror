delete from "ntss"."sys_data_set" where "sql_cd" = -400013;
delete from "ntss"."sys_data_set" where "sql_cd" = -509;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400013, '-- 【SQL_CD=-400013】
WITH query0 AS (--酸素吸入用薬剤コード
	SELECT COALESCE
		( info ->> ''value'', info ->> ''default_v'' ) :: TEXT AS oxygen_medi_cd 
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
	WHERE
		facility_cd = @facilityCd 
		AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		
		AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
		
		AND info ->> ''key1'' = ''DIALYSISSEND'' 
		AND info ->> ''key2'' = ''OXYGEN_CODE'' 
	),
	query1 AS (--酸素吸入量
	SELECT
		(
		CASE
				
				WHEN ''1'' = (
				SELECT COALESCE
					( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
				FROM
					mst_coop_ini AS ini
					CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
				WHERE
					facility_cd = @facilityCd 
					AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
					
					AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
					
					AND info ->> ''key1'' = ''DIALYSISSEND'' 
					AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
					) THEN
				CASE
						
						WHEN SUM ( K.sumresultvalue1 :: INTEGER ) > 999 THEN
						( SUM ( K.sumresultvalue1 :: INTEGER ) :: TEXT ) ELSE ( to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm000'' ) ) 
					END ELSE ( SUM ( K.sumResultValue1 :: INTEGER ) ) :: TEXT 
				END 
				) AS sumResultValue1 
			FROM
				(
				SELECT
					(
					CASE
							
							WHEN ''1'' = (
							SELECT COALESCE
								( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
							FROM
								mst_coop_ini AS ini
								CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
							WHERE
								facility_cd = @facilityCd 
								AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
								
								AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
								
								AND info ->> ''key1'' = ''DIALYSISSEND'' 
								AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
							) 
							AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
								(
								CASE
										
										WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
										''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
									END 
									) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
								END 
								) AS sumResultValue1 
							FROM
								( SELECT jsonb_array_elements ( ord.rst_treatment_info :: JSONB ) ->> ''oxygen_amount'' AS result_value FROM ord_main ord WHERE ord.ord_no = @ordNo ) T 
							) K 
						),
						query2 AS (--愁訴処置の酸素吸入用薬剤量
						SELECT
							(
							CASE
									
									WHEN ''1'' = (
									SELECT COALESCE
										( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
									FROM
										mst_coop_ini AS ini
										CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
									WHERE
										facility_cd = @facilityCd 
										AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
										
										AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
										
										AND info ->> ''key1'' = ''DIALYSISSEND'' 
										AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
										) THEN
									CASE
											
											WHEN SUM ( K.sumResultValue2 :: INTEGER ) > 999 THEN
											( SUM ( K.sumResultValue2 :: INTEGER ) :: TEXT ) ELSE ( to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm000'' ) ) 
										END ELSE ( SUM ( K.sumResultValue2 :: INTEGER ) ) :: TEXT 
									END 
									) AS sumResultValue2 
								FROM
									(
									SELECT
										(
										CASE
												
												WHEN ''1'' = (
												SELECT COALESCE
													( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
												FROM
													mst_coop_ini AS ini
													CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
												WHERE
													facility_cd = @facilityCd 
													AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
													
													AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
													
													AND info ->> ''key1'' = ''DIALYSISSEND'' 
													AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
												) 
												AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
													(
													CASE
															
															WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
															''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
														END 
														) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
													END 
													) AS sumResultValue2 
												FROM
													(
													SELECT A
														.result_value 
													FROM
														(
														SELECT
															jsonb_array_elements ( ord.rst_treatment_info :: JSONB ) ->> ''amount'' AS result_value,
															jsonb_array_elements ( ord.rst_treatment_info :: JSONB ) ->> ''treat_medicine_cd'' AS treat_medicine_cd 
														FROM
															ord_main ord 
														WHERE
															ord.ord_no = @ordNo 
														) A,
														mst_medicine mme,
														query0 
													WHERE
														A.treat_medicine_cd = mme.medicine_cd :: TEXT 
														AND mme.in_hospital_cd_1 = query0.oxygen_medi_cd 
													) T 
												) K 
											),
											query3 AS (--投与薬剤の酸素吸入用薬剤量
											SELECT
												(
												CASE
														
														WHEN ''1'' = (
														SELECT COALESCE
															( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
														FROM
															mst_coop_ini AS ini
															CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
														WHERE
															facility_cd = @facilityCd 
															AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
															
															AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
															
															AND info ->> ''key1'' = ''DIALYSISSEND'' 
															AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
															) THEN
														CASE
																
																WHEN SUM ( K.sumResultValue3 :: INTEGER ) > 999 THEN
																( SUM ( K.sumResultValue3 :: INTEGER ) :: TEXT ) ELSE ( to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm000'' ) ) 
															END ELSE ( SUM ( K.sumResultValue3 :: INTEGER ) ) :: TEXT 
														END 
														) AS sumResultValue3 
													FROM
														(
														SELECT
															(
															CASE
																	
																	WHEN ''1'' = (
																	SELECT COALESCE
																		( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
																	FROM
																		mst_coop_ini AS ini
																		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
																	WHERE
																		facility_cd = @facilityCd 
																		AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
																		
																		AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
																		
																		AND info ->> ''key1'' = ''DIALYSISSEND'' 
																		AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
																	) 
																	AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
																		(
																		CASE
																				
																				WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
																				''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
																			END 
																			) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
																		END 
																		) AS sumResultValue3 
																	FROM
																		(
																		SELECT A
																			.result_value 
																		FROM
																			(
																			SELECT
																				jsonb_array_elements ( ord.rst_medi_info :: JSONB ) ->> ''amount'' AS result_value,
																				jsonb_array_elements ( ord.rst_medi_info :: JSONB ) ->> ''cd'' AS medicine_cd 
																			FROM
																				ord_main ord 
																			WHERE
																				ord.ord_no = @ordNo 
																			) A,
																			mst_medicine mme,
																			query0 
																		WHERE
																			A.medicine_cd = mme.medicine_cd :: TEXT 
																			AND mme.in_hospital_cd_1 = query0.oxygen_medi_cd 
																		) T 
																	) K 
																),
																query4 AS (--合算値
																SELECT
																	(
																		COALESCE ( ( query1.sumResultValue1 :: INTEGER ), 0 ) + COALESCE ( ( query2.sumResultValue2 :: INTEGER ), 0 ) + COALESCE ( ( query3.sumResultValue3 :: INTEGER ), 0 ) 
																	) AS oxygen_amount 
																FROM
																	query1,
																	query2,
																	query3 
																) SELECT
																(
																CASE
																		
																		WHEN ''1'' = (
																		SELECT COALESCE
																			( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
																		FROM
																			mst_coop_ini AS ini
																			CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
																		WHERE
																			facility_cd = @facilityCd 
																			AND is_del = ''0'' -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
																			
																			AND COALESCE ( info ->> ''key0'', '''' ) = @key0 -- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
																			
																			AND info ->> ''key1'' = ''DIALYSISSEND'' 
																			AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
																			) THEN
																		CASE
																				
																				WHEN ( query4.oxygen_amount :: INTEGER ) > 999 THEN
																				( ( query4.oxygen_amount :: INTEGER ) :: TEXT ) ELSE ( to_char( ( query4.oxygen_amount :: INTEGER ), ''fm000'' ) ) 
																			END ELSE ( ( query4.oxygen_amount :: INTEGER ) :: TEXT ) 
																		END 
																		) AS oxygen_amount 
																FROM
	query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-15 08:44:53.101', CURRENT_TIMESTAMP, NULL);
	
	INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-509, '-- 【SQL_CD=-512】
WITH 
ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	),
query0 AS (--酸素吸入用薬剤コード
	SELECT COALESCE
		( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) :: TEXT AS oxygen_medi_cd 
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	WHERE
		facility_cd = @facilityCd 
		AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
		AND info ->> ''key1'' = ''DIALYSISSEND'' 
		AND info ->> ''key2'' = ''OXYGEN_CODE'' 
	),
	query1 AS (--酸素吸入量
	SELECT
		(
		CASE
				WHEN ''1'' = (
				SELECT COALESCE
					( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
				FROM
					mst_coop_ini AS ini
					CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
				WHERE
					facility_cd = @facilityCd 
					AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
					AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
					AND info ->> ''key1'' = ''DIALYSISSEND'' 
					AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
					) THEN CASE WHEN SUM ( K.sumresultvalue1 :: INTEGER ) > 999 THEN SUM ( K.sumresultvalue1 :: INTEGER ) :: TEXT ELSE
					( to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm000'' ) ) end ELSE ( SUM ( K.sumResultValue1 :: INTEGER ))::text 
				END 
				) AS sumResultValue1 
			FROM
				(
				SELECT
					(
					CASE
							WHEN ''1'' = (
							SELECT COALESCE
								( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
							FROM
								mst_coop_ini AS ini
								CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
							WHERE
								facility_cd = @facilityCd 
								AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
								AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
								AND info ->> ''key1'' = ''DIALYSISSEND'' 
								AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
							) 
							AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
								(
								CASE
										WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
										''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
									END 
									) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
								END 
								) AS sumResultValue1 
							FROM
								( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main_restore_info  ord) T 
							) K 
						),
						query2 AS (--愁訴処置の酸素吸入用薬剤量
						SELECT
							(
							CASE
									WHEN ''1'' = (
									SELECT COALESCE
										( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
									FROM
										mst_coop_ini AS ini
										CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
									WHERE
										facility_cd = @facilityCd 
										AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
										AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end 
										AND info ->> ''key1'' = ''DIALYSISSEND'' 
										AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
										) THEN CASE WHEN SUM ( K.sumresultvalue2 :: INTEGER ) > 999 THEN SUM ( K.sumresultvalue2 :: INTEGER ) :: TEXT ELSE
										( to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm000'' ) ) end ELSE ( SUM ( K.sumResultValue2 :: INTEGER ))::text 
									END 
									) AS sumResultValue2 
								FROM
									(
									SELECT
										(
										CASE
												WHEN ''1'' = (
												SELECT COALESCE
													( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
												FROM
													mst_coop_ini AS ini
													CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
												WHERE
													facility_cd = @facilityCd 
													AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
													AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
													AND info ->> ''key1'' = ''DIALYSISSEND'' 
													AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
												) 
												AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
													(
													CASE
															WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
															''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
														END 
														) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
													END 
													) AS sumResultValue2 
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
															ord_main_restore_info ord
														) A,
														mst_medicine mme,
														query0 
													WHERE
														A.treat_medicine_cd = mme.medicine_cd :: TEXT 
														AND mme.in_hospital_cd_1 = query0.oxygen_medi_cd 
													) T 
												) K 
											),
											query3 AS (--投与薬剤の酸素吸入用薬剤量
											SELECT
												(
												CASE
														WHEN ''1'' = (
														SELECT COALESCE
															( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
														FROM
															mst_coop_ini AS ini
															CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
														WHERE
															facility_cd = @facilityCd 
															AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
															AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
															AND info ->> ''key1'' = ''DIALYSISSEND'' 
															AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
															) THEN CASE WHEN SUM ( K.sumresultvalue3 :: INTEGER ) > 999 THEN SUM ( K.sumresultvalue3 :: INTEGER ) :: TEXT ELSE
															( to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm000'' ) ) end ELSE ( SUM ( K.sumResultValue3 :: INTEGER ))::text 
														END 
														) AS sumResultValue3 
													FROM
														(
														SELECT
															(
															CASE
																	WHEN ''1'' = (
																	SELECT COALESCE
																		( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
																	FROM
																		mst_coop_ini AS ini
																		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
																	WHERE
																		facility_cd = @facilityCd 
																		AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
																		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
																		AND info ->> ''key1'' = ''DIALYSISSEND'' 
																		AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
																	) 
																	AND ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 < 100 THEN
																		(
																		CASE
																				WHEN ( COALESCE ( T.result_value, ''0'' ) :: FLOAT ) * 100 > 10 THEN
																				''0'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) ELSE''00'' || ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: TEXT ) 
																			END 
																			) ELSE ( ( COALESCE ( T.result_value, ''0'' ) :: FLOAT * 100 ) :: INTEGER ) :: TEXT 
																		END 
																		) AS sumResultValue3 
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
																			ord_main_restore_info ord
																			) A,
																			mst_medicine mme,
																			query0 
																		WHERE
																			A.medicine_cd = mme.medicine_cd :: TEXT 
																			AND mme.in_hospital_cd_1 = query0.oxygen_medi_cd 
																		) T 
																	) K 
																),
																query4 AS (--合算値
																SELECT
																	(
																		COALESCE ( ( query1.sumResultValue1 :: INTEGER ), 0 ) + COALESCE ( ( query2.sumResultValue2 :: INTEGER ), 0 ) + COALESCE ( ( query3.sumResultValue3 :: INTEGER ), 0 ) 
																	) AS oxygen_amount 
																FROM
																	query1,
																	query2,
																	query3 
																) SELECT
																(
																CASE
																		WHEN ''1'' = (
																		SELECT COALESCE
																			( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
																		FROM
																			mst_coop_ini AS ini
																			CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
																		WHERE
																			facility_cd = @facilityCd 
																			AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
																			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
																			AND info ->> ''key1'' = ''DIALYSISSEND'' 
																			AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
																			) THEN CASE WHEN ( query4.oxygen_amount :: INTEGER ) > 999 THEN ( ( query4.oxygen_amount :: INTEGER ) :: TEXT ) ELSE
																			( to_char( ( query4.oxygen_amount :: INTEGER ), ''fm000'' ) ) end ELSE ( ( query4.oxygen_amount :: INTEGER )::text) 
																		END 
																		) AS oxygen_amount 
																FROM
	query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:酸素吸入量（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);

