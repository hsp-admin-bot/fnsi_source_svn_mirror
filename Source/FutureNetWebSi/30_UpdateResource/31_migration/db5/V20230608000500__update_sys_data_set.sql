DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -400013;

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -504;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -503;

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -496;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -512;

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -108;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -509;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = -109;

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400013, '-- 【SQL_CD=-400013】
WITH query0 AS (--酸素吸入用薬剤コード
	SELECT COALESCE
		( info ->> ''value'', info ->> ''default_v'' ) :: TEXT AS oxygen_medi_cd 
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
					) THEN
					( to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue1 :: INTEGER ))::text 
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
								( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main ord WHERE ord.ord_no = @ordNo ) T 
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
										) THEN
										( to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue2 :: INTEGER ))::text 
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
															CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
														WHERE
															facility_cd = @facilityCd 
															AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
															AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
															AND info ->> ''key1'' = ''DIALYSISSEND'' 
															AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
															) THEN
															( to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue3 :: INTEGER ))::text 
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
																			CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
																		WHERE
																			facility_cd = @facilityCd 
																			AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
																			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
																			AND info ->> ''key1'' = ''DIALYSISSEND'' 
																			AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
																			) THEN
																			( to_char( ( query4.oxygen_amount :: INTEGER ), ''fm000'' ) ) ELSE ( ( query4.oxygen_amount :: INTEGER )::text) 
																		END 
																		) AS oxygen_amount 
																FROM
	query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-15 08:44:53.101', CURRENT_TIMESTAMP, NULL);


INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-503, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
order by del_date desc limit 1
)
, EQUIP_OUTPUT_TYPE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
, CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
, KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, RST_COND_INFO AS (
SELECT ord.rst_cONd_info :: jsON ->''25'' ->> ''value'' AS mix_cd, 
             ord.rst_cONd_info :: jsON ->''25'' ->> ''medicine_type'' AS mix_medicine_type, 
             to_number(ord.rst_cONd_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.rst_cONd_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count,
             CASE WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END AS falgF
FROM do_ord_main AS ord
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_codmst_coop_distributee, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_class'' 
)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_mix'' 
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_procedure'' 
)
, rst_cond_info_K AS (
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
      (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      do_ord_main AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info:: json ->''25'' ->> ''value'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = mmd.medicine_cd
  WHERE
      ord.rst_cond_info:: json ->''25'' ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( mmx.class_cd :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''effect_flg'' = ''1'' 
  AND medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_2_m AS (
SELECT * FROM (
        SELECT item_cd, login_ord, 
            CASE WHEN medi_class_M_cd IS NULL THEN 0 ELSE medi_class_M_cd END AS medi_class_M_cd
            , medicine_type, medicine_mix_cd, 
            CASE WHEN timing_cd IS NULL THEN 0 ELSE timing_cd END AS timing_cd,       
            CASE WHEN procedure_cd IS NULL THEN 0 ELSE procedure_cd END AS procedure_cd, 
            CASE WHEN date_interval IS NULL THEN 0 ELSE date_interval END AS date_interval, class_M_cd, mix_M_cd 
    FROM do_medicine_mix_1) AS middle_data
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM do_medicine_mix_2_m
    ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS mid_data
)
, do_medicine_mix_3 AS (
SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_4 AS (
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM do_medicine_mix_3
        GROUP BY mix_M_cd)
)
, do_medicine_mix_dis AS (
   SELECT 
      TRIM(item_cd) AS item_cd_m_dis,
      MIN(no2) AS ord_mk_dis
   FROM
      do_medicine_mix_2
   GROUP BY item_cd_m_dis
     ORDER BY ord_mk_dis
)
, do_medicine_mix AS (
   SELECT 
      login_ord_in_mm AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, do_medicine_mix_2.medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM do_medicine_mix_dis 
                LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
                LEFT JOIN do_medicine_mix_4 ON do_medicine_mix_4.medicine_mix_cd = mix_M_cd 
                                                                        AND do_medicine_mix_4.item_cd_mm = item_cd   
)
, middle_data AS (
SELECT
  ''薬剤del'' AS detail_id,
  all_cost.e01 AS item_cd,
  (CASE WHEN all_cost.e08 = ''1'' THEN
                    (sum(all_cost.e04::float)*100::INTEGER)::text
             ELSE
                CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END)  THEN  ((sum(all_cost.e04::float)*100)::INTEGER)::text
                             ELSE
                 case when((sum(all_cost.e04::float)*100)::INTEGER)>99 then (((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else case when ((sum(all_cost.e04::float)*100)::INTEGER)>10 
                                then ''0''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else ''00''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) end
                                end
                             END

             END) AS amount
FROM (
    (
  SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                                             mmd.medicine_name AS e02,
                                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) AS e04,
                                                             mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                                             mmd.medicine_name AS e02,
                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) AS e04,
                                             mmd.unit AS e05,
                                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            )) AS all_cost GROUP BY item_cd,all_cost.e05,all_cost.e08
)
, data_middle_all AS (
SELECT
  ''薬剤del'' AS detail_id,
  all_cost.e01 AS item_cd,
  (SELECT middle_data.amount FROM middle_data WHERE middle_data.item_cd = all_cost.e01) AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
  UNION ALL
    SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
         meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--投与薬剤情報(調製)
      ''薬剤del'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
      to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07,
          ''0'' AS e08  
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
            ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM99990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM99990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) as all_cost1 where all_cost1.e01 = all_cost.e01) count
            , all_cost.e09 AS cond_info_jyun, medi_type AS medi_type
FROM
  (
  SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''1'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''2'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''0'' AS e09,
      ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
    ''4'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08, 
    ''4'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08,
      ''4'' AS e09,
      ''1'' AS medi_type
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08, ''3'' AS e09, (SELECT mix_medicine_type FROM RST_COND_INFO) AS medi_type
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM99990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM99990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
    group by all_cost.e01,all_cost.e05,all_cost.e08,all_cost.e09,all_cost.medi_type
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.item_cd, data_middle_all.amount, data_middle_all.unit, data_middle_all.count, data_middle_all.cond_info_jyun, data_middle_all.medi_type 
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.mix_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.class_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.item_cd = mst_medicine.in_hospital_cd_1
        LEFT JOIN do_medicine_mix ON data_middle_all.item_cd = do_medicine_mix.item_cd_m
)
, order_code_F AS (
  SELECT
    item_cd AS item_cd_f, medi_type AS medi_type_f, 
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN medi_type :: TEXT = ''2'' THEN TO_NUMBER( medicine_mix_cd :: TEXT, ''999999999999'' ) 
             WHEN medi_type :: TEXT = ''1'' THEN TO_NUMBER( medi_code_order :: TEXT, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = data_all.medicine_cd
    LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.item_cd
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc   
)
, order_code_S_1 AS (
 SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) IS NOT NULL 
        THEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) 
        ELSE (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine_mix.facility_cd = @facilityCd) END AS item_cd_s,
    TO_NUMBER( json_idx :: text, ''999999999999'' ) AS login_ord_s,
    0 AS login_ord_medicine_mix,
    TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type_s,
    (SELECT TO_NUMBER(timing_code_order :: text, ''999999999999'') FROM do_mst_timing WHERE TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'') = TO_NUMBER(timing_code :: text, ''999999999999'')) AS timing_cd_s,
    (SELECT TO_NUMBER(procedure_code_order :: text, ''999999999999'') FROM do_mst_procedure WHERE TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'') = TO_NUMBER(procedure_code :: text, ''999999999999'')) AS procedure_cd_s,
    TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval_s
 FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx) 
 WHERE medi ->> ''medicine_type'' :: text = ''1''   
