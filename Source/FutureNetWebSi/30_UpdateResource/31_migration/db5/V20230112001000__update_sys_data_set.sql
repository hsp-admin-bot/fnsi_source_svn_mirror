DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-504,-497,-503,-108,-105,-106,-2201,-514,-513,-400013,-400012,-494,-507,-508,-509,-114,-516,-517,-518,-515,-511,-400005,-400003,-107,-110,-510,-109,-498,-16);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-504, 'WITH do_order_data_from AS (
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
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
ORDER BY del_date DESC LIMIT 1
)
, data_all_A AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') AS amount,
  (CASE WHEN ''0''=(SELECT
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
    COALESCE(all_cost.e05, ''0'') ::INTEGER else 
      COALESCE(all_cost.e05, ''0'') ::INTEGER * 100
      END) AS amounttest, 
    COALESCE(all_cost.e06, '''') AS unit,
    all_cost.syoumouhinOrder AS syoumouhinOrder, 1 as dodo
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    11 AS syoumouhinOrder
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
    meq.unit AS e06,
    8 AS syoumouhinOrder
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
    meq.unit AS e06,
    9 AS syoumouhinOrder
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
    meq.unit AS e06,
    10 AS syoumouhinOrder
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
    equip ->> ''unit'' AS e06,
    12 AS syoumouhinOrder
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
    equip ->> ''unit'' AS e6,
    12 AS syoumouhinOrder
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
    equip ->> ''unit'' AS e6,
    25 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
  SELECT--医材情報
    ''加算・管理料'' AS detail_id,
    adt.in_hospital_cd_1 AS e01,
    adt.addition_name AS e02,
    ''加算・管理料'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    '''' AS e6,
    1 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    6 AS syoumouhinOrder
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  UNION ALL
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    7 AS syoumouhinOrder
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  UNION ALL
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    5 AS syoumouhinOrder
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
)
, do_data_group_A AS (
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, SUM(amounttest) AS amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder, 1 AS dodogroup
FROM  
    data_all_A
GROUP BY item_cd, detail_id :: text, name
)
, data_all_B AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') AS amount,
   (CASE WHEN ''0''=(SELECT
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
    COALESCE(all_cost.e05, ''0'') ::INTEGER else 
      COALESCE(all_cost.e05, ''0'') ::INTEGER * 100
    END) AS amounttest, 
    COALESCE(all_cost.e06, '''') AS unit,
    all_cost.syoumouhinOrder AS syoumouhinOrder, 2 as dodo
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    11 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    meq.unit AS e06,
    8 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    meq.unit AS e06,
    9 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    meq.unit AS e06,
    10 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    equip ->> ''unit'' AS e06,
    12 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    equip ->> ''unit'' AS e6,
    12 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
    equip ->> ''unit'' AS e6,
    25 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
  SELECT--医材情報
    ''加算・管理料'' AS detail_id,
    adt.in_hospital_cd_1 AS e01,
    adt.addition_name AS e02,
    ''加算・管理料'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    '''' AS e6,
    1 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    6 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  UNION ALL
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    7 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  UNION ALL
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06,
    5 AS syoumouhinOrder
  FROM
    --ord_main_restore AS ord
        do_ord AS ord
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
)
, do_data_group_B AS (
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, SUM(amounttest) AS amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder, 2 AS dodogroup
FROM  
    data_all_B
GROUP BY item_cd, detail_id :: text, name
) 
, doAll_data_middle AS (
SELECT item_cd, type_name, dodo FROM data_all_A
UNION ALL
SELECT item_cd, type_name, dodo FROM data_all_B
)
, doAll_data_group_middle AS (
SELECT detail_id AS detail_id, item_cd AS item_cd, name, amounttest AS amounttest, syoumouhinOrder AS syoumouhinOrder, dodogroup AS dodogroup FROM do_data_group_A
UNION ALL
SELECT detail_id AS detail_id, item_cd AS item_cd, name, amounttest AS amounttest, syoumouhinOrder AS syoumouhinOrder, dodogroup AS dodogroup FROM do_data_group_B
)
, data_all AS (
SELECT * FROM doAll_data_middle 
WHERE CASE WHEN (SELECT COUNT(*) FROM data_all_B) > 0 THEN dodo = 2 ELSE dodo = 1 END 
)
, do_data_group AS (
SELECT * FROM doAll_data_group_middle 
WHERE CASE WHEN (SELECT COUNT(*) FROM data_all_B) > 0 THEN dodogroup = 2 ELSE dodogroup = 1 END 
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
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE ord.ord_no = @ordNo
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
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績)中止時）医材繰り返し部', '2022-07-27 01:34:23.636', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-497, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
,EQUIP_OUTPUT_TYPE_cd AS(SELECT
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
,CREATE_NUMBER_FUNCTION_cd AS(SELECT
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
, do_ord_main AS (
SELECT * FROM ord_main as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( medi ->> ''class_cd'' :: text, ''999999999999'' ) AS class_M_cd,
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
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(medi ->> ''class_cd'' :: text, ''999999999999'' )
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
  ''薬剤'' AS detail_id,
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
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
        2 AS e09
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
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
        3 AS e09
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
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
        1 AS e09
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
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
        4 AS e09
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
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
        4 AS e09
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
          4 AS e09
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) )) AS all_cost GROUP BY item_cd,all_cost.e05,all_cost.e08,all_cost.e09
)
, data_middle_all AS (
SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  (SELECT middle_data.amount FROM middle_data WHERE middle_data.item_cd = all_cost.e01) AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
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
    ''投与薬剤'' AS detail_id,
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
    ''投与薬剤'' AS detail_id,
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
    ''投与薬剤'' AS detail_id,
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
      ''投与薬剤'' AS detail_id,
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
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) ) as all_cost1 where all_cost1.e01 = all_cost.e01) count
            , all_cost.e09 AS cond_info_jyun, medi_type AS medi_type
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
    ''NULL'' AS e07,
    ''0'' AS e08,
    2 AS e09,
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
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    3 AS e09,
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
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    1 AS e09,
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
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
    4 AS e09,
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
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
    4 AS e09,
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
      4 AS e09,
            ''1'' AS medi_type
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) ) all_cost
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
    detail_id, item_cd, amount, unit, count, cond_info_jyun, 
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS date_interval
FROM
    data_all ) AS order_middle
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
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤の投薬回数のSQL)', '2022-05-09 05:52:21.853',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-503, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
,EQUIP_OUTPUT_TYPE_cd AS(SELECT
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
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
ORDER BY del_date DESC LIMIT 1
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( medi ->> ''class_cd'' :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(medi ->> ''class_cd'' :: text, ''999999999999'' )
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
FROM do_ord AS ord
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
  (sum(all_cost.e04::float)*100)::INTEGER AS amount
FROM (
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    2 AS e08
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    3 AS e08
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    1 AS e08
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
 UNION ALL
   SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    TRIM(mmd.in_hospital_cd_1) AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    4 AS e08
  FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( TRIM(mmd.in_hospital_cd_1), ''ZERO'' ) <> ''ZERO''
UNION ALL
  SELECT--投与薬剤情報(調製)
     ''投与薬剤'' AS detail_id,
     TRIM(mmd.in_hospital_cd_1) AS e1,
     mmd.medicine_name AS e2,
     mmdc.class_name AS e03,
     to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
     mmd.unit AS e05,
     mp.in_hospital_cd_a1 AS e06,
     medi ->> ''procedure_name'' AS e07,
     4 AS e08 
    FROM
      do_ord AS ord
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
      TRIM(mmd.in_hospital_cd_1) AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      4 AS e08
    FROM
      do_ord AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) ) all_cost group by all_cost.e01,all_cost.e05,all_cost.e08
)
, data_middle_all AS (
SELECT
  ''薬剤del'' AS detail_id,
  all_cost.e01 AS item_cd,
    (SELECT middle_data.amount FROM middle_data WHERE middle_data.item_cd = all_cost.e01) ::INTEGER AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    TRIM(mmd.in_hospital_cd_1) AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07
  FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( TRIM(mmd.in_hospital_cd_1), ''ZERO'' ) <> ''ZERO''
  UNION ALL
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
         meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(調製)
      ''投与薬剤'' AS detail_id,
      TRIM(mmd.in_hospital_cd_1) AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
      to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
   FROM
      do_ord AS ord
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
      TRIM(mmd.in_hospital_cd_1) AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07
    FROM
      do_ord AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' )) as all_cost1 where all_cost1.e01 = all_cost.e01) count
            , all_cost.e08 AS cond_info_jyun, medi_type AS medi_type
FROM
  (
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
    meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    2 AS e08,
        ''1'' AS medi_type
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    3 AS e08,
        ''1'' AS medi_type
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    TRIM(meq.in_hospital_cd_1) AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    1 AS e08,
        ''1'' AS medi_type
  FROM
    do_ord ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
 UNION ALL
   SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    TRIM(mmd.in_hospital_cd_1) AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    4 AS e08,
        medi ->> ''medicine_type'' AS medi_type
  FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( TRIM(mmd.in_hospital_cd_1), ''ZERO'' ) <> ''ZERO''
UNION ALL
  SELECT--投与薬剤情報(調製)
     ''投与薬剤'' AS detail_id,
     TRIM(mmd.in_hospital_cd_1) AS e1,
     mmd.medicine_name AS e2,
     mmdc.class_name AS e03,
     to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) AS e04,
     mmd.unit AS e05,
     mp.in_hospital_cd_a1 AS e06,
     medi ->> ''procedure_name'' AS e07,
     4 AS e08,
         medi ->> ''medicine_type'' AS medi_type
    FROM
      do_ord AS ord
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
      TRIM(mmd.in_hospital_cd_1) AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      4 AS e08,
            ''1'' AS medi_type
    FROM
      do_ord AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
    group by all_cost.e01,all_cost.e05,all_cost.e08, all_cost.medi_type
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
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
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
    do_ord AS ord
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
SELECT detail_id, item_cd, amount, unit, count, cond_info_jyun, 
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS date_interval
FROM data_all ) AS order_middle
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
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績)中止時）薬剤の投薬回数のSQL)', '2022-07-27 01:34:23.644', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2201, 'SELECT COALESCE
           (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
FROM mst_coop_ini AS ini
         CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
WHERE facility_cd = @facilityCd

  AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
  AND info ->> ''key1'' = ''DIALYSISSEND''
  AND info ->> ''key2'' = ''HEADER_MODE''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, '2022-06-11 14:01:34',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-114, 'WITH 
dialysateSql AS (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as dialysateTransCd
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
	from ord_main ord,dialysateSql
WHERE
  ord.ord_no =  @ordNo', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析液使用量（単体薬剤）', '2022-09-12 12:54:26.263', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-516, 'with coop_ini as (SELECT COALESCE
                             ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
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
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select
    case when coop_ini.header_mode=  ''1'' then  ''1'' else '' ''
        end as type_cd
from coop_ini', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理区分
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-515, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
										AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select case
           when coop_ini.header_mode = ''1''
					 then to_char(CURRENT_TIMESTAMP, ''YYYYMMDDHH12MISS'') else ''              ''
           end sys_date
from coop_ini

', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理日時
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-511, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
),
     journal as (
         SELECT coop_ord_no
         from sys_coop_journal
         WHERE facility_cd = @facilityCd
           AND ord_no = @ordNo
           AND coop_cd = ''rst_dial''
           AND coop_ord_no IS NOT NULL
         union
         select ''0'' as coop_ord_no
         order by coop_ord_no DESC
         LIMIT 1 )
select case
           when journal.coop_ord_no = ''0'' then ''            ''
           else
               (case
                   when coop_ini.header_mode = ''1''
                       then journal.coop_ord_no
                   else ''            ''
                   end)
           end coop_ord_no
FROM coop_ini,
     journal
', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析番号取得（削除）', '2022-09-05 08:14:41.911', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400005, 'SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as len
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''PAT_LENGTH''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-06-07 12:13:42.213', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400003, 'SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS aligh
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''PAT_ALIGN''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-05-17 08:54:31.633', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-110, 'WITH 
	A AS ( 
	SELECT (((rst_cond_info -> ''26'' ->> ''value'' )::FLOAT + (rst_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount
	FROM ord_main 
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
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
	) 
SELECT B.default_setting,
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
) AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）', '2022-06-08 15:38:53', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-510, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
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
A', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：診療科コード取得（削除）', '2022-09-05 08:14:41.911', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, 'WITH A AS (
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
                            AND is_del = ''0''
                      ) s
                 WHERE save_1 ->> ''pkg'' = ''GX''
                   AND reg_date < (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo)
                 ORDER BY reg_date DESC
                 LIMIT 1
             ) AS ord_no
      FROM A
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-105, 'WITH A AS (
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
	WHEN ( SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo))
			END
	ELSE
		A.default_in_hospital_cd
