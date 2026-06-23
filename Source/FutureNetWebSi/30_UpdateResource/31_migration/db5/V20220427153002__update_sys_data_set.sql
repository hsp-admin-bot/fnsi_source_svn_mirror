delete from "sys_data_set" where "sql_cd" in (3103);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3103, 'WITH mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , (ms ->> ''cd''::TEXT) AS cd 
    , (''1''::TEXT) AS is_enable 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
    , (ms ->> ''start_date''::TEXT) AS start_date
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
    , NULL AS start_date
  ORDER BY order_no ASC LIMIT 1
) 
UPDATE pat_main 
SET addition_info = jsonb_set (
  COALESCE ( addition_info, ''[]'' ) :: JSONB,
  CAST((SELECT ''{'' ||  COALESCE(idx, 999) || ''}'' FROM mstInfo) AS TEXT []),
  (SELECT jsonb_build_object(''cd'', TO_NUMBER(cd, ''FM999999999999999999''), ''reg_date'', reg_date, ''is_enable'', is_enable, ''start_date'', start_date) FROM mstInfo) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→加算情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
