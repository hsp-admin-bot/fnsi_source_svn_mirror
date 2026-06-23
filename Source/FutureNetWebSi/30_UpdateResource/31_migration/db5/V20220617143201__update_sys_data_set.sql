delete from sys_data_set where sql_cd = -498;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-498, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER (ORDER BY datt.a1 DESC) AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, order_code AS (
SELECT
    meq.in_hospital_cd_1 AS e01,
    CASE WHEN 0 in (SELECT a1 FROM do_order_data_from) THEN json_idx ELSE NULL END AS login_ord,
    CASE WHEN 1 in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( equip ->> ''class_cd'', ''999999999999'' ) ELSE NULL END AS cl_cd,
    CASE WHEN 2 in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) ELSE NULL END AS eq_cd
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''0''
    AND meq.in_hospital_cd_1 IS NOT NULL
    AND (equip ->> ''class_type'' NOT IN ( ''2'', ''3'' ) or equip ->>''class_type'' is null)
    AND ord.ord_no = @ordNo
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
    SELECT--ダイアライザ
    ''ダイアライザ'' AS detail_id,
    mdz.in_hospital_cd_1 AS e01,
    mdz.model_number AS e02,
    ''ダイアライザ'' AS e03,
    '''' AS e04,
    ''1'' AS e05,
    '''' AS e06
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
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
    AND (equip ->> ''class_type'' NOT IN ( ''2'', ''3'' ) or equip ->>''class_type'' is null)
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.model_number AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e6
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND (equip ->> ''class_type'' IN ( ''5'' ) or equip ->>''class_type'' is null)
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
SELECT
    (detail_id:: text) as detail_id, item_cd, sum(amounttest) as amounttest
FROM
    data_all
GROUP BY item_cd, detail_id :: text
ORDER BY detail_id, item_cd
limit (SELECT
    (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd
     FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
     WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key1'' = ''CONSUMABLE_ITEAMS_NUMBER''
        AND info ->> ''key2'' = ''OUT_PUT_NUMBER'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);