delete from "sys_data_set" where "sql_cd" in (1601,1602,1701,1702,1703);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1601, 'select
  pat_id,

  medical_hst_info,

  in_out_visit_history_info,

  physical_info,

  is_del,

  up_date,

  reg_date,

  facility_cd,

  old_up_date_unique



from
  pat_unique


where
  pat_id = @patId

and
  is_del = ''0''


', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1602, 'insert into pat_unique (

  pat_id,

  medical_hst_info,

  in_out_visit_history_info,

  physical_info,

  is_del,

  up_date,

  reg_date,

  facility_cd,

  old_up_date_unique

)



VALUES

(

  @patId,

  ''@medicalHstInfoValue'',

  ''@inOutVisitHistoryInfoValue'',

  ''@physicalInfoValue'',

  ''0'',

  CURRENT_TIMESTAMP,

  CURRENT_TIMESTAMP,

  ''@facilityCd'',

  null

)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1701, 'select

  pat_id,

  medical_hst_info,

  in_out_visit_history_info,

  physical_info,

  is_del,

  up_date,

  reg_date,

  facility_cd,

  old_up_date_unique



from

  pat_unique



where

  pat_id = @patId

and

  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1702, 'update pat_unique set
	physical_info = ''[]''
where

  pat_id = @patId

and

  facility_cd = ''@facilityCd''

and

  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1703, 'update pat_unique set

  physical_info = case ''@physicalInfoFlg''

                  when '''' then ''@physicalInfoValue''

                  else physical_info || ''[{"ctl_no":"@physicalInfo.ctlNo", "exam_date":"@physicalInfo.examDate", "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":"@physicalInfo.breastDia", "chest_dia":"@physicalInfo.chestDia", "ctr":"@physicalInfo.ctr", "dw":"@physicalInfo.dw", "indicator_cd":"@physicalInfo.indicatorCd", "indicator_start_date":"@physicalInfo.indicatorStartDate", "memo":"@physicalInfo.memo", "pre_scale_upper":"@physicalInfo.preScaleUpper", "pre_scale_lower":"@physicalInfo.preScaleLower", "facility_cd": "@physicalInfo.facilityCd", "target_weight": "@physicalInfo.targetWeight"}]''::jsonb

                  end



where

  pat_id = @patId

and

  facility_cd = ''@facilityCd''

and

  is_del = ''0''

', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
