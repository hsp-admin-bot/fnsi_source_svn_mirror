DELETE FROM sys_data_set WHERE sql_cd in(7401,7405,7406);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7401, 'SELECT
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
		  CROSS JOIN LATERAL json_array_elements (exam_result_info :: json ) info 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = @facilityCd
    AND reg_exam_date = to_timestamp(@regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'')
    AND info ->> ''item_cd'' = @examResultInfo.itemCd :: text
    AND reg_order_class = @regOrderClass', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7405, 'UPDATE pat_exam_main 
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
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd
	AND @item_cd = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(検査結果情報更新)', '2020-05-25 18:21:40.841',CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7406, 'SELECT
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
    AND reg_order_class = @regOrderClass
		AND exam_result_info = ''[]''
		LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841',CURRENT_TIMESTAMP, NULL);