UNION ALL
 SELECT 
    item_cd_m AS item_cd_s,
    login_ord_m AS login_ord_s,
    ord_mk AS login_ord_medicine_mix,
    medicine_type_m AS medicine_type_s,
    timing_cd_m AS timing_cd_s,
    procedure_cd_m AS procedure_cd_s,
    date_interval_m AS date_interval_s 
 FROM do_medicine_mix
)
, order_code_S_2 AS (
SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_f AS class_cd_s, medicine_type_s, medi_cd_f AS medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_1 LEFT JOIN order_code_F ON item_cd_s = item_cd_f 
                                    AND medicine_type_s :: TEXT = medi_type_f :: TEXT
)
, order_code_S_3_m AS (
SELECT * FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
            CASE WHEN class_cd_s IS NULL THEN 0 ELSE class_cd_s END AS class_cd_s
            , medicine_type_s, medi_cd_s,       
            CASE WHEN timing_cd_s IS NULL THEN 0 ELSE timing_cd_s END AS timing_cd_s,       
            CASE WHEN procedure_cd_s IS NULL THEN 0 ELSE procedure_cd_s END AS procedure_cd_s, 
            CASE WHEN date_interval_s IS NULL THEN 0 ELSE date_interval_s END AS date_interval_s
         FROM order_code_S_2) AS middle_data_s
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM order_code_S_3_m
    ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS mid_data
)
, order_code_S_dis AS (
SELECT 
    TRIM(item_cd_s) AS item_cd_s_dis,
    MIN(no2) AS ord_mk_s_dis
FROM
    order_code_S_3
WHERE TRIM(item_cd_s) IS NOT NULL
GROUP BY item_cd_s_dis
ORDER BY ord_mk_s_dis
)
, order_code_S AS (
SELECT  
   no2 AS ord_mk_s, item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_s, medicine_type_s, medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM
   order_code_S_dis LEFT JOIN order_code_S_3 ON item_cd_s_dis = item_cd_s AND ord_mk_s_dis = no2
)
, dataAndOrder AS (
SELECT DISTINCT ON (item_cd)* FROM (
SELECT
    detail_id, item_cd, amount, unit, count, 
        CASE WHEN item_cd IN (SELECT item_cd_k FROM rst_cond_info_K WHERE first_K = ''3''
 and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''1'',''2'') ) ) 
            THEN (SELECT order_K FROM rst_cond_info_K WHERE item_cd_k = item_cd) ELSE cond_info_jyun END AS cond_info_jyun,             
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS date_interval
FROM
    data_all ORDER BY cond_info_jyun) AS order_middle 
)
SELECT
    detail_id, item_cd, amount, unit, count, cond_info_jyun, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY cond_info_jyun,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
    login_ord_mix
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績)中止時）薬剤の投薬回数のSQL)', '2022-07-27 01:34:23.644',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-504, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
), 
ord_main_do as (
select * from ord_main_restore    where ord_no = @ordNo order by del_date desc limit 1
),
EQUIP_OUTPUT_TYPE_cd AS 
(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE''),
do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
)
, data_all AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost.e05, ''0'') ::Float AS amounttest,
  COALESCE(all_cost.e06, '''') AS unit,
  all_cost.syoumouhinOrder AS syoumouhinOrder
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
		  (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05, 
    meq.unit AS e06,
    11 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    8 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    9 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    10 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e06,
    12 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' )
  UNION ALL
    SELECT--医材情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    12 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''0''
    AND (equip ->> ''class_type'' NOT IN (''2'', ''3'') or equip ->>''class_type'' is null)
  UNION ALL
    SELECT--医材情報
    ''ダイアライザ'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.model_number AS e02,
    ''ダイアライザ'' AS e03,
    ''0'' AS e04,
		 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    25 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
  UNION ALL
  SELECT--医材情報
    ''加算・管理料'' AS detail_id,
    adt.in_hospital_cd_1 AS e01,
    adt.addition_name AS e02,
    ''加算・管理料'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    '''' AS e6,
    1 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
  UNION ALL
    SELECT--1次膜情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    6 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
   ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--2次膜情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    7 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
  ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--吸着カラム情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    5 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
   ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
),
data_all_weight AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost_weight.e01) AS item_cd,
  all_cost_weight.e02 AS name,
  all_cost_weight.e03 AS type_name,
  all_cost_weight.e04 AS class_name,
  COALESCE(all_cost_weight.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost_weight.e05, ''0'') ::text AS amounttest,
  COALESCE(all_cost_weight.e06, '''') AS unit,
  all_cost_weight.syoumouhinOrder AS syoumouhinOrder
FROM
  (
 select --目標体重出力
	''医材del'' AS detail_id,
	(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	(COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100)::text AS e05,
(CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')  and (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
	5 AS syoumouhinOrder
   from ord_main_do
	 where rst_cond_info-> ''3'' ->> ''value'' is not NULL
	 AND rst_cond_info-> ''3'' ->> ''value'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'')!= ''''
		 union All
 select --前体重出力
	''医材del'' AS detail_id,
(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	 (COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100)::text AS e05,
 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    5 AS syoumouhinOrder
   from ord_main_do
	 where rst_weight_info ->> ''weight_before'' is not NULL
	 AND rst_weight_info ->> ''weight_before'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'')!= ''''
	union All
  select --後体重出力
	''医材del'' AS detail_id,
  (SELECT (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
	 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_after'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    5 AS syoumouhinOrder
   from ord_main_do
	 where rst_weight_info ->> ''weight_after'' is not NULL
	 AND rst_weight_info ->> ''weight_after'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'')!= ''''
)all_cost_weight
WHERE
  all_cost_weight.e01 IS NOT NULL)
