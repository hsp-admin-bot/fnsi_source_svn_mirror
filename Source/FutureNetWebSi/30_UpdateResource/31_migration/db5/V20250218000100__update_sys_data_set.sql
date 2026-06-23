DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 240;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (240, 'SELECT
  COUNT(*) AS total_confirmed_count,
  COUNT(CASE WHEN rst_in_out_class = ''0'' THEN 1 END) AS confirmed_ambulatory_count,
  COUNT(CASE WHEN rst_in_out_class = ''1'' THEN 1 END) AS confirmed_inpatient_count,
  @ordNo as ord_no
FROM
  ord_main
WHERE
  treat_date BETWEEN to_char(date_trunc(''day'', cast(@fromDate AS timestamp)), ''YYYYMMDD'')
  AND to_char(date_trunc(''day'', cast(@toDate AS timestamp)), ''YYYYMMDD'')
  AND rst_dialysis_state = ''6''
  AND facility_cd = @facilityCd
  AND is_del = ''0''
  AND pat_id is not null
', 2, '[{"preview": "0", "can_calc": "0", "data_code": "confirmed_inpatient_count", "data_name": "確定実績数(入院)", "data_type": "string", "conv_table": [], "data_class": "スケジュール情報", "field_name": "confirmed_inpatient_count", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "confirmed_ambulatory_count", "data_name": "確定実績数(外来)", "data_type": "string", "conv_table": [], "data_class": "スケジュール情報", "field_name": "confirmed_ambulatory_count", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_confirmed_count", "data_name": "確定実績数(総数)", "data_type": "string", "conv_table": [], "data_class": "スケジュール情報", "field_name": "total_confirmed_count", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績：実績情報　@facilityCd  @fromdate  @todate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
