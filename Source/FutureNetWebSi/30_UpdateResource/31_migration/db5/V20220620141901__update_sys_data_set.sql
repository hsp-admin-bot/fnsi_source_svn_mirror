DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1714);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1714, 'WITH exam_date_tmp AS ( 
    SELECT CASE WHEN ''@physicalInfo.ctr'' <> '''' THEN NULLIF(''@physicalInfo.examDate_CTR_GMTDate'', '''') ELSE '''' END AS exam_date,
           CASE WHEN ''@physicalInfo.examDate_CTR_GMTDate'' = ''@physicalInfo.examDate_height_GMTDate'' 
                   AND ''@physicalInfo.examDate_height_GMTDate'' <> '''' THEN 1 
                WHEN ''@physicalInfo.examDate_CTR_GMTDate'' <> ''@physicalInfo.examDate_height_GMTDate'' 
                   AND ''@physicalInfo.examDate_CTR_GMTDate'' = '''' 
                   AND ''@physicalInfo.examDate_height_GMTDate'' <> '''' THEN 1
           ELSE 0 END AS do_height_flag
) 
, exam_date_info AS ( 
  SELECT
    CASE WHEN exam_date <> '''' THEN exam_date END AS exam_date
    , CASE WHEN exam_date <> '''' THEN REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS inspect_date
    , CASE WHEN exam_date <> '''' THEN REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS indicator_start_date
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
   T01.indicator_cd
  FROM
   (
    -- 患者情報の担当医の最上位（並び順が最も上）
    (SELECT
       3 AS order_no
       , staff_info->>''staff_cd'' AS indicator_cd 
     FROM
       pat_main AS pat 
       CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info :: json) AS staff_info
     WHERE    
       pat.is_del = ''0'' 
       AND pat.pat_id = @patId
       AND pat.facility_cd = ''@facilityCd'' 
     ORDER BY 
       CASE WHEN staff_info->>''is_main'' = ''1'' THEN 0  WHEN staff_info->>''is_charge'' = ''1'' THEN 1 ELSE 2 END ASC
       , staff_info->>''ctl_no'' ASC 
       LIMIT 1
    )
    -- なければ施設設定の25番のIDを使用
    UNION 
    SELECT
      2 AS order_no
      , COALESCE(NULLIF(TRIM(fset.value), ''''), ''0'')  AS indicator_cd 
    FROM
      mst_facility_setting AS fset 
    WHERE
      fset.facility_setting_no = ''1025'' 
      AND fset.facility_cd = ''@facilityCd'' 
    -- 未指定の場合は連携設定のデフォルト指示医とする
    UNION 
    SELECT
      1 AS order_no
      , CASE 
        WHEN TRIM(ini_info ->> ''value'') = '''' OR TRIM(ini_info ->> ''value'') = ''0'' 
          THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS indicator_cd 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
      AND ini.facility_cd = ''@facilityCd'' 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''DEFAULT_DOCTOR'' 
    -- デフォルト
    UNION 
    SELECT
      0 AS order_no
      , '''' AS indicator_cd 
   ) AS T01
  WHERE
    T01.indicator_cd <> ''0''
  ORDER BY
    T01.order_no DESC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    TRIM(NULLIF(''@physicalInfo.ctr'', ''''), ''0'') AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    CASE WHEN (SELECT do_height_flag FROM exam_date_tmp) = 1 THEN TRIM(NULLIF(''@physicalInfo.height'', ''''), ''0'') ELSE NULL END AS height,
    CASE WHEN ''@physicalInfo.ctr'' = '''' THEN NULL ELSE TRIM(NULLIF(''@physicalInfo.chestDia'', ''''), ''0'') END AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    CASE WHEN ''@physicalInfo.ctr'' = '''' THEN NULL ELSE TRIM(NULLIF(''@physicalInfo.breastDia'', ''''), ''0'') END AS breast_dia,
    TRIM(NULLIF(''@physicalInfo.ctrWeight'', ''''), ''0'') AS ctr_weight,
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
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''ctr''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.ctr ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''chest_dia''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.chest_dia ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''breast_dia''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.breast_dia ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''height''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.height, ''''), ''0''), ''FM9999.99'')
    AND SUBSTR(OLD->>''exam_date''::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
    --AND TO_NUMBER(OLD->>''ctr_weight''::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr_weight ::TEXT, ''FM9999.99'') 
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
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' 
  AND ((''@physicalInfo.ctr'' <> '''' AND ''@physicalInfo.examDate_CTR_GMTDate'' <> '''')
  OR (''@physicalInfo.height'' <> '''' AND ''@physicalInfo.examDate_height_GMTDate'' <> ''''))
  AND (SELECT exam_date FROM data_new_info) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
