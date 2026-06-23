delete from "sys_data_set" where "sql_cd" in (2101,2102,2103,2104,2105,2106);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2101, 'WITH order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''key2'') WHEN ''CODE_BEFORE_DIALYSIS'' THEN ''1'' ELSE ''2'' END reg_order_class
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND (TRIM(ini_info ->> ''key2'') = ''CODE_BEFORE_DIALYSIS'' OR TRIM(ini_info ->> ''key2'') = ''CODE_AFTER_DIALYSIS'')
    AND ( CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN TRIM(ini_info ->> ''default_v'') ELSE TRIM(ini_info ->> ''value'') END) = @regOrderClass
    AND '''' <> @regOrderClass
  UNION
  SELECT
    2 AS order_no
    , ''0'' AS reg_order_class
  ORDER BY order_no ASC LIMIT 1
) 
SELECT
  exam_main_cd
  , pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , TO_CHAR(reg_exam_date, ''YYYYMMDDHH24MISS'') AS reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , TO_CHAR(result_exam_date, ''YYYYMMDDHH24MISS'') AS result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
  , exam_week
  , TO_CHAR(exam_from, ''YYYYMMDDHH24MISS'') AS exam_from
  , TO_CHAR(exam_to, ''YYYYMMDDHH24MISS'') AS exam_to
  , exam_pattern
  , ( 
    SELECT (COALESCE(MAX(TO_NUMBER(COALESCE(NULLIF(RESULT ->> ''disp_order'', ''''), ''0''), ''FM99999'')) , 0) + 1) AS next_disp_order 
    FROM
      pat_exam_main exam 
      CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) RESULT 
    WHERE
      exam.exam_main_cd = pat_exam_main.exam_main_cd
  ) AS next_disp_order 
FROM
  pat_exam_main 
