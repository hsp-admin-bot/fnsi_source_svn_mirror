delete from "sys_data_set" where "sql_cd" in (2101,2102);
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
  AND pat_id = @patId 
  AND facility_cd = @facilityCd
  AND reg_exam_date = TO_TIMESTAMP(@regExamDate, ''YYYYMMDDHH24MISS'') 
  AND reg_order_class = (SELECT reg_order_class FROM order_class_info)
  AND exam_status = ''1''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
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
  , TO_TIMESTAMP(NULLIF(''@regExamDate'', ''''), ''YYYYMMDDHH24MISS'' ) 
  , (SELECT reg_order_class FROM order_class_info)
  , NULLIF(''@examStatus'', '''')
  , NULLIF(''@orderComment'', '''')
  , ''@orderExamSetInfoValue''
  , ''@examOrderInfoValue''
  , ''@orderLabelInfoValue''
  , NULLIF(''@dataGenClass'', '''')
  , TO_TIMESTAMP(NULLIF(''@resultExamDate'', ''''), ''YYYYMMDDHH24MISS'') 
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
