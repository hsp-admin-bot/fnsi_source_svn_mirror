delete from ntss.sys_data_set where sql_cd = '7405';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7405, 'with examData as (select exam_class as examClass from mst_exam_item where exam_item_cd = ''@examResultInfo.itemCd'')
UPDATE pat_exam_main 
SET exam_result_info = 
    CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN
      ''@examResultInfoValue''
    ELSE
      CASE WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' THEN
        exam_result_info || (''[{"com_cd":"@examResultInfo.comCd1, @examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"''||examData.examClass||''", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'') :: jsonb 
      ELSE
        exam_result_info || (''[{"com_cd":"@examResultInfo.comCd1@examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"''||examData.examClass||''", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'') :: jsonb 
      END
   END 
   from examData
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd
	AND @item_cd = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の検査結果(検査結果情報更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