WHERE
  is_del = ''0'' 
  AND facility_cd = @facilityCd
  AND pat_id = @patId 
  AND (TO_CHAR(reg_exam_date, ''YYYYMMDD'') = TO_CHAR(TO_TIMESTAMP(@regExamDate, ''YYYYMMDDHH24MISS'' ) , ''YYYYMMDD'')) 
  AND reg_order_class = (SELECT reg_order_class FROM order_class_info)
  AND (@copOrderNo1 = '''' OR (@copOrderNo1 <> '''' AND cop_order_no1 = TO_NUMBER(NULLIF(@copOrderNo1, ''''), ''FM999999999999999999'')))', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2102, 'WITH order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''key2'') WHEN ''CODE_BEFORE_DIALYSIS'' THEN ''1'' ELSE ''2'' END reg_order_class
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND (TRIM(ini_info ->> ''key2'') = ''CODE_BEFORE_DIALYSIS'' OR TRIM(ini_info ->> ''key2'') = ''CODE_AFTER_DIALYSIS'')
    AND (CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN TRIM(ini_info ->> ''default_v'') ELSE TRIM(ini_info ->> ''value'') END) = ''@regOrderClass''
    AND '''' <> ''@regOrderClass''
  UNION
  SELECT
    2 AS order_no
    , ''0'' AS reg_order_class
  ORDER BY order_no ASC LIMIT 1
) 
INSERT 
INTO pat_exam_main( 
  pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
  , exam_week
  , exam_from
  , exam_to
  , exam_pattern
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , CASE ''@ordNo'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@ordNo'', ''FM999999999999999999'') 
    END
  , NULLIF(''@fnPatId'', '''')
  , CASE ''@regExamDate'' 
    WHEN '''' THEN CURRENT_TIMESTAMP 
    ELSE TO_TIMESTAMP(TO_CHAR(TO_TIMESTAMP(''@regExamDate'', ''YYYYMMDDHH24MISS'' ) , ''YYYYMMDD''), ''YYYYMMDDHH24MISS'') 
    END
  , (SELECT reg_order_class FROM order_class_info)
  , NULLIF(''@examStatus'', '''')
  , NULLIF(''@orderComment'', '''')
  , ''@orderExamSetInfoValue''
  , ''@examOrderInfoValue''
  , ''@orderLabelInfoValue''
  , NULLIF(''@dataGenClass'', '''')
  , CASE ''@resultExamDate'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@resultExamDate'', ''YYYYMMDDHH24MISS'') 
    END
  , NULLIF(''@resultComment'', '''')
  , ''@examResultInfoValue''
  , CASE ''@copOrderNo1'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@copOrderNo1'', ''FM999999999999999999'') 
    END
  , CASE ''@copOrderNo2'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@copOrderNo2'', ''FM999999999999999999'') 
    END
  , NULLIF(''@isLock'', '''')
  , CASE ''@indUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indUserId'', ''FM999999999999999999'') 
    END
  , ''0''
  , CURRENT_TIMESTAMP
  , CASE ''@regStaff'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@regStaff'', ''FM999999999999999999'') 
    END
  , CURRENT_TIMESTAMP
  , CASE ''@upStaff'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@upStaff'', ''FM999999999999999999'') 
    END
  , NULLIF(''@isOrder'', '''')
  , CASE ''@examWeek'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@examWeek'', ''FM999999999999999999'') 
    END
  , CASE ''@examFrom'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@examFrom'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examTo'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@examTo'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examPattern'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@examPattern'', ''FM999999999999999999'') 
    END
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2103, 'UPDATE pat_exam_main 
SET
  ind_user_id = CASE ''@indUserId'' 
    WHEN '''' THEN ind_user_id 
    ELSE TO_NUMBER(''@indUserId'', ''FM999999999999999999'') 
    END
  , cop_order_no1 = CASE ''@copOrderNo1'' 
    WHEN '''' THEN cop_order_no1 
    ELSE TO_NUMBER(''@copOrderNo1'', ''FM999999999999999999'') 
    END
  , result_comment = CASE ''@resultComment'' 
    WHEN '''' THEN result_comment 
    ELSE ''@resultComment''
    END
  , result_exam_date = CASE ''@resultExamDate'' 
    WHEN '''' THEN result_exam_date 
    ELSE TO_TIMESTAMP(''@resultExamDate'', ''YYYYMMDDHH24MISS'') 
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2104, 'UPDATE pat_exam_main 
SET
  is_del = ''1''
  , ind_user_id = CASE ''@indUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indUserId'', ''FM999999999999999999'') 
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2105, 'UPDATE pat_exam_main 
SET exam_result_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2106, 'WITH result_comment1 AS ( 
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
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
) 
, result_comment2 AS ( 
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
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
) 
, freememo_info_join AS ( 
  SELECT
    0 AS order_no
    , ''@examResultInfo.freememo'' AS freememo_text 
  UNION 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF((SELECT comment_text FROM result_comment1), ''''), (CASE WHEN ''@examResultInfo.resultComment1Code'' = '''' THEN '''' ELSE ''結果コメント１コード[@examResultInfo.resultComment1Code]'' END )) AS freememo_text 
  UNION 
  SELECT
    2 AS order_no
    , COALESCE(NULLIF((SELECT comment_text FROM result_comment2), ''''), (CASE WHEN ''@examResultInfo.resultComment2Code'' = '''' THEN '''' ELSE ''結果コメント２コード[@examResultInfo.resultComment2Code]'' END )) AS freememo_text 
  ORDER BY
    order_no ASC
) 
, freememo_info AS ( 
  SELECT
    STRING_AGG(freememo_text, '','') AS freememo 
  FROM
    freememo_info_join 
  WHERE
    NULLIF(freememo_text, '''') IS NOT NULL
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
    , NULLIF(''@examResultInfo.result'', '''') AS result
    , NULLIF((SELECT freememo FROM freememo_info), '''') AS freememo
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
    , NULLIF(''@examResultInfo.result'', '''') AS result
    , NULLIF((SELECT freememo FROM freememo_info), '''') AS freememo
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
  CAST((SELECT ''{"item_cd":"'' || item_cd 
          || ''", "item_name":"'' || COALESCE(NULLIF(item_name, ''''), '''')
          || ''", "type":"'' || COALESCE(NULLIF(type, ''''), '''')
          || ''", "unit":"'' || COALESCE(NULLIF(unit, ''''), '''')
          || ''", "exam_class":"'' || COALESCE(NULLIF(exam_class, ''''), '''')
          || ''", "upper":"'' || COALESCE(NULLIF(upper, ''''), '''')
          || ''", "lower":"'' || COALESCE(NULLIF(lower, ''''), '''')
          || ''", "com_cd":"'' || COALESCE(NULLIF(com_cd, ''''), '''')
          || ''", "disp_order":"'' || COALESCE(NULLIF(disp_order, ''''), '''')
          || ''", "hl":"'' || COALESCE(NULLIF(hl, ''''), '''')
          || ''", "result":"'' || COALESCE(NULLIF(result, ''''), '''')
          || ''", "freememo":"'' || COALESCE(NULLIF(freememo, ''''), '''')
          || ''", "result_date":"'' || COALESCE(NULLIF(result_date, ''''), '''') || ''"}'' FROM mstInfo) AS JSONB) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
