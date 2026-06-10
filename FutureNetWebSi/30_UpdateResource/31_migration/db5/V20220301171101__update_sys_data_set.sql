delete from "sys_data_set" where "sql_cd" in (3202);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3202, 'WITH exam_date_tmp AS ( 
  SELECT
    ''@examDate_GMTDate''::TEXT AS exam_date
) 
, exam_date_info AS ( 
  SELECT
    CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD'') ELSE exam_date END AS exam_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS inspect_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS indicator_start_date
  FROM
    exam_date_tmp
) 
, order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_CLASS'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS order_class 
  ORDER BY
    order_no ASC LIMIT 1
) 
, indicator_info AS ( 
  SELECT
   ''@staffCd''::TEXT AS indicator_cd
) 
, data_new_info AS (
  SELECT 
    NULLIF(''@physicalInfo.dw'', '''') AS dw,
    NULL AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    NULL AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    NULL AS ctr_weight,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    COALESCE(NULLIF((SELECT order_class FROM order_class_info), ''0''), ''3'') AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    ''-1'' AS target_weight
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS OLD 
    , data_new_info AS NEW 
  WHERE
    patu.pat_id = @patId 
    AND patu.facility_cd = ''@facilityCd'' 
    AND patu.is_del = ''0'' 
    AND TO_NUMBER(OLD->>''dw''::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.dw ::TEXT, ''FM9999.99'') 
    AND SUBSTR(OLD->>''exam_date''::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no
    , dw ::TEXT AS dw
    , ctr ::TEXT AS ctr
    , memo ::TEXT AS memo
    , ctl_no ::TEXT AS ctl_no
    , height ::TEXT AS height
    , chest_dia ::TEXT AS chest_dia
    , exam_date ::TEXT AS exam_date
    , breast_dia ::TEXT AS breast_dia
    , ctr_weight ::TEXT AS ctr_weight
    , facility_cd ::TEXT AS facility_cd
    , order_class ::TEXT AS order_class
    , indicator_cd ::TEXT AS indicator_cd
    , inspect_date ::TEXT AS inspect_date
    , pre_scale_lower ::TEXT AS pre_scale_lower
    , pre_scale_upper ::TEXT AS pre_scale_upper
    , indicator_start_date ::TEXT AS indicator_start_date 
    , target_weight ::TEXT AS target_weight 
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , info ->> ''dw'' AS dw
    , info ->> ''ctr'' AS ctr
    , info ->> ''memo'' AS memo
    , info ->> ''ctl_no'' AS ctl_no
    , info ->> ''height'' AS height
    , info ->> ''chest_dia'' AS chest_dia
    , info ->> ''exam_date'' AS exam_date
    , info ->> ''breast_dia'' AS breast_dia
    , info ->> ''ctr_weight'' AS ctr_weight
    , info ->> ''facility_cd'' AS facility_cd
    , info ->> ''order_class'' AS order_class
    , info ->> ''indicator_cd'' AS indicator_cd
    , info ->> ''inspect_date'' AS inspect_date
    , info ->> ''pre_scale_lower'' AS pre_scale_lower
    , info ->> ''pre_scale_upper'' AS pre_scale_upper
    , info ->> ''indicator_start_date'' AS indicator_start_date 
    , info ->> ''target_weight'' AS target_weight 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS info 
  WHERE
    pat_id = @patId  
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
  ORDER BY order_no DESC, ctl_no ASC)
, json_data AS (
  SELECT json_build_object(''dw'', TO_NUMBER(dw , ''FM9999.99''),
    ''ctr'', TO_NUMBER(ctr, ''FM9999.99''),
    ''memo'', memo,
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''height'', TO_NUMBER(height, ''FM9999.99''),
    ''chest_dia'', TO_NUMBER(chest_dia, ''FM9999.99''),
    ''exam_date'', exam_date,
    ''breast_dia'', TO_NUMBER(breast_dia, ''FM9999.99''),
    ''ctr_weight'', TO_NUMBER(ctr_weight, ''FM9999.99''),
    ''facility_cd'', facility_cd,
    ''order_class'', (order_class :: INTEGER),
    ''indicator_cd'', (NULLIF(indicator_cd, '''') :: INTEGER),
    ''inspect_date'', inspect_date,
    ''target_weight'', TO_NUMBER(target_weight, ''FM9999.99''),
    ''pre_scale_lower'', TO_NUMBER(pre_scale_lower, ''FM9999.99''),
    ''pre_scale_upper'', TO_NUMBER(pre_scale_upper, ''FM9999.99''),
    ''indicator_start_date'', indicator_start_date) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  physical_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→身体情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
