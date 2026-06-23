DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" in (9605);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9605, 'UPDATE pat_main
SET infect_info = infect_info || cast((''[
                         {
                           "infect": "@infectInfo.infect",
                           "up_date": "'' || to_char(current_date, ''yyyymmdd'') || ''",
                           "exam_date": "'' || to_char(to_date(''@infectInfo.examDate_Date'', ''yyyymmdd''), ''yyyymmdd'') || ''",
                           "infection_cd": ''||@infectInfo.infectionCd||''
                         }
                       ]'') as text) :: jsonb
WHERE is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, null);
