INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-497, 'SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  (sum(all_cost.e04::float)*100)::INTEGER AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
	(select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
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
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo  
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
      ord_main AS ord
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
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo ) as all_cost1 where all_cost1.e01 = all_cost.e01) count
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
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo 
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
      ord_main AS ord
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
	group by all_cost.e01,all_cost.e05
	ORDER BY all_cost.e01', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤繰り返し部(※このSQLを修正した場合、「-496」を修正してください。)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