, do_data_group AS (
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, SUM(amounttest)::text AS amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_all
GROUP BY item_cd, detail_id :: text, name
union all
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_all_weight
GROUP BY item_cd, detail_id :: text, name,amounttest
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    LEFT(meq.in_hospital_cd_1, 8) AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_dialyzer AS dia 
                 WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main_do AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
)
, dia_data_order AS (
SELECT DISTINCT item_cd, CASE type_name WHEN ''ダイアライザ'' THEN 
    (SELECT dialyzer_cd FROM mst_dialyzer WHERE item_cd = in_hospital_cd_1 AND mst_dialyzer.facility_cd = @facilityCd) ELSE 0 END AS dia_cd
FROM data_all
)
, do_data AS (
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = item_cd) AS login_ord
		, CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) END AS cl_cd
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = item_cd) AS eq_cd
    , (SELECT dia_cd FROM dia_data_order WHERE dia_data_order.item_cd = do_data_group.item_cd) AS dia_cd
FROM  do_data_group
)
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder, login_ord, cl_cd, eq_cd, dia_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END, dia_cd
limit (SELECT
    (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd
     FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
     WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
				AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績)中止時）医材繰り返し部', '2022-07-27 01:34:23.636',CURRENT_TIMESTAMP, NULL);


INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-496, 'WITH total_info AS (
  SELECT
    COUNT(1) AS total_cnt
  FROM
    (
      SELECT--投与薬剤情報(通常)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      medi ->> ''name'' AS e02,
      medi ->> ''class_name'' AS e03,
      to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      medi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''1'' 
      AND COALESCE ( mmd.in_hospital_cd_2, ''ZERO'' ) <> ''ZERO'' 
      AND ord.ord_no = @ordNo 
    UNION
      SELECT--投与薬剤情報(調製)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
--       COALESCE (
--         (
--         CASE
--             mmxd ->> ''solvent'' 
--             WHEN ''1'' THEN
--               to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
--             ELSE
--               CASE WHEN mmx2.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
--               THEN ''0.00'' 
--               ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
--               END 
--           END 
--           ),
--           ''0.00'' 
--         ) AS e04,
        '''' AS e04,
        COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
        mp.in_hospital_cd_a1 AS e06,
        medi ->> ''procedure_name'' AS e07 
      FROM
        ord_main AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
--         mst_medicine_mix AS mmx2
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
      WHERE
        medi ->> ''effect_flg'' = ''1'' 
        AND medi ->> ''medicine_type'' = ''2'' 
        AND ord.ord_no = @ordNo 
    UNION
        SELECT--処置薬剤情報
        ''処置薬剤'' AS detail_id,
        mmd.in_hospital_cd_1 AS e01,
        tmedi ->> ''treat_medicine_name'' AS e02,
        mmdc.class_name AS e03,
        to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
        tmedi ->> ''unit'' AS e05,
        mp.in_hospital_cd_a1 AS e06,
        tmedi ->> ''procedure_name'' AS e07 
      FROM
        ord_main AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
      WHERE
        ord.ord_no = @ordNo 
      ) all_cost 
  WHERE
    all_cost.e01 IS NOT NULL
)
SELECT (total_cnt/15 + CASE WHEN (total_cnt%15) > 0 THEN 1 ELSE 0 END)  AS total_cnt FROM total_info', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤繰り返し部の総ページ', '2020-05-22 12:43:46',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-512, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	)	
	, total_info AS (
  SELECT
    COUNT(1) AS total_cnt
  FROM
    (
      SELECT--投与薬剤情報(通常)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      medi ->> ''name'' AS e02,
      medi ->> ''class_name'' AS e03,
      to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      medi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main_restore_info AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''1'' 
      AND COALESCE ( mmd.in_hospital_cd_2, ''ZERO'' ) <> ''ZERO'' 
      AND ord.ord_no = @ordNo 
    UNION
      SELECT--投与薬剤情報(調製)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
--       COALESCE (
--         (
--         CASE
--             mmxd ->> ''solvent'' 
--             WHEN ''1'' THEN
--               to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
--             ELSE
--               CASE WHEN mmx2.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
--               THEN ''0.00'' 
--               ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
--               END 
--           END 
--           ),
--           ''0.00'' 
--         ) AS e04,
        '''' AS e04,
        COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
        mp.in_hospital_cd_a1 AS e06,
        medi ->> ''procedure_name'' AS e07 
      FROM
        ord_main_restore_info AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
--         mst_medicine_mix AS mmx2
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
      WHERE
        medi ->> ''effect_flg'' = ''1'' 
        AND medi ->> ''medicine_type'' = ''2'' 
        AND ord.ord_no = @ordNo 
    UNION
        SELECT--処置薬剤情報
        ''処置薬剤'' AS detail_id,
        mmd.in_hospital_cd_1 AS e01,
        tmedi ->> ''treat_medicine_name'' AS e02,
        mmdc.class_name AS e03,
        to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
        tmedi ->> ''unit'' AS e05,
        mp.in_hospital_cd_a1 AS e06,
        tmedi ->> ''procedure_name'' AS e07 
      FROM
        ord_main_restore_info AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
      WHERE
        ord.ord_no = @ordNo 
      ) all_cost 
  WHERE
    all_cost.e01 IS NOT NULL
)
SELECT (total_cnt/15 + CASE WHEN (total_cnt%15) > 0 THEN 1 ELSE 0 END)  AS total_cnt FROM total_info', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ（削除）', '2022-08-22 12:05:22.245',CURRENT_TIMESTAMP, NULL);


INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, '

WITH 
ord_main_restore_info AS (
    (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo AND facility_cd = @facilityCd and rst_treatment_cd is not null )
		UNION
		(SELECT rst_start_date FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		AND (SELECT count(rst_treatment_cd) FROM ord_main WHERE ord_no = @ordNo AND facility_cd = @facilityCd) = ''0''
		ORDER BY del_date DESC LIMIT 1)
	),

A AS (
    SELECT COALESCE
               (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS setting_value
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''DIALYSISSEND''
      AND info ->> ''key2'' = ''DERECT_ACID_FLG''
)
SELECT A.setting_value,
             (
                 SELECT (save_2 ->> ''ord_no'')
                 FROM (
                          SELECT (save_1 :: json) save_1,
                                 (save_2 :: json) save_2,
                                 reg_date
                          FROM pat_coop_detail
                          WHERE pat_id = @patId
-- add 2023-01-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                            AND facility_cd = @facilityCd
                            AND coop_version = @coopVersion
-- add 2023-01-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                            AND is_del = ''0''
                      ) s
                 WHERE save_1 ->> ''pkg'' = ''GX''
                   AND reg_date < (SELECT rst_start_date FROM ord_main_restore_info)
                 ORDER BY reg_date DESC
                 LIMIT 1
             ) AS ord_no
      FROM A
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677',CURRENT_TIMESTAMP, NULL);
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
					) THEN
					( to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue1 :: INTEGER ))::text 
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
										) THEN
										( to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue2 :: INTEGER ))::text 
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
															) THEN
															( to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm000'' ) ) ELSE ( SUM ( K.sumResultValue3 :: INTEGER ))::text 
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
																			) THEN
																			( to_char( ( query4.oxygen_amount :: INTEGER ), ''fm000'' ) ) ELSE ( ( query4.oxygen_amount :: INTEGER )::text) 
																		END 
																		) AS oxygen_amount 
																FROM
	query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:酸素吸入量（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
	INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-109, 'with 
