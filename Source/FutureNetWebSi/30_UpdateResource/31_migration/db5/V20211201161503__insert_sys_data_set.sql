delete from "sys_data_set" where "sql_cd" in (7402,9201,9202,9203,9204,9205,9206);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9206, 'WITH order_class_def AS ( 
  SELECT
    CASE info ->> ''key2'' 
      WHEN ''ORDERCLASS_61'' THEN ''1'' 
      WHEN ''ORDERCLASS_62'' THEN ''2'' 
      ELSE ''0'' 
      END reg_order_class
    , LPAD( COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') , 2, ''0'') AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND ( info ->> ''key2'' = ''ORDERCLASS_61'' OR info ->> ''key2'' = ''ORDERCLASS_62'')
) 
, order_class_nec AS ( 
  SELECT
    CASE 
      WHEN COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''2'' 
      THEN ''@regOrderClass2'' 
      ELSE ''@regOrderClass1'' 
      END AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS info 
  WHERE
    facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND (info ->> ''key2'' = ''ORDERCLASS_POSITION'')
) 
, reg_order_class_conv AS (SELECT
  nec.order_class_value
  , COALESCE(NULLIF(def.reg_order_class, ''''), ''0'') AS reg_order_class 
FROM
  order_class_nec AS nec 
  LEFT OUTER JOIN order_class_def AS def 
    ON nec.order_class_value = def.order_class_value
) 
DELETE FROM pat_exam_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND reg_order_class = (SELECT reg_order_class FROM reg_order_class_conv)
    AND jsonb_array_length(exam_result_info) = 0
    AND reg_date = up_date
    AND reg_date BETWEEN (CURRENT_TIMESTAMP + ''-3 min'') AND (CURRENT_TIMESTAMP + ''1 min'')
    AND up_date BETWEEN (CURRENT_TIMESTAMP + ''-3 min'') AND (CURRENT_TIMESTAMP + ''1 min'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9205, 'WITH exam_item_nec AS ( 
  SELECT
    NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF(''@examResultInfo.type'', '''') AS type
    , NULLIF(''@examResultInfo.unit'', '''') AS unit
    , NULLIF(''@examResultInfo.lower'', '''') AS lower
    , NULLIF(''@examResultInfo.upper'', '''') AS upper
    , NULLIF( 
      ( 
        CASE 
          WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' 
          THEN ''@examResultInfo.comCd1'' || '','' || ''@examResultInfo.comCd2'' 
          ELSE ''@examResultInfo.comCd1'' || ''@examResultInfo.comCd2'' 
          END
      ) , '''') AS com_cd
    , NULLIF(''@examResultInfo.result'', '''') AS result
    , NULLIF(''@examResultInfo.itemCd'', '''') AS item_cd
    , NULLIF(''@examResultInfo.freememo'', '''') AS freememo
    , NULLIF(''@examResultInfo.itemName'', '''') AS item_name
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.examClass'', '''') AS exam_class
    , NULLIF(''@examResultInfo.resultDate_Date'', '''') AS result_date
) 
, exam_item_ntss AS ( 
  SELECT
    A.exam_item_cd
    , A.exam_item_name
    , A.data_type
    , A.unit
    , A.exam_class
    , A.input_upper
    , A.input_lower
    , A.in_hospital_cd1 AS hospital_cd1
    , A.in_hospital_cd2 AS hospital_cd2
    , A.in_hospital_cd3 AS hospital_cd3 
  FROM
    mst_exam_item A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_exam_item''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.exam_item_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, exam_result_nec AS ( 
  SELECT
    nec.hl 
    , COALESCE(nec.type, ntss.data_type) AS type
    , COALESCE(nec.unit, ntss.unit) AS unit
    , COALESCE(nec.lower, ntss.input_lower) AS lower
    , COALESCE(nec.upper, ntss.input_upper) AS upper
    , nec.com_cd
    , nec.result AS result
    , COALESCE((ntss.exam_item_cd ::TEXT), nec.item_cd) AS item_cd
    , nec.freememo
    , COALESCE(nec.item_name, ntss.exam_item_name) AS item_name
    , nec.disp_order
    , COALESCE(COALESCE(nec.exam_class, ntss.exam_class), ''0'') AS exam_class
    , nec.result_date 
  FROM
    exam_item_nec AS nec 
    LEFT OUTER JOIN exam_item_ntss AS ntss ON ntss.hospital_cd1 = nec.item_cd
) 
, exam_result_exists AS ( 
  SELECT
    count(1) AS data_count 
  FROM
    pat_exam_main 
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info 
    INNER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd'' 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd
) 
, exam_result AS ( 
  -- JOSNにNECのデータが有りの場合、UPDATE
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN nec.item_cd IS NULL 
            THEN info ::JSON 
          ELSE json_build_object( 
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          ) 
          END
      )
    ) AS exam_result_info_new 
  FROM
    pat_exam_main 
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info 
    LEFT OUTER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd'' 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd
    AND (SELECT data_count FROM exam_result_exists) > 0

  UNION ALL
  -- JOSNにNECのデータが無しの場合、INSERT
  SELECT
    CAST( 
      exam_result_info || ( 
        SELECT
          json_build_object( 
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          ) 
        FROM
          exam_result_nec AS nec
      ) ::JSONB AS JSON
    ) AS exam_result_info_new 
  FROM
    pat_exam_main 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd 
    AND (SELECT data_count FROM exam_result_exists) = 0
) 
UPDATE pat_exam_main 
SET
  exam_result_info = CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN ''@examResultInfoValue'' 
    ELSE (SELECT exam_result_info_new FROM exam_result WHERE exam_result_info_new is not null) ::JSONB 
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
  AND exam_main_cd = @examMainCd 
  AND NULLIF(''@examResultInfo.result'', '''') IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9204, 'UPDATE pat_exam_main 
SET exam_result_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(検査結果情報クリア)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9203, 'UPDATE pat_exam_main 
SET cop_order_no1 = CASE ''@copOrderNo1'' 
    WHEN '''' THEN cop_order_no1 
    ELSE to_number(''@copOrderNo1'', ''999999999'') 
    END,
    up_date = CURRENT_TIMESTAMP 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(UPDATE)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9202, 'WITH order_class_def AS ( 
  SELECT
    CASE info ->> ''key2'' 
      WHEN ''ORDERCLASS_61'' THEN ''1'' 
      WHEN ''ORDERCLASS_62'' THEN ''2'' 
      ELSE ''0'' 
      END reg_order_class
    , LPAD( COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') , 2, ''0'') AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND ( info ->> ''key2'' = ''ORDERCLASS_61'' OR info ->> ''key2'' = ''ORDERCLASS_62'')
) 
, order_class_nec AS ( 
  SELECT
    CASE 
      WHEN COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''2'' 
      THEN ''@regOrderClass2'' 
      ELSE ''@regOrderClass1'' 
      END AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS info 
  WHERE
    facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND (info ->> ''key2'' = ''ORDERCLASS_POSITION'')
) 
, reg_order_class_conv AS (SELECT
  nec.order_class_value
  , COALESCE(NULLIF(def.reg_order_class, ''''), ''0'') AS reg_order_class 
FROM
  order_class_nec AS nec 
  LEFT OUTER JOIN order_class_def AS def 
    ON nec.order_class_value = def.order_class_value
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
    ELSE to_number(''@ordNo'', ''999999999'') 
    END
  , NULLIF(''@fnPatId'', '''')
  , CASE ''@regExamDate_Date'' 
    WHEN '''' THEN CURRENT_TIMESTAMP 
    ELSE to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , (SELECT reg_order_class FROM reg_order_class_conv) 
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
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(INSERT)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9201, 'WITH order_class_def AS ( 
  SELECT
    CASE info ->> ''key2'' 
      WHEN ''ORDERCLASS_61'' THEN ''1'' 
      WHEN ''ORDERCLASS_62'' THEN ''2'' 
      ELSE ''0'' 
      END reg_order_class
    , LPAD( COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') , 2, ''0'') AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND ( info ->> ''key2'' = ''ORDERCLASS_61'' OR info ->> ''key2'' = ''ORDERCLASS_62'')
) 
, order_class_nec AS ( 
  SELECT
    CASE 
      WHEN COALESCE( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''2'' 
      THEN @regOrderClass2 
      ELSE @regOrderClass1 
      END AS order_class_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''NEC'' 
    AND (info ->> ''key2'' = ''ORDERCLASS_POSITION'')
) 
, reg_order_class_conv AS (SELECT
  nec.order_class_value
  , COALESCE(NULLIF(def.reg_order_class, ''''), ''0'') AS reg_order_class 
FROM
  order_class_nec AS nec 
  LEFT OUTER JOIN order_class_def AS def 
    ON nec.order_class_value = def.order_class_value
) 
SELECT
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
    AND reg_order_class = (SELECT reg_order_class FROM reg_order_class_conv)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(SELECT)', '2021-11-30 18:21:40', '2021-11-30 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7402, 'INSERT INTO pat_exam_main (
  pat_id,
  facility_cd,
  ord_no,
  fn_pat_id,
  reg_exam_date,
  reg_order_class,
  exam_status,
  order_comment,
  order_exam_set_info,
  exam_order_info,
  order_label_info,
  data_gen_class,
  result_exam_date,
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
  exam_from,
  exam_to,
  exam_pattern 
)
VALUES
  (
    @patId,
    ''@facilityCd'',
  CASE
      ''@ordNo'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@ordNo'', ''999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate_Date'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
  CASE
      ''@regOrderClass'' 
      WHEN '''' THEN
      NULL ELSE''@regOrderClass'' 
      END,
    NULLIF ( ''@examStatus'', '''' ),
    NULLIF ( ''@orderComment'', '''' ),
    ''@orderExamSetInfoValue'',
    ''@examOrderInfoValue'',
    ''@orderLabelInfoValue'',
    NULLIF ( ''@dataGenClass'', '''' ),
  CASE
      ''@resultExamDate_Date'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    NULLIF ( ''@resultComment'', '''' ),
    ''@examResultInfoValue'',
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''999999999'' ) 
    END,
  CASE
      ''@examFrom'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examTo'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examPattern'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examPattern'', ''999999999'' ) 
    END 
  )', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(INSERT)', '2020-05-25 18:21:40.841', '2021-11-30 18:21:40', NULL);
