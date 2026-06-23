delete from "sys_data_set" where "sql_cd" in (9604,9603,9602,9601);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9604, 'WITH exam_item_nec AS ( 
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
--  AND NULLIF(''@examResultInfo.result'', '''') IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの検査結果(検査結果情報更新)', '2021-12-17 16:00:00', '2021-12-17 16:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9603, 'UPDATE pat_exam_main 
SET up_date = CURRENT_TIMESTAMP 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの検査結果(UPDATE)', '2021-12-17 16:00:00', '2021-12-17 16:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9602, 'WITH iniClassInfo AS ( 
  SELECT
    ''1'' AS ntss_order_class
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS nec_order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_EXAMSND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDERCLASS_CODE_BEFORE'' 
  UNION 
  SELECT
    ''2'' AS ntss_order_class
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS nec_order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_EXAMSND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDERCLASS_CODE_AFTER''
) 
, orderClassInfo AS ( 
  SELECT
    ntss_order_class AS reg_order_class 
  FROM
    iniClassInfo 
  WHERE
    nec_order_class <> ''NULL'' 
    AND nec_order_class = ''@regOrderClass'' 
  UNION 
  SELECT
    ''0'' AS reg_order_class 
  ORDER BY
    reg_order_class DESC 
  LIMIT
    1
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
  , (SELECT reg_order_class FROM orderClassInfo) 
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
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの検査結果(INSERT)', '2021-12-17 16:00:00', '2021-12-17 16:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9601, 'WITH iniClassInfo AS ( 
  SELECT
    ''1'' AS ntss_order_class
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS nec_order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_EXAMSND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDERCLASS_CODE_BEFORE'' 
  UNION 
  SELECT
    ''2'' AS ntss_order_class
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS nec_order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_EXAMSND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDERCLASS_CODE_AFTER''
) 
, orderClassInfo AS ( 
  SELECT
    ntss_order_class AS reg_order_class 
  FROM
    iniClassInfo 
  WHERE
    nec_order_class <> ''NULL'' 
    AND nec_order_class = @regOrderClass 
  UNION 
  SELECT
    ''0'' AS reg_order_class 
  ORDER BY
    reg_order_class DESC 
  LIMIT
    1
) 
SELECT
  exam_main_cd
  , pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , to_char(reg_exam_date, ''yyyy-MM-dd hh24:mi:ss'') AS reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , to_char(result_exam_date, ''yyyy-MM-dd hh24:mi:ss'') AS result_exam_date
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
  , to_char(exam_from, ''yyyymmddhh24miss'') AS exam_from
  , to_char(exam_to, ''yyyymmddhh24miss'') AS exam_to
  , exam_pattern
  , ( 
    SELECT
      ( 
        COALESCE( 
          MAX( 
            TO_NUMBER( 
              COALESCE(NULLIF(RESULT ->> ''disp_order'', ''''), ''0'')
              , ''99999''
            )
          ) 
          , 0
        ) + 1
      ) AS next_disp_order 
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
  AND reg_exam_date = to_timestamp(@regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'') 
  AND reg_order_class = (SELECT reg_order_class FROM orderClassInfo)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの検査結果(SELECT)', '2021-12-17 16:00:00', '2021-12-17 16:00:00', NULL);
