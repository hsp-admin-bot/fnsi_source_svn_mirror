delete from ntss.sys_data_set where sql_cd in (2106, 2107);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (2106, 'WITH result_comment1 AS (
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント１コード[@examResultInfo.resultComment1Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment1Code'' 
    AND '''' <> ''@examResultInfo.resultComment1Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント１コード[@examResultInfo.resultComment1Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment1Code''
  ORDER BY order_no ASC LIMIT 1
) 
, result_comment2 AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント２コード[@examResultInfo.resultComment2Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment2Code'' 
    AND '''' <> ''@examResultInfo.resultComment2Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント２コード[@examResultInfo.resultComment2Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment2Code''
  ORDER BY order_no ASC LIMIT 1
) 
, examin_get_info AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS examin_get_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''EXAMIN_GET_DESTINATION'' 
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS examin_get_flag
  ORDER BY order_no ASC LIMIT 1
) 
, freememo_info_join_0 AS ( 
  SELECT
    0 AS order_no
    , ''@examResultInfo.freememo'' AS freememo_text 
  UNION 
  SELECT
    1 AS order_no
    , (SELECT comment_text FROM result_comment1) AS freememo_text 
  UNION 
  SELECT
    2 AS order_no
    , (SELECT comment_text FROM result_comment2) AS freememo_text 
  ORDER BY
    order_no ASC
) 
, result_freememo_info AS ( 
  -- 0:電文.検査結果
  SELECT
    ''@examResultInfo.result'' AS result
    , (SELECT STRING_AGG(freememo_text, '','') AS freememo FROM freememo_info_join_0 WHERE NULLIF(freememo_text, '''') IS NOT NULL) AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) = ''0''
  -- 1:電文.検査結果フリー
  UNION 
  SELECT
    -- Ⅰ)検査結果フリーに値がある場合
    CASE WHEN ''@examResultInfo.freememo'' != '''' 
           THEN ''@examResultInfo.freememo'' 
         -- Ⅱ)検査結果フリーに値がなく、検査結果と結果コメント１コードのいずれにも値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''@examResultInfo.result'' || (SELECT comment_text FROM result_comment1)
         -- Ⅲ) 検査結果フリーに値がなく、検査結果のみに値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
           THEN ''@examResultInfo.result''
         -- Ⅳ) 検査結果フリーに値がなく、結果コメント１コードのみに値がある場合
         WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''''
         ELSE ''''
         END AS result
    , CASE WHEN ''@examResultInfo.freememo'' != '''' 
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN (SELECT comment_text FROM result_comment1)
         ELSE ''''
         END AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) != ''0''
) 
, mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''item_cd'' AS item_cd 
    , ms->>''item_name'' AS item_name 
    , ms->>''type'' AS type 
    , ms->>''unit'' AS unit 
    , ms->>''exam_class'' AS exam_class 
    , ms->>''normal_value_upper'' AS upper 
    , ms->>''normal_value_lower'' AS lower 
    , ms->>''com_cd'' AS com_cd 
    , ms->>''disp_order'' AS disp_order 
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    pat_exam_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.exam_result_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND exam_main_cd = @examMainCd 
    AND ms->>''item_cd'' :: TEXT = ''@examResultInfo.itemCd''
  UNION
  SELECT
    2 AS order_no
    , NULL AS idx
    , (A.exam_item_cd :: TEXT) AS item_cd
    , A.exam_item_name AS item_name
    , A.data_type AS type
    , A.unit
    , A.exam_class
    , A.input_upper AS upper
    , A.input_lower AS lower
    , null AS com_cd
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    mst_exam_item A
  WHERE
    A.exam_item_cd = TO_NUMBER(''@examResultInfo.itemCd'', ''FM999999999999999999'')
  ORDER BY order_no ASC LIMIT 1
) 
UPDATE pat_exam_main 
SET exam_result_info = jsonb_set(
  COALESCE(exam_result_info, ''[]'') :: JSONB,
  CAST((SELECT ''{'' || COALESCE(idx, 999) || ''}'' FROM mstInfo ) AS TEXT []),
  (SELECT jsonb_build_object(''item_cd'', TO_NUMBER(item_cd, ''FM999999999999999999'')
          , ''item_name'' , NULLIF(item_name, '''')
          , ''type'' , TO_NUMBER(NULLIF(type, ''''), ''FM999999999999999999'') 
          , ''unit'' , NULLIF(unit, '''')
          , ''exam_class'' , NULLIF(exam_class, '''')
          , ''upper'' , TO_NUMBER(NULLIF(upper, ''''), ''FM999999999999999999'')
          , ''lower'' , TO_NUMBER(NULLIF(lower, ''''), ''FM999999999999999999'')
          , ''com_cd'' , NULLIF(com_cd, '''')
          , ''disp_order'' , TO_NUMBER(NULLIF(disp_order, ''''), ''FM999999999999999999'') 
          , ''hl'' , NULLIF(hl, '''')
          , ''result'' , COALESCE(result, ''delete'')
          , ''freememo'' , NULLIF(freememo, '''')
          , ''result_date'' , NULLIF(result_date, '''')) FROM mstInfo) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd 
  AND ((NULLIF((SELECT result FROM result_freememo_info), '''')) IS NOT NULL
    OR (NULLIF((SELECT freememo FROM result_freememo_info), '''')) IS NOT NULL)', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (2107, 'with nowData as (select jsonb_agg((exam_result_info ->> (idx - 1)::int)::json) as nowJosn
                 from pat_exam_main
                          CROSS JOIN jsonb_array_elements(exam_result_info) WITH ORDINALITY arr(j, idx)
                 WHERE (j ->> ''result'')::text <> ''delete''
                   and is_del = ''0''
                   and pat_id = @patId
                   and facility_cd = ''@facilityCd''
                   and exam_main_cd = @examMainCd)
update pat_exam_main
set exam_result_info = nowData.nowJosn
from nowData
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and exam_main_cd = @examMainCd ', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
