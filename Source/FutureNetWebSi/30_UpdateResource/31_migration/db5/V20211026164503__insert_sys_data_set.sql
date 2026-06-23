delete from "sys_data_set" where "sql_cd" in (6101,6102,6103,6201,6202);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6101, 'SELECT
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
    AND reg_exam_date = TO_TIMESTAMP(@regExamDate_Date, ''YYYY-MM-DD HH24:MI:SS'') 
    AND reg_order_class = @regOrderClass', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6102, 'INSERT INTO pat_exam_main (
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
      NULL ELSE to_number( ''@ordNo'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate'' 
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
      ''@resultExamDate'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    NULLIF ( ''@resultComment'', '''' ),
    ''@examResultInfoValue'',
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''9999999999999999'' ) 
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
      NULL ELSE to_number( ''@examPattern'', ''9999999999999999'' ) 
    END 
  )', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6103, 'UPDATE pat_exam_main 
SET result_exam_date = CASE
    ''@resultExamDate'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    up_date = CURRENT_TIMESTAMP 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    AND reg_order_class = ''@regOrderClass'' 
    AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6201, 'UPDATE pat_exam_main 
SET exam_result_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6202, 'UPDATE pat_exam_main 
SET exam_result_info = 
    CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN
      ''@examResultInfoValue''
    ELSE
      CASE WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' THEN
        exam_result_info || ''[{"com_cd":"@examResultInfo.comCd1, @examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"@examResultInfo.examClass", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'' :: jsonb 
      ELSE
        exam_result_info || ''[{"com_cd":"@examResultInfo.comCd1@examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"@examResultInfo.examClass", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'' :: jsonb 
      END
   END 
  WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
