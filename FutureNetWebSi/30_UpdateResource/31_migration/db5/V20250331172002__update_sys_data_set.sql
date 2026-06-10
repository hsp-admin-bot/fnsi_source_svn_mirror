DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-600701,9201,9202,9206);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600701, 'WITH comment_value AS (
  SELECT
    CASE COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'')
      WHEN ''C2'' THEN @regOrderClass2
      ELSE @regOrderClass1
      END comment_value
    , 0 AS order_num
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAMIN_RECV''
    AND info ->> ''key2'' = ''COMMENT_POSITION''
  UNION
  SELECT
    @regOrderClass1 AS comment_value
    , 1 AS order_num
  ORDER BY order_num ASC
  LIMIT 1
)
SELECT
order_class.order_class AS order_class
FROM
(
  SELECT
    CASE COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'')
      WHEN ''1'' THEN ''1''
      WHEN ''2'' THEN ''2''
      ELSE ''0''
      END AS order_class
    , 0 AS order
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_FNW''
    AND info ->> ''key2'' = (SELECT comment_value FROM comment_value)
  UNION
  SELECT
    ''0'' AS order_class
    , 1 AS order
) AS order_class
ORDER BY order_class.order ASC
LIMIT 1
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果前後区分', '2025-03-18 11:34:59.051', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9201, 'SELECT
    exam_main_cd,
    pat_id,
    facility_cd,
    ord_no,
    fn_pat_id,
    to_char( reg_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS reg_exam_date,
    reg_order_class,
    exam_status,
    order_comment,
    order_exam_set_info,
    exam_order_info,
    order_label_info,
    data_gen_class,
    to_char( result_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS result_exam_date,
    result_comment,
    exam_result_info,
    cop_order_no1,
    cop_order_no2,
    is_lock,
    ind_user_id,
    is_del,
    reg_date,
    reg_staff,
    up_date,
    up_staff,
    is_order,
    exam_week,
    to_char( exam_from, ''yyyymmddhh24miss'' ) AS exam_from,
    to_char( exam_to, ''yyyymmddhh24miss'' ) AS exam_to,
    exam_pattern,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''disp_order'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS next_disp_order 
    FROM
        pat_exam_main exam
        CROSS JOIN LATERAL json_array_elements ( exam.exam_result_info :: json ) RESULT 
    WHERE
        exam.exam_main_cd = pat_exam_main.exam_main_cd 
    ) AS next_disp_order 
FROM
    pat_exam_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = @facilityCd
    AND reg_exam_date = to_timestamp(@regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'')
    AND reg_order_class = @orderClass', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(SELECT)', '2021-11-30 18:21:40.000', CURRENT_TIMESTAMP, '[{"sql_cd": -600701, "field_name": "order_class", "replace_var": "@orderClass"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9202, 'INSERT 
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
    ELSE to_number(''@ordNo'', ''999999999'') 
    END
  , NULLIF(''@fnPatId'', '''')
  , CASE ''@regExamDate_Date'' 
    WHEN '''' THEN CURRENT_TIMESTAMP 
    ELSE to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , ''@orderClass''
  , NULLIF(''@examStatus'', '''')
  , NULLIF(''@orderComment'', '''')
  , ''@orderExamSetInfoValue''
  , ''@examOrderInfoValue''
  , ''@orderLabelInfoValue''
  , NULLIF(''@dataGenClass'', '''')
  , CASE ''@resultExamDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULLIF(''@resultComment'', '''')
  , ''@examResultInfoValue''
  , CASE ''@copOrderNo1'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@copOrderNo1'', ''999999999'') 
    END
  , CASE ''@copOrderNo2'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@copOrderNo2'', ''999999999'') 
    END
  , NULLIF(''@isLock'', '''')
  , CASE ''@indUserId'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@indUserId'', ''999999999'') 
    END
  , ''0''
  , CURRENT_TIMESTAMP
  , CASE ''@regStaff'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@regStaff'', ''999999999'') 
    END
  , CURRENT_TIMESTAMP
  , CASE ''@upStaff'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@upStaff'', ''999999999'') 
    END
  , NULLIF(''@isOrder'', '''')
  , CASE ''@examWeek'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@examWeek'', ''999999999'') 
    END
  , CASE ''@examFrom'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@examFrom'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examTo'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@examTo'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examPattern'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@examPattern'', ''999999999'') 
    END
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(INSERT)', '2021-11-30 18:21:40.000', CURRENT_TIMESTAMP, '[{"sql_cd": -600701, "field_name": "order_class", "replace_var": "@orderClass"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9206, 'DELETE FROM pat_exam_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND reg_order_class = ''@orderClass''
    AND jsonb_array_length(exam_result_info) = 0
    AND reg_date = up_date
    AND reg_date BETWEEN (CURRENT_TIMESTAMP + ''-3 min'') AND (CURRENT_TIMESTAMP + ''1 min'')
    AND up_date BETWEEN (CURRENT_TIMESTAMP + ''-3 min'') AND (CURRENT_TIMESTAMP + ''1 min'')', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2021-11-30 18:21:40.000', CURRENT_TIMESTAMP, '[{"sql_cd": -600701, "field_name": "order_class", "replace_var": "@orderClass"}]'::jsonb);