ord_maincopy_do as (
SELECT 
ord_no,
null as del_date,
pat_id,
fn_pat_id,
treat_date,
treat_week,
facility_cd,
facility_name,
ind_va_cd,
ind_treatment_cd,
ind_treatment_name,
ind_kur_cd,
ind_kur_name,
ind_treat_start_time,
ind_bed_cd,
ind_bed_name,
ind_schedule_user_info,
ind_cond_info,
ind_medi_info,
ind_equip_info,
ind_ind_comment_info,
ind_tare_info,
ind_off_water_info,
ind_device_set_info,
rst_fn_dialysis_no,
rst_relation_dialysis_no,
rst_edition,
rst_is_update_edition,
rst_input_class,
rst_dialysis_state,
rst_treatment_cd,
rst_treatment_name,
rst_kur_cd,
rst_kur_name,
rst_bed_cd,
rst_bed_name,
rst_machine_no,
rst_machine_name,
rst_cond_send_date,
rst_accept_date,
rst_start_date,
rst_end_date,
rst_return_home_date,
rst_in_out_class,
rst_dialysis_cnt,
rst_ward_cd,
rst_ward_name,
rst_course_cd,
rst_course_name,
rst_puncture_user_info,
rst_return_user_info,
rst_charge_user_info,
rst_blood_circulate_total,
rst_running_time,
rst_kt_v,
rec_set_date,
send_ctl_no,
blood_purifier_name,
pull_leave_amount,
rst_cond_info,
rst_medi_info,
rst_equip_info,
rst_ind_comment_info,
rst_tare_info,
rst_off_water_info,
rst_device_set_info,
rst_weight_info,
rst_vital_info,
rst_complaint_info,
rst_treatment_info,
rst_treat_staff_info,
rst_rounds_info,
is_del,
up_date ,
up_ind_user_id,
up_user_id,
reg_date,
treat_type,
rst_purification_cnt,
rst_dw,
weight_scale_no,
fn_plural,
is_confirm,
ind_dw,
addition_info,
rst_edition_date,
cur_edition_date,
bvms_path
from ord_main ord where ord.ord_no = @ordNo and ord.rst_treatment_cd is not null
union 
SELECT * FROM  ord_main_restore AS ord 
WHERE  ord.ord_no = @ordNo and 
(select count(1) from ord_main ord where ord.ord_no = @ordNo and ord.rst_treatment_cd is not null ) = ''0''
order by del_date desc limit 1
),

ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_maincopy_do ord
),
mst_user_authenticator as(		select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_maincopy_do )		
then ''Mon'' 
 when 2 =(select treat_week from ord_maincopy_do )		
then ''Tues'' 
 when 3 =(select treat_week from ord_maincopy_do )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_maincopy_do )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_maincopy_do )		
then ''Fri'' 
 when 6 =(select treat_week from ord_maincopy_do )		
then ''Satur'' 
 when 7 =(select treat_week from ord_maincopy_do )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_maincopy_do ord, mst_kur mst where ord.rst_kur_cd = mst.kur_cd 	
), 
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DOCTOR_TYPE''  
	) 
     select staff_cd,code from((SELECT 
    charge_staff ->> ''staff_cd'' AS staff_cd ,
    0  as code
    FROM
      pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
    WHERE
      pm.pat_id = @patId
  
  		AND charge_staff ->> ''is_main'' = ''1''
  		and ''1'' = (select * from ini_key)
  		order by charge_staff ->> ''is_main'' asc LIMIT 1
  		)
  	UNION
  	SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd ,
  		1 as code
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
  	facility_cd = @facilityCd
  
  	AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
  	AND info ->> ''key1'' = ''DIALYSISSEND'' 
  	AND info ->> ''key2'' = ''DOCTOR_DEF''
  	and
  	 ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
      pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
      WHERE
      pm.pat_id = @patId
  
  		AND charge_staff ->> ''is_main'' = ''1'')
  		AND ''1'' = (select * from ini_key)
  		UNION
      select staff_cd , 0 as code from ind_user_id
  		where  ''0'' = (select * from ini_key)
  		union

     select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR 
 		(select staff_cd from mst_user_authenticator)= ''''
 		OR  (select staff_cd from mst_user_authenticator) = ''0'') and
 	  ''2'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
 	  AND info ->> ''key1'' = ''DIALYSISSEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''''
 		and (select staff_cd from mst_user_authenticator) != ''0''  and
 	  ''2'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null
        
 		
	', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '(受信用)日機装)連携設定:医師コード', '2022-06-09 17:05:03',CURRENT_TIMESTAMP, NULL);



