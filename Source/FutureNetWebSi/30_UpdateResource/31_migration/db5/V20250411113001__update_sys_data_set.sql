DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-108,-503,-504,-505,-506,-507,-508,-509,-510,-512,-513,-514);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-108, 'WITH 
ord_main_restore_info AS (
    (SELECT rst_start_date, rst_edition_date as up_date_switch FROM ord_main WHERE ord_no = @ordNo)
	UNION
		(SELECT rst_start_date, del_date as up_date_switch
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
		WHERE
        ord_i.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord_i.ord_no = journal.ord_no
        AND journal.reg_date >= ord_i.del_date
    ORDER BY del_date DESC
    LIMIT 1)
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
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
                 WHERE save_1 ->> ''pkg'' = @key0
                   AND reg_date < (SELECT rst_start_date FROM ord_main_restore_info)
                 ORDER BY reg_date DESC
                 LIMIT 1
             ) AS ord_no
      FROM A
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-503, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
    to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                                             mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                                             mmd.medicine_name AS e02,
                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--          meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--      meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
      to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
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
--     meq.equipment_name AS e02,
ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
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
limit 135
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, '日機装)実績)中止時）薬剤の投薬回数のSQL)', '2022-07-27 01:34:23.644', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
), 
ord_main_do as (
  (SELECT
    ord.del_date as up_date_switch,
    ord.rst_cond_info AS rst_cond_info,
    ord.rst_equip_info AS rst_equip_info,
    ord.addition_info AS addition_info,
    ord.rst_weight_info AS rst_weight_info
  FROM ord_main_restore as ord
  JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
  WHERE ord.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord.ord_no = journal.ord_no
    AND journal.reg_date >= ord.del_date
  ORDER BY ord.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord.rst_edition_date as up_date_switch,
    ord.rst_cond_info AS rst_cond_info,
    ord.rst_equip_info AS rst_equip_info,
    ord.addition_info AS addition_info,
    ord.rst_weight_info AS rst_weight_info
  FROM ord_main AS ord
  WHERE ord.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
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
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, '日機装)実績)中止時）医材繰り返し部', '2022-07-27 01:34:23.636', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-505, 'WITH ord_main_restore_info AS (
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.ord_no AS ord_no,
    ord_i.treat_date AS treat_date,
    ord_i.rst_kur_cd AS rst_kur_cd,
    ord_i.rst_kur_name AS rst_kur_name,
    ord_i.rst_dialysis_cnt AS rst_dialysis_cnt,
    ord_i.rst_bed_cd AS rst_bed_cd,
    ord_i.rst_machine_no AS rst_machine_no,
    ord_i.rst_machine_name AS rst_machine_name,
    ord_i.rst_course_cd AS rst_course_cd,
    ord_i.rst_course_name AS rst_course_name,
    ord_i.rst_ward_cd AS rst_ward_cd,
    ord_i.rst_ward_name AS rst_ward_name,
    ord_i.rst_treatment_cd AS rst_treatment_cd,
    ord_i.rst_treatment_name AS rst_treatment_name,
    ord_i.rst_dw AS rst_dw,
    ord_i.rst_accept_date AS rst_accept_date,
    ord_i.rst_start_date AS rst_start_date,
    ord_i.rst_end_date AS rst_end_date,
    ord_i.rst_return_home_date AS rst_return_home_date,
    ord_i.rst_in_out_class AS rst_in_out_class,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_puncture_user_info AS rst_puncture_user_info,
    ord_i.rst_return_user_info AS rst_return_user_info,
    ord_i.rst_charge_user_info AS rst_charge_user_info,
    ord_i.rst_running_time AS rst_running_time,
    ord_i.pull_leave_amount AS pull_leave_amount,
    ord_i.rst_weight_info AS rst_weight_info,
    ord_i.up_date AS up_date,
    ord_i.ind_schedule_user_info AS ind_schedule_user_info
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.ord_no AS ord_no,
    ord_i.treat_date AS treat_date,
    ord_i.rst_kur_cd AS rst_kur_cd,
    ord_i.rst_kur_name AS rst_kur_name,
    ord_i.rst_dialysis_cnt AS rst_dialysis_cnt,
    ord_i.rst_bed_cd AS rst_bed_cd,
    ord_i.rst_machine_no AS rst_machine_no,
    ord_i.rst_machine_name AS rst_machine_name,
    ord_i.rst_course_cd AS rst_course_cd,
    ord_i.rst_course_name AS rst_course_name,
    ord_i.rst_ward_cd AS rst_ward_cd,
    ord_i.rst_ward_name AS rst_ward_name,
    ord_i.rst_treatment_cd AS rst_treatment_cd,
    ord_i.rst_treatment_name AS rst_treatment_name,
    ord_i.rst_dw AS rst_dw,
    ord_i.rst_accept_date AS rst_accept_date,
    ord_i.rst_start_date AS rst_start_date,
    ord_i.rst_end_date AS rst_end_date,
    ord_i.rst_return_home_date AS rst_return_home_date,
    ord_i.rst_in_out_class AS rst_in_out_class,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_puncture_user_info AS rst_puncture_user_info,
    ord_i.rst_return_user_info AS rst_return_user_info,
    ord_i.rst_charge_user_info AS rst_charge_user_info,
    ord_i.rst_running_time AS rst_running_time,
    ord_i.pull_leave_amount AS pull_leave_amount,
    ord_i.rst_weight_info AS rst_weight_info,
    ord_i.up_date AS up_date,
    ord_i.ind_schedule_user_info AS ind_schedule_user_info
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
,KOU_COAG_RESOLVE_MODE_cd AS(
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
SELECT
  ord.ord_no AS ord_no,
  ord.treat_date AS treat_date,--透析日
  COALESCE(mkr.in_hospital_cd_1, '''') AS kur_cd1,--クール
  COALESCE(ord.rst_kur_name, '''') AS kur_name,--クール名
  COALESCE(ord.rst_dialysis_cnt, 0) AS dialysis_cnt,--透析回数
  COALESCE(ord.rst_machine_no, 0) AS machine_no,--装置番号
  COALESCE(ord.rst_machine_name, '''') AS machine_name,--装置名
  COALESCE(ord.rst_course_name, '''') AS course_name,--診療科名
  COALESCE(mcs.in_hospital_cd_1, '''') AS course_cd,--診療科コード１
  COALESCE(ord.rst_ward_name, '''') AS ward_name,--病棟名
  COALESCE(mwd.in_hospital_cd_1, '''') AS ward_cd,--病棟コード１
  COALESCE(ord.rst_treatment_name, '''') AS treatment_name,--治療項目
  COALESCE(mtt.in_hospital_cd_a1, '''') AS treatment_cd,--治療項目コード１
  (CASE  mtt.device_mode 
    WHEN ''0'' THEN
      ''HD'' 
    WHEN ''1'' THEN
      ''ECUM'' 
    WHEN ''2'' THEN
      ''HDF'' 
    WHEN ''3'' THEN
      ''HF'' 
    WHEN ''4'' THEN
      ''HD+補液'' 
    WHEN ''5'' THEN
      ''ECUM+補液'' 
    WHEN ''6'' THEN
      ''AFBF'' 
    WHEN ''7'' THEN
      ''OHDF'' 
    WHEN ''8'' THEN
      ''OHF'' 
    WHEN ''9'' THEN
      ''特殊浄化'' 
    WHEN ''10'' THEN
      ''i-HDF'' ELSE''不明'' 
    END) AS device_mode,--装置モード
  COALESCE(ord.rst_dw, 0) AS dw,--dw
--mbd.bed_cd as bed_cd,--ベッドコード
  COALESCE(mbd.in_hospital_cd_1, '''') AS bed_cd1,
  COALESCE(mbd.bed_name, '''') AS bed_name,--ベッド名
  COALESCE(( CASE mbd.shunt_position WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS shunt_position,--シャント位置名称
  COALESCE(( CASE mbd.is_infection WHEN ''0'' THEN ''感染症無'' WHEN ''1'' THEN ''感染症対応'' ELSE''不明'' END ), '''') AS is_infection,--感染症フラグ
  COALESCE(( CASE mbd.emergency_class WHEN ''0'' THEN ''通常ベッド'' WHEN ''1'' THEN ''救急ベッド'' ELSE''不明'' END ), '''') AS emergency_class,--救急対応
  ord.rst_accept_date AS accept_date,--受付日時
  ord.rst_start_date AS start_date,--透析開始日時
  COALESCE(TO_CHAR( ord.rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  ord.rst_end_date AS end_date,--透析終了日時
  COALESCE(TO_CHAR( ord.rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  ord.rst_return_home_date AS return_home_date,--帰宅時刻
  ord.rst_in_out_class AS in_out_class,--入外コード
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,--入外区分
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,--入外区分（F)
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s,--入外区分（S)
  COALESCE(RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ), 60 ), 2 ), '''') AS treatment_time,
  COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''') AS treatment_time_m,
  COALESCE(ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''') AS va,--シャント
  COALESCE(mva.in_hospital_cd_1, '''') AS va_cd1,--シャントコード１
  COALESCE(( CASE mva.va_direct WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS va_direct,--シャント方向
  COALESCE(ord.rst_cond_info -> ''3'' ->> ''value'', '''') AS target_weight,
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''3'' ->> ''value'' = ''-1'' THEN ''DWと同じ'' ELSE''目標体重指定'' END ), '''') AS target_mode,--目標体重指定設定
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_cond_info -> ''4'' ->> ''value'', ''FM99.99'' ), ''FM90.99'' ), '''') AS water_removal_amount_limit,
  COALESCE(ord.rst_cond_info -> ''5'' ->> ''value_name_1'', '''') AS dialyzer,
  COALESCE(TRIM ( mdr.in_hospital_cd_1 ), '''') AS dialyzer_cd1,--ダイアライザコード１
  COALESCE(mdr.maker, '''') AS dialyzer_maker,--ダイアライザメーカ
  COALESCE(mdr.function_class, '''') AS function_class,--ダイアライザ機能分類
  COALESCE(mdr.area, 0) AS dialyzer_area,--ダイアライザ面積
  COALESCE(mdr.ufr, 0) AS dialyzer_ufr,--ダイアライザUFR
  COALESCE(mdr.koa, 0) AS dialyzer_KoA,--ダイアライザKoA
  COALESCE(mdr.material, '''') AS dialyzer_material,--ダイアライザ材質
  COALESCE(( CASE mdr.membrane_wash WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE''不明'' END ), '''') AS membrane_wash,--膜洗浄（中空糸）
  COALESCE(( CASE mdr.wetdry WHEN ''0'' THEN ''不明'' WHEN ''1'' THEN ''WET'' WHEN ''2'' THEN ''DRY'' ELSE''不明'' END ), '''') AS dialyzer_wetdry,--WET/DRY
  COALESCE(mdr.substituent_wash_amt, 0) AS substituent_wash_amt,--置換洗浄量（透析液）
  COALESCE(mdr.gas_purge_time, 0) AS gas_purge_time,--ガスパージ時間
  COALESCE(mdr.urea_clearance, 0) AS urea_clearance,--尿素クリアランス
  COALESCE(mdr.alqd_flood_vol, 0) AS alqd_flood_vol,--透析液流量
  COALESCE(mdr.bloodamt, 0) AS dialyzer_bloodamt,--血流量
  COALESCE(mdr.sterilization, '''') AS sterilization,--滅菌
  COALESCE(ord.rst_cond_info -> ''6'' ->> ''value_name_1'', '''') AS adsorption_column,
  COALESCE(meqad.in_hospital_cd_1, '''') AS ad_cd1,--吸着器コード１
  COALESCE(ord.rst_cond_info -> ''7'' ->> ''value_name_1'', '''') AS primary_film,
  COALESCE(meqpr.in_hospital_cd_1, '''') AS pr_cd1,--1次膜コード１
  COALESCE(ord.rst_cond_info -> ''8'' ->> ''value_name_1'', '''') AS secondary_film,
  COALESCE(meqse.in_hospital_cd_1, '''') AS se_cd1,--2次膜コード１
  COALESCE(ord.rst_cond_info -> ''9'' ->> ''value_name_1'', '''') AS puncture_needle_a,
  COALESCE(meqa.in_hospital_cd_1, '''') AS a_cd1,--穿刺針Aコード１
  COALESCE(ord.rst_cond_info -> ''10'' ->> ''value_name_1'', '''') AS puncture_needle_v,
  COALESCE(meqv.in_hospital_cd_1, '''') AS v_cd1,--穿刺針Vコード１
  COALESCE(ord.rst_cond_info -> ''11'' ->> ''value_name_1'', '''') AS puncture_needle_sn,
  COALESCE(meqsn.in_hospital_cd_1, '''') AS sn_cd1,--穿刺針SNコード１
  COALESCE(( CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''') AS single_needle,
  COALESCE(ord.rst_cond_info -> ''13'' ->> ''value'', '''') AS blood_circuit,
  COALESCE(meqbc.in_hospital_cd_1, '''') AS bc_cd1,--血液回路コード１
  COALESCE(ord.rst_cond_info -> ''14'' ->> ''value'', '''') AS blood_flow,--血流量
  COALESCE(ord.rst_cond_info -> ''15'' ->> ''value_name_1'', '''') AS dialysate,
  COALESCE(( CASE ord.rst_cond_info -> ''15'' ->> ''medicine_type'' WHEN ''1'' THEN med15.in_hospital_cd_1 WHEN ''2'' THEN mmmx.in_hospital_cd_1 END ), '''') AS ds_cd,
  COALESCE(ord.rst_cond_info -> ''16'' ->> ''value'', '''') AS dialysate_flow_rate,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', '''') AS dialysate_amount,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''unit'', '''') AS dialysate_amount_unit,
  COALESCE(ord.rst_cond_info -> ''18'' ->> ''value'', '''') AS dialysate_temperature,
  COALESCE(ord.rst_cond_info -> ''19'' ->> ''value_name_1'', '''') AS fluid_replacement,
  COALESCE(( CASE ord.rst_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ), '''') AS ds_cd2,--補液コード１
  COALESCE(ord.rst_cond_info -> ''20'' ->> ''value'', '''') AS fluid_replacement_amount,
  COALESCE(( CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''') AS fluid_replacement_timing,
  COALESCE(ord.rst_cond_info -> ''21'' ->> ''value'', '''') AS fluid_replacement_timing_ssi,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', '''') AS fluid_replacement_use_count,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''unit'', '''') AS fluid_replacement_use_count_unit,
  COALESCE(ord.rst_cond_info -> ''23'' ->> ''value'', '''') AS fluid_replacement_temperature,
  COALESCE(ord.rst_cond_info -> ''24'' ->> ''value'', '''') AS fluid_replacement_speed,
  COALESCE(ord.rst_cond_info -> ''25'' ->> ''value_name_1'', '''') AS anti_coagulant,
--   COALESCE(( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--抗凝固剤コード１
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''25'' ->> ''medicine_type'' =''1'' THEN med25.in_hospital_cd_1 WHEN
	ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
	and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''0'',''1''))
	THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--抗凝固剤コード１
  COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', '''') AS anti_coagulant_one_shot_amount,
--   COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') AS anti_coagulant_one_shot_amount_unit,
 case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'')
or ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
then 
 COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') else '''' end AS anti_coagulant_one_shot_amount_unit,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''value'', '''') AS anti_coagulant_sustained_speed,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''unit'', '''') AS anti_coagulant_sustained_speed_unit,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', '''') AS anti_coagulant_sustained_amount,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''unit'', '''') AS anti_coagulant_sustained_amount_unit,
  COALESCE(TO_NUMBER( ord.rst_cond_info -> ''26'' ->> ''value'', ''FM999999999999'' ) + TO_NUMBER( ord.rst_cond_info -> ''28'' ->> ''value'', ''FM999999999999'' ), 0) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE(( CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS ip,
  COALESCE(( CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''') AS ip_start,
  COALESCE(ord.rst_cond_info -> ''30'' ->> ''value'', '''') AS ip_start_ssi,
  COALESCE(ord.rst_cond_info -> ''31'' ->> ''value'', '''') AS ip_one_short_amount,
  COALESCE(ord.rst_cond_info -> ''32'' ->> ''value'', '''') AS ip_speed,
  COALESCE(ord.rst_cond_info -> ''33'' ->> ''value'', '''') AS ip_speed_max,
  COALESCE(( CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS auto_one_shot,
  COALESCE(ord.rst_cond_info -> ''34'' ->> ''value'', '''') AS auto_one_shot_ssi,
  COALESCE(( CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_auto_off,
  COALESCE(ord.rst_cond_info -> ''35'' ->> ''value'', '''') AS ip_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''') AS ip_auto_off_time,
  COALESCE(( CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_monitor_auto_off,
  COALESCE(ord.rst_cond_info -> ''37'' ->> ''value'', '''') AS ip_monitor_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''') AS ip_monitor_auto_off_time,
  ord.rst_puncture_user_info -> ''date'' AS puncture_date,--穿刺時刻
  ord.rst_puncture_user_info -> ''user_id_1'' AS puncture1_id,--穿刺者１ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_1'', ord.rst_puncture_user_info ->> ''user_first_name_1'' ), '''') AS puncture1_name,--穿刺者1
  ord.rst_puncture_user_info -> ''date_1''AS puncture1_date,--穿刺時刻1
  ord.rst_puncture_user_info -> ''user_id_2'' AS puncture2_id,--穿刺者２ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_2'', ord.rst_puncture_user_info ->> ''user_first_name_2'' ), '''') AS puncture2_name,--穿刺者2
  ord.rst_puncture_user_info -> ''date_2'' AS puncture2_date,--穿刺時刻2
  ord.rst_return_user_info -> ''date'' AS return_date,--回収時刻
  ord.rst_return_user_info -> ''user_id_1'' AS return1_id,--回収者１ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_1'', ord.rst_return_user_info ->> ''user_first_name_1'' ), '''') AS return1_name,--回収者1
  ord.rst_return_user_info -> ''date_1'' AS return1_date,--回収時刻1
  ord.rst_return_user_info -> ''user_id_2'' AS return2_id,--回収者２ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_2'', ord.rst_return_user_info ->> ''user_first_name_2'' ), '''') AS return2_name,--回収者2
  ord.rst_return_user_info -> ''date_2'' AS return2_date,--回収時刻2
  ord.rst_charge_user_info -> ''user_id_1'' AS charge1_id,--担当者１ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_1'', ord.rst_charge_user_info ->> ''user_first_name_1'' ), '''') AS charge1_name,--担当者1
  ord.rst_charge_user_info -> ''date_1'' AS charge1_date,--担当時刻1
  ord.rst_charge_user_info -> ''user_id_2'' AS charge2_id,--担当者２ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_2'', ord.rst_charge_user_info ->> ''user_first_name_2'' ), '''') AS charge2_name,--担当者2
  ord.rst_charge_user_info -> ''date_2'' AS charge2_date,--担当時刻2
  ord.rst_running_time AS running_time,--透析運転時間
  TRIM((to_char((to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),1,2),''99'') * 60 + to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),3,2),''99'')),''999999999''))) AS running_time_cal,--透析運転時間_計算
  COALESCE(ord.pull_leave_amount, 0) AS pull_leave_amount,--引き残し量
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_before,
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_after,
	CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDDHH24MISS'' ), '''') AS up_date14,
  COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS ind_user_id,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDD'' ), '''') AS up_date8,
  COALESCE(TO_CHAR( ord.up_date, ''HH24MISS'' ), '''') AS up_date6 
  FROM
    ord_main_restore_info AS ord
    LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
    LEFT OUTER JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NKK)  実績）透析条件（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-506, 'WITH ord_main_restore_info AS (
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.rst_start_date AS rst_start_date,
    ord_i.rst_end_date AS rst_end_date,
    ord_i.rst_running_time AS rst_running_time,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.treat_date AS treat_date,
    ord_i.ind_treat_start_time AS ind_treat_start_time,
    ord_i.ord_no AS ord_no
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.rst_start_date AS rst_start_date,
    ord_i.rst_end_date AS rst_end_date,
    ord_i.rst_running_time AS rst_running_time,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.treat_date AS treat_date,
    ord_i.ind_treat_start_time AS ind_treat_start_time,
    ord_i.ord_no AS ord_no
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
	--(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER )<=999 then (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER ) 
	else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main_restore_info as ord
where
  ord.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NKK)  実績）透析開始終了日時変換（削除）', '2022-08-08 01:01:09.031', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-507, 'WITH 
ord_main_restore_info AS (
		(SELECT
			ord_i.del_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_cond_info AS rst_cond_info
		FROM ord_main_restore as ord_i
		JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
		WHERE ord_i.ord_no = @ordNo
			AND journal.ctl_no = @ctlNo
			AND ord_i.ord_no = journal.ord_no
			AND journal.reg_date >= ord_i.del_date
		ORDER BY ord_i.del_date DESC LIMIT 1)
	UNION
		(SELECT
			ord_i.rst_edition_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_cond_info AS rst_cond_info
		FROM ord_main AS ord_i
		WHERE ord_i.ord_no = @ordNo)
	ORDER BY
		up_date_switch DESC NULLS LAST
	LIMIT 1
	),
	A AS ( 
	SELECT (to_number(rst_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(rst_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount
	FROM ord_main_restore_info 
	WHERE ord_no = @ordNo
	),
 B AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
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
	),
	KOU_COAG_RESOLVE_MODE_cd AS(
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
SELECT B.default_setting,
case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'') 
or (	SELECT rst_cond_info -> ''25'' ->> ''medicine_type'' FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1)=''1''
then
(CASE A.anti_coagulant_amount::FLOAT >= 1
	WHEN true THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	ELSE
		(
		CASE B.default_setting
	WHEN ''0'' THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	WHEN ''1'' THEN
		LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
	)
END
) else '''' END AS calculate_one_shot_amount
FROM A,B', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)  透析実績：抗凝固剤総量（単体薬剤）（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-508, 'WITH ord_main_restore_info AS (
		(SELECT
			ord_i.del_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_cond_info AS rst_cond_info
		FROM ord_main_restore as ord_i
		JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
		WHERE ord_i.ord_no = @ordNo
			AND journal.ctl_no = @ctlNo
			AND ord_i.ord_no = journal.ord_no
			AND journal.reg_date >= ord_i.del_date
		ORDER BY ord_i.del_date DESC LIMIT 1)
	UNION
		(SELECT
			ord_i.rst_edition_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_cond_info AS rst_cond_info
		FROM ord_main AS ord_i
		WHERE ord_i.ord_no = @ordNo)
	ORDER BY
		up_date_switch DESC NULLS LAST
	LIMIT 1
),
dialysateSql AS (
SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' )::int as dialysateTransCd
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
	from ord_main_restore_info ord,dialysateSql
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)日機装)rst_dial連携:透析液使用量（単体薬剤）（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-509, 'WITH 
ord_main_restore_info AS (
		(SELECT
			ord_i.del_date as up_date_switch,
			ord_i.rst_treatment_info AS rst_treatment_info,
			ord_i.rst_medi_info AS rst_medi_info
		FROM ord_main_restore as ord_i
		JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
		WHERE ord_i.ord_no = @ordNo
			AND journal.ctl_no = @ctlNo
			AND ord_i.ord_no = journal.ord_no
			AND journal.reg_date >= ord_i.del_date
		ORDER BY ord_i.del_date DESC LIMIT 1)
	UNION
		(SELECT
			ord_i.rst_edition_date as up_date_switch,
			ord_i.rst_treatment_info AS rst_treatment_info,
			ord_i.rst_medi_info AS rst_medi_info
		FROM ord_main AS ord_i
		WHERE ord_i.ord_no = @ordNo)
	ORDER BY
		up_date_switch DESC NULLS LAST
	LIMIT 1
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
	query4', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)日機装)rst_dial連携:酸素吸入量（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-510, 'WITH ord_main_restore_info AS (
		(SELECT
			ord_i.del_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_course_cd AS rst_course_cd
		FROM ord_main_restore as ord_i
		JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
		WHERE ord_i.ord_no = @ordNo
			AND journal.ctl_no = @ctlNo
			AND ord_i.ord_no = journal.ord_no
			AND journal.reg_date >= ord_i.del_date
		ORDER BY ord_i.del_date DESC LIMIT 1)
	UNION
		(SELECT
			ord_i.rst_edition_date as up_date_switch,
			ord_i.ord_no AS ord_no,
			ord_i.rst_course_cd AS rst_course_cd
		FROM ord_main AS ord_i
		WHERE ord_i.ord_no = @ordNo)
	ORDER BY
		up_date_switch DESC NULLS LAST
	LIMIT 1
	)
	, A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_in_hospital_cd
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
	AND info ->> ''key2'' = ''DEPARTMENT_DEF''
	)
SELECT
	(
CASE
	WHEN ( SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo))
			END
	ELSE
		A.default_in_hospital_cd
END
	) AS in_hospital_cd_1
FROM
A', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)  透析実績：診療科コード取得（削除）', '2022-09-05 08:14:41.911', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-512, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
    to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                                             mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                                             mmd.medicine_name AS e02,
                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--          meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--      meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
      to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
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
--     meq.equipment_name AS e02,
ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
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
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
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
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
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
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
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
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
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
),
order_all as (
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
limit 135)
SELECT ((select count(1) from order_all)/15 + CASE WHEN ((select count(1) from order_all)%15) > 0 THEN 1 ELSE 0 END)  AS total_cnt 
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)  透析実績：ヘッダ（削除）', '2022-08-22 12:05:22.245', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-513, 'WITH ord_main_restore_info AS (
		(SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_in_out_class AS rst_in_out_class
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord_i.ord_no = journal.ord_no
      AND journal.reg_date >= ord_i.del_date
    ORDER BY ord_i.del_date DESC LIMIT 1)
  UNION
    (SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_in_out_class AS rst_in_out_class
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo)
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
	)	
	, CONV_INOUT_TO_KARTE as (
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''CONV_INOUT_TO_KARTE'' 
      AND info ->> ''key2'' = ''1'' limit 1)
)

SELECT
  CONV_INOUT_TO_KARTE.staff_cd AS in_out_class
FROM
  ord_main_restore_info LEFT JOIN CONV_INOUT_TO_KARTE ON
  ord_main_restore_info.rst_in_out_class || '''' = CONV_INOUT_TO_KARTE.CONV_INOUT || ''''
WHERE
  ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)  透析実績：透析条件-治療コード（削除）', '2022-08-22 12:05:22.245', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-514, 'WITH ord_main_restore_info AS (
		(SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_treatment_cd AS rst_treatment_cd
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord_i.ord_no = journal.ord_no
      AND journal.reg_date >= ord_i.del_date
    ORDER BY ord_i.del_date DESC LIMIT 1)
  UNION
    (SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_treatment_cd AS rst_treatment_cd
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo)
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
	)	
	, IN_HOSPITAL as (
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
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
    ord_main_restore_info AS ord
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd,
		IN_HOSPITAL
WHERE
  ord.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NKK)  透析実績：入外区分取得（削除）', '2022-08-22 12:05:22.245', CURRENT_TIMESTAMP, NULL);
