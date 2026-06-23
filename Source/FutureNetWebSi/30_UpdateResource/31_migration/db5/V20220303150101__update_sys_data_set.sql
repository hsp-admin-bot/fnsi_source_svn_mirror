delete from "sys_data_set" where "sql_cd" in (3103,1105,1106,1007);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3103, 'WITH mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , (ms ->> ''cd''::TEXT) AS cd 
    , (''1''::TEXT) AS is_enable 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.addition_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''cd'' :: TEXT = ''@additionInfo.cd''
  UNION
  SELECT
    2 AS order_no
    , NULL AS idx
    , (''@additionInfo.cd''::TEXT) AS cd 
    , (''1''::TEXT) AS is_enable 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
  ORDER BY order_no ASC LIMIT 1
) 
UPDATE pat_main 
SET addition_info = jsonb_set (
  COALESCE ( addition_info, ''[]'' ) :: JSONB,
  CAST((SELECT ''{'' ||  COALESCE(idx, 999) || ''}'' FROM mstInfo) AS TEXT []),
  (SELECT jsonb_build_object(''cd'', TO_NUMBER(cd, ''FM999999999999999999''), ''reg_date'', reg_date, ''is_enable'', is_enable) FROM mstInfo) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→加算情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1106, 'WITH mstInfo AS (
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''is_main'' AS is_main
    , ms->>''reg_date'' AS reg_date
    , ms->>''dial_diff_cd'' AS dial_diff_cd
    , ms->>''is_dial_diff'' AS is_dial_diff
  FROM
    pat_personal_main
    CROSS JOIN LATERAL jsonb_array_elements(dial_diff_com_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND (ms->>''is_main'' :: TEXT) = ''1''
  UNION 
  SELECT
    2 AS order_no
    , null AS idx 
    , null AS is_main
    , null AS reg_date
    , null AS dial_diff_cd
    , null AS is_dial_diff
  ORDER BY
    order_no ASC LIMIT 1
)
UPDATE pat_personal_main 
SET
  dial_diff_com_info = jsonb_set (
    COALESCE ( dial_diff_com_info, ''[]'' ) :: JSONB,
    CAST((SELECT ''{'' ||  idx || ''}'' FROM mstInfo) AS TEXT []),
    (SELECT jsonb_build_object(''is_main'', ''0'', ''reg_date'', reg_date, ''dial_diff_cd'', dial_diff_cd, ''is_dial_diff'', is_dial_diff) FROM mstInfo) :: JSONB 
  ) 
  , up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
  AND ''@dialDiffUpd'' = ''0'' -- 障害者加算が存在しない場合の更新有無:0：更新する
  AND (SELECT idx FROM mstInfo) IS NOT NULL -- 主欄のチェックしたデータがあり', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者個人情報→透析困難情報の設定(障害者加算が存在しない場合の更新有無→主欄のチェック)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1007, "field_name": "dial_diff_upd", "replace_var": "@dialDiffUpd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1105, 'WITH reg_date_info AS (
  SELECT COALESCE(NULLIF(''@regDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'')) AS reg_date
)
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_personal_main
    CROSS JOIN LATERAL json_array_elements(dial_diff_com_info :: json) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND (info->>''dial_diff_cd'' ::TEXT) = (''@dialDiffComInfo.dialDiffCd'' ::TEXT) 
    AND (''@dialDiffComInfo.dialDiffCd'' ::TEXT) != ''''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT 
    0 AS order_no,
    ''1'' AS is_main, 
    (SELECT reg_date FROM reg_date_info) AS reg_date, 
    TO_NUMBER((''@dialDiffComInfo.dialDiffCd'' ::TEXT), ''FM9999999999999999'') AS dial_diff_cd, 
    ''1'' AS is_dial_diff 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
    AND (''@dialDiffComInfo.dialDiffCd'' ::TEXT) != '''' 
  UNION 
  SELECT
    1 AS order_no,
    CASE WHEN new_data.dial_diff_cd IS NULL 
      THEN ''0''
      ELSE ''1''
      END AS is_main, 
    CASE WHEN new_data.dial_diff_cd IS NULL 
      THEN info->> ''reg_date'' 
      ELSE (SELECT reg_date FROM reg_date_info) 
      END AS reg_date, 
    TO_NUMBER((info ->> ''dial_diff_cd'' :: TEXT), ''FM9999999999999999'') AS dial_diff_cd,  
    CASE WHEN new_data.dial_diff_cd IS NULL 
      THEN info ->> ''is_dial_diff'' 
      ELSE ''1'' 
      END AS is_dial_diff 
  FROM
    pat_personal_main
    CROSS JOIN LATERAL json_array_elements(dial_diff_com_info :: json) AS info 
    LEFT JOIN (SELECT ''@dialDiffComInfo.dialDiffCd'' ::TEXT AS dial_diff_cd) AS new_data ON new_data.dial_diff_cd = (info->>''dial_diff_cd''::TEXT) AND (''@dialDiffComInfo.dialDiffCd'' ::TEXT) != ''''
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, dial_diff_cd ASC
)
, json_data AS (
  SELECT json_build_object(
    ''is_main'', is_main, 
    ''reg_date'', reg_date,
    ''dial_diff_cd'', dial_diff_cd, 
    ''is_dial_diff'', is_dial_diff) AS new_data
  FROM data_info
)
UPDATE pat_personal_main 
SET
  dial_diff_com_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者個人情報→透析困難情報の設定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1007, 'SELECT
  1 AS order_no
  , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dial_diff_upd 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
WHERE
  ini.is_del = ''0'' 
  AND ini.facility_cd = @facilityCd 
  AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
  AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_DIAL_DIFF_UPD'' 
UNION
SELECT
  2 AS order_no
  , ''0'' AS dial_diff_upd
ORDER BY order_no ASC LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者個人情報→連携設定の障害者加算が存在しない場合の更新有無', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
