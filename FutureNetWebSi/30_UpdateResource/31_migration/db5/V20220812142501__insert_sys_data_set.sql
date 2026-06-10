DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-510,-511,-512,-513,-514);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-510, 'WITH A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_in_hospital_cd 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DEPARTMENT_DEF'' 
	) 
SELECT
	(
CASE
	WHEN ( SELECT rst_course_cd FROM ord_main_restore WHERE ord_no = @ordNo LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore WHERE ord_no = @ordNo))
			END
	ELSE 
		A.default_in_hospital_cd
END 
	) AS in_hospital_cd_1 
FROM
A', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：診療科コード取得（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-511, 'SELECT
	coop_ord_no AS coop_ord_no 
FROM
	sys_coop_journal 
WHERE
  facility_cd = @facilityCd
	AND ord_no = @ordNo 
	AND coop_cd = ''rst_dial'' 
	AND coop_ord_no IS NOT NULL
LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析番号取得（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-512, 'WITH total_info AS (
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
      ord_main_restore AS ord
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
      COALESCE (
        (
        CASE
            mmxd ->> ''solvent'' 
            WHEN ''1'' THEN
              to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            ELSE
              CASE WHEN mmx2.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
              THEN ''0.00'' 
              ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
              END 
          END 
          ),
          ''0.00'' 
        ) AS e04,
        COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
        mp.in_hospital_cd_a1 AS e06,
        medi ->> ''procedure_name'' AS e07 
      FROM
        ord_main_restore AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' ),
        mst_medicine_mix AS mmx2
        CROSS JOIN LATERAL json_array_elements ( mmx2.mix_info :: json ) mmxd
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
        ord_main_restore AS ord
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
SELECT (total_cnt/15 + CASE WHEN (total_cnt%15) > 0 THEN 1 ELSE 0 END)  AS total_cnt FROM total_info', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-513, 'with CONV_INOUT_TO_KARTE as (
(SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd ,
	  info ->> ''key2'' AS CONV_INOUT
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''CONV_INOUT_TO_KARTE'' 
      AND info ->> ''key2'' = ''0'' limit 1)
UNION ALL
(SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd ,
	  info ->> ''key2'' AS CONV_INOUT
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''CONV_INOUT_TO_KARTE'' 
      AND info ->> ''key2'' = ''1'' limit 1)
)

SELECT
  CONV_INOUT_TO_KARTE.staff_cd AS in_out_class
FROM
  ord_main_restore LEFT JOIN CONV_INOUT_TO_KARTE ON
  ord_main_restore.rst_in_out_class || '''' = CONV_INOUT_TO_KARTE.CONV_INOUT || ''''
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析条件-治療コード（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-514, 'with IN_HOSPITAL as (
SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''DIALYSISSEND'' 
      AND info ->> ''key2'' = ''TREAT_INHOSP'' limit 1
)
SELECT
CASE WHEN IN_HOSPITAL.staff_cd = ''1'' THEN 
  COALESCE(NULLIF(mtt.in_hospital_cd_a1, ''''), ''-'')
	ELSE CASE WHEN IN_HOSPITAL.staff_cd = ''2'' THEN
  COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), ''-'')
	ELSE ''-''
	END
END AS treatment_cd --治療項目コード１
  FROM
    ord_main_restore AS ord
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd,
		IN_HOSPITAL
WHERE
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：入外区分取得（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
