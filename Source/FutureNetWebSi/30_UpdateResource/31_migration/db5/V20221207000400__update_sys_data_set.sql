DELETE FROM ntss.sys_data_set where sql_cd in (7406);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7406, 'UPDATE pat_exam_main pea1
 SET
  exam_result_info = 
	CASE
    ''@examResultInfo.itemCd'' 
    WHEN '''' THEN
    ''@examResultInfoValue''
ELSE	jsonb_set(exam_result_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_exam_main pea2, jsonb_array_elements(exam_result_info) WITH

ORDINALITY WHERE pea1.pat_id = pea2.pat_id AND value->>''item_cd'' = ''@examResultInfo.itemCd'' AND pea2.reg_order_class = ''@regOrderClass'' AND pea2.reg_exam_date = to_timestamp(''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss''))::text, ''result''::text], ''"@examResultInfo.result"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @item_cd != ''0''
	AND reg_order_class = ''@regOrderClass''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');

    
