DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-498);
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
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);