END
	) AS in_hospital_cd_1
FROM
A', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '実績（治療中）：診療科コード @ordNo 使用', '2022-05-27 15:57:30',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-106, 'with CONV_INOUT_TO_KARTE as (
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
  ord_main LEFT JOIN CONV_INOUT_TO_KARTE ON
  ord_main.rst_in_out_class || '''' = CONV_INOUT_TO_KARTE.CONV_INOUT || ''''
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '透析実績：入外区分取得', '2022-06-02 11:22:26', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-514, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
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
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：入外区分取得（削除）', '2022-08-22 12:05:22.245', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-513, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
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
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析条件-治療コード（削除）', '2022-08-22 12:05:22.245', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400013, 'WITH query0 AS (--酸素吸入用薬剤コード
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
					( to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm000'' ) ) ELSE to_char( SUM ( K.sumresultvalue1 :: INTEGER ), ''fm0'' ) 
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
										( to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm000'' ) ) ELSE to_char( SUM ( K.sumResultValue2 :: INTEGER ), ''fm0'' ) 
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
															( to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm000'' ) ) ELSE to_char( SUM ( K.sumResultValue3 :: INTEGER ), ''fm0'' ) 
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
																			( to_char( ( query4.oxygen_amount :: INTEGER ), ''fm000'' ) ) ELSE to_char( ( query4.oxygen_amount :: INTEGER ), ''fm0'' ) 
																		END 
																		) AS oxygen_amount 
																FROM
	query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-15 08:44:53.101', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400012, 'WITH dialysateSql AS (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as dialysateTransCd
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
	from ord_main ord,dialysateSql
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2022-06-11 06:40:08.234',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-494, 'SELECT
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
  UNION
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
  UNION
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
  UNION
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
  UNION
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
  UNION
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
  UNION
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
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	  AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
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
        and ''0''=(SELECT
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
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
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
      and ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd
    AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')  
  ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL 
ORDER BY
  all_cost.e01
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
            AND info ->> ''key2'' = ''OUT_PUT_NUMBER'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-507, 'WITH 
	ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	),
	A AS ( 
	SELECT (((rst_cond_info -> ''26'' ->> ''value'' )::FLOAT + (rst_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount
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
	) 
SELECT B.default_setting,
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
) AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-508, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
),
dialysateSql AS (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as dialysateTransCd
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
  ord.ord_no =  @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:透析液使用量（単体薬剤）（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-509, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
),
query0 AS (--酸素吸入用薬剤コード
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::text as oxygen_medi_cd
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
	AND info ->> ''key2'' = ''OXYGEN_CODE''),
query1 AS (--酸素吸入量
	SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue1
	FROM
		( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main_restore_info ord WHERE ord.ord_no = @ordNo
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
				ord_main_restore_info ord
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
				ord_main_restore_info ord
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
	from query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:酸素吸入量（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-517, 'with coop_ini as (SELECT COALESCE
                             ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
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
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select
    case when coop_ini.header_mode=  ''1'' then  ''2'' else '' ''
        end as type_cd
from coop_ini', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理区分（削除）
', '2022-06-07 03:24:08.677',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-518, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
										AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select case
           when coop_ini.header_mode = ''1''
               then coop_ord_no
           else ''            ''
           end
           AS coop_ord_no
FROM sys_coop_journal,
     coop_ini
WHERE ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-透析番号
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-107, 'with IN_HOSPITAL as (
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
    ord_main AS ord
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd,
		IN_HOSPITAL
WHERE
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2020-03-17 15:42:41',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-109, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
),
mst_user_authenticator as(		select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main ord, mst_kur mst where ord.rst_kur_cd = mst.kur_cd 
		and ord.ord_no = @ordNo 
		
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
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-498, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
), EQUIP_OUTPUT_TYPE_cd AS 
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
  ''医材'' AS detail_id,
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
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND ord.ord_no = @ordNo
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
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--1次膜情報
    ''医材'' AS detail_id,
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
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    and ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--2次膜情報
    ''医材'' AS detail_id,
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
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
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
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
),
data_all_weight AS (
SELECT
  ''医材'' AS detail_id,
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
	''医材'' AS detail_id,
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
   from ord_main where ord_no =@ordNo
	 and rst_cond_info-> ''3'' ->> ''value'' is not NULL
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
	''医材'' AS detail_id,
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
   from ord_main where ord_no =@ordNo
	 and rst_weight_info ->> ''weight_before'' is not NULL
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
	''医材'' AS detail_id,
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
   from ord_main where ord_no = @ordNo
	 and rst_weight_info ->> ''weight_after'' is not NULL
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
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE ord.ord_no = @ordNo
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
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-16, 'select 
  1 AS  ctl_no, 
	diff->>''dial_diff_cd'' as cd
from
	pat_personal_main as ppm,
	json_array_elements (ppm.dial_diff_com_info :: json) diff
where
	diff->>''is_main'' = ''1'' and 
	ppm.pat_id = ''31381''
UNION
SELECT
 2 AS  ctl_no, 
	''-1'' AS cd
	ORDER BY ctl_no ASC
	LIMIT 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '主たる透析困難コメントコード', '2020-04-10 14:35:26.747', CURRENT_TIMESTAMP, NULL);
