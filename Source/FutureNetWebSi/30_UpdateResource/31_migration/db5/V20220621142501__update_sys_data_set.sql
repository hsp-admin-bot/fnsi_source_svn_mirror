DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-497, -498);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-497, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
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
, data_middle_all AS (
SELECT
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
  UNION ALL
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
         meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
        and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo
  UNION ALL
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
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
        and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
    UNION ALL
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
  UNION ALL
     SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo
  UNION ALL
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
    --ORDER BY all_cost.e01
    --limit 135
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.item_cd, data_middle_all.amount, data_middle_all.unit, data_middle_all.count, mst_medicine.medicine_cd, mst_medicine.class_cd 
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.item_cd = mst_medicine.in_hospital_cd_1
)
, order_code_F AS (
SELECT
	  item_cd AS item_cd_f, 
    CASE WHEN ''0'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_code :: text, ''999999999999'' ) ELSE NULL END AS login_ord,
    CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_cd,
    CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) ELSE NULL END AS medi_cd
  FROM
    data_all
		LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
		LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
)
, order_code_S AS (
SELECT
	  DISTINCT item_cd AS item_cd_s, 
    CASE WHEN ''2'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''medicine_type'', ''999999999999'' ) ELSE NULL END AS medicine_type,
    CASE WHEN ''4'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''timing_cd'', ''999999999999'' ) ELSE NULL END AS timing_cd,
    CASE WHEN ''5'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) ELSE NULL END AS procedure_cd,
    CASE WHEN ''6'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''date_interval'', ''999999999999'' ) ELSE NULL END AS date_interval
  FROM
    data_all
		LEFT OUTER JOIN ord_main AS ord
             CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
						 ON TO_NUMBER( medi ->> ''cd'', ''999999999999'') = data_all.medicine_cd
  WHERE ord.ord_no = @ordNo
)
, dataAndOrder AS (
SELECT
    detail_id, item_cd, amount, unit, count, 
		(SELECT login_ord FROM order_code_F WHERE order_code_F.item_cd_f = item_cd) AS login_ord, 
		(SELECT class_cd FROM order_code_F WHERE order_code_F.item_cd_f = item_cd) AS class_cd, 
		(SELECT medicine_type FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
		(SELECT medi_cd FROM order_code_F WHERE order_code_F.item_cd_f = item_cd) AS medi_cd,
		(SELECT timing_cd FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS timing_cd, 
		(SELECT procedure_cd FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS procedure_cd, 
		(SELECT date_interval FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS date_interval
FROM
    data_all
)
SELECT
    detail_id, item_cd, amount, unit, count, login_ord, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY 
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤の投薬回数のSQL)', '2022-05-09 05:52:21.853', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-498, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmeq_cd AS (
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
  ''医材'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') AS amount,
  ((COALESCE(all_cost.e05, ''0'')::FLOAT)*100)::INTEGER AS amounttest,
  COALESCE(all_cost.e06, '''') AS unit
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e06
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' )
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e6
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''0''
    AND (equip ->> ''class_type'' NOT IN (''2'', ''3'') or equip ->>''class_type'' is null)
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材情報
    ''ダイアライザ'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.model_number AS e02,
    ''ダイアライザ'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e6
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    and ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
   facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION ALL
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd =@facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''CONSUMABLES_CODE''
    AND info ->> ''key2'' = ''POTION_STATUS'')
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
)
, do_data_group AS (
SELECT 
    (detail_id:: text) as detail_id, left(item_cd, 8) as item_cd, name, type_name, class_name, sum(amounttest) as amounttest, unit
FROM  
    data_all
GROUP BY item_cd, detail_id :: text, name, type_name, class_name, unit
)
, order_code_up AS (
SELECT 
    LEFT(meq.in_hospital_cd_1, 8) AS e01
		, CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code :: text, ''999999999999'') ELSE NULL END AS login_ord
		, CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd
	  , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
		LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE
    meq.in_hospital_cd_1 IS NOT NULL
)
, do_data AS (
SELECT detail_id, item_cd, name, type_name, class_name, amounttest, unit
       , (SELECT login_ord FROM order_code_up WHERE e01 = item_cd) AS login_ord
       , (SELECT cl_cd FROM order_code_up WHERE e01 = item_cd) AS cl_cd
	     , (SELECT eq_cd FROM order_code_up WHERE e01 = item_cd) AS eq_cd
FROM  do_data_group
)
SELECT detail_id, item_cd, name, type_name, class_name, amounttest, unit, login_ord, cl_cd, eq_cd
FROM do_data
ORDER BY 
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
limit (SELECT
    (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd
     FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
     WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);
