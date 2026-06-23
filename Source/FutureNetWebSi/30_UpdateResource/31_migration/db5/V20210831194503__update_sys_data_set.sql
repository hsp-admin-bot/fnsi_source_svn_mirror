delete from "sys_data_set" where "sql_cd"  in (1201,1602,1603,1701,1703,3101,3102,3201,3202,3301,3302,3303);INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3303, 'update pat_obs_rec set
  obs_rec_info = case ''@obsRecInfoFlg''
                       when '''' then ''@obsRecInfoValue''
                       else json_build_object(''detail1'',NULLIF(''@obsRecInfo.detail1'',''''),''detail2'',NULLIF(''@obsRecInfo.detail2'',''''),''detail3'',NULLIF(''@obsRecInfo.detail3'',''''),''detail4'',NULLIF(''@obsRecInfo.detail4'',''''))
                     end,
  up_date = CURRENT_TIMESTAMP
where
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3302, 'insert into pat_obs_rec (
  pat_id,
  facility_cd,
  rec_date,
  up_cnt,
  kind_info,
  reg_staff_info,
  up_staff_info,
  obs_rec_info,
  bbs_ctl_no,
  ord_no,
  is_newest,
  is_del,
  fn_seq_id,
  reg_date,
  up_date
) values (
  @patId,
  ''@facilityCd'',
  CURRENT_TIMESTAMP,
  1,
  ''{}'',
  ''{}'',
  ''{}'',
  case ''@obsRecInfoFlg''
    when '''' then json_build_object(''detail1'',null,''detail2'',null,''detail3'',null,''detail4'',null)
    else json_build_object(''detail1'',NULLIF(''@obsRecInfo.detail1'',''''),''detail2'',NULLIF(''@obsRecInfo.detail2'',''''),''detail3'',NULLIF(''@obsRecInfo.detail3'',''''),''detail4'',NULLIF(''@obsRecInfo.detail4'',''''))
  end,
  null,
  null,
  0,
  0,
  null,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3301, 'SELECT
  obs_rec_no,
  pat_id,
  facility_cd,
  rec_date,
  up_cnt,
  kind_info,
  reg_staff_info,
  up_staff_info,
  obs_rec_info,
  bbs_ctl_no,
  ord_no,
  is_newest,
  is_del,
  fn_seq_id,
  reg_date,
  up_date 
FROM
  pat_obs_rec 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3202, 'update pat_unique set
  medical_hst_info = case ''@medicalHstInfoFlg''
                  when '''' then ''@medicalHstInfoValue''
                  else medical_hst_info || ''[{"memo":"@medicalHstInfo.memo", "ctl_no":"@nextCtlNo2", "die_date":"@medicalHstInfo.dieDate", "out_come":"@medicalHstInfo.outCome", "course_cd":"@medicalHstInfo.courseCd", "is_notice":"@medicalHstInfo.isNotice", "disease_cd":"@medicalHstInfo.diseaseCd", "disp_order":"@medicalHstInfo.dispOrder", "disease_day":"@medicalHstInfo.diseaseDay", "facility_cd":"@medicalHstInfo.facilityCd", "disease_date":"@medicalHstInfo.diseaseDate", "disease_year":"@medicalHstInfo.diseaseYear", "is_diagnosed":"@medicalHstInfo.isDiagnosed", "diagnosis_day":"@medicalHstInfo.diagnosisDay", "disease_month":"@medicalHstInfo.diseaseMonth", "out_come_date":"@medicalHstInfo.outComeDate", "course_is_free":"@medicalHstInfo.courseIsFree", "diagnosis_date":"@medicalHstInfo.diagnosisDate", "diagnosis_year":"@medicalHstInfo.diagnosisYear", "diagnosis_month":"@medicalHstInfo.diagnosisMonth", "is_main_disease":"@medicalHstInfo.isMainDisease", "diagnostician_cd":"@medicalHstInfo.diagnosticianCd", "diagnosis_facility_cd":"@medicalHstInfo.diagnosisFacilityCd", "diagnostician_is_free":"@medicalHstInfo.diagnosticianIsFree", "is_confirmation_biopsy":"@medicalHstInfo.isConfirmationBiopsy", "diagnosis_facility_is_free":"@medicalHstInfo.diagnosisFacilityIsFree", "is_dialysis_underlying_disease":"@medicalHstInfo.isDialysisUnderlyingDisease"}]''::jsonb
                  end,
  physical_info = case ''@physicalInfoFlg''
                  when '''' then ''@physicalInfoValue''
                  else physical_info || ''[{"ctl_no":"@nextCtlNo1", "exam_date":"@physicalInfo.examDate", "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":"@physicalInfo.breastDia", "chest_dia":"@physicalInfo.chestDia", "ctr":"@physicalInfo.ctr", "dw":"@physicalInfo.dw", "indicator_cd":"@physicalInfo.indicatorCd", "indicator_start_date":"@physicalInfo.indicatorStartDate", "memo":"@physicalInfo.memo", "pre_scale_upper":"@physicalInfo.preScaleUpper", "pre_scale_lower":"@physicalInfo.preScaleLower", "facility_cd": "@physicalInfo.facilityCd", "target_weight": "@physicalInfo.targetWeight"}]''::jsonb
                  end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3201, 'update pat_unique set
  physical_info = ''[]'',
  medical_hst_info = ''[]''
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3102, 'UPDATE pat_main 
SET pat_memo_info =
CASE
    ''@patMemoInfoFlg'' 
    WHEN '''' THEN
    ''@patMemoInfoValue'' ELSE pat_memo_info || ''[{"ctl_no":"@nextCtlNo1", "title":"@patMemoInfo.title", "content":"@patMemoInfo.content"}]'' :: jsonb 
  END,
  charge_staff_info =
CASE
    ''@chargeStaffInfoFlg'' 
    WHEN '''' THEN
    ''@chargeStaffInfoValue'' ELSE charge_staff_info || ''[{"ctl_no":"@nextCtlNo2", "disp_order":"@chargeStaffInfo.dispOrder", "staff_cd":"@chargeStaffInfo.staffCd", "is_main":"@chargeStaffInfo.isMain", "is_charge":"@chargeStaffInfo.isCharge", "is_puncture":"@chargeStaffInfo.isPuncture"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3101, 'UPDATE pat_main 
SET pat_memo_info = ''[]'', 
  charge_staff_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1703, 'update pat_unique set
  physical_info = case ''@physicalInfoFlg''
                  when '''' then ''@physicalInfoValue''
                  else physical_info || ''[{"ctl_no":"@nextCtlNo1", "exam_date":"@physicalInfo.examDate", "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":"@physicalInfo.breastDia", "chest_dia":"@physicalInfo.chestDia", "ctr":"@physicalInfo.ctr", "dw":"@physicalInfo.dw", "indicator_cd":"@physicalInfo.indicatorCd", "indicator_start_date":"@physicalInfo.indicatorStartDate", "memo":"@physicalInfo.memo", "pre_scale_upper":"@physicalInfo.preScaleUpper", "pre_scale_lower":"@physicalInfo.preScaleLower", "facility_cd": "@physicalInfo.facilityCd", "target_weight": "@physicalInfo.targetWeight"}]''::jsonb
                  end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''

', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1701, 'select
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  is_del,
  up_date,
  reg_date,
  facility_cd,
  old_up_date_unique,
  (
  SELECT
    (
      COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
    ) AS ctl_no 
  FROM
    pat_unique tbl1
    CROSS JOIN LATERAL json_array_elements ( tbl1.physical_info :: json ) RESULT 
  WHERE
    tbl1.pat_id = @patId 
  ) AS next_ctl_no_1,
  (
  SELECT
    (
      COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
    ) AS ctl_no 
  FROM
    pat_unique tbl2
    CROSS JOIN LATERAL json_array_elements ( tbl2.medical_hst_info :: json ) RESULT 
  WHERE
    tbl2.pat_id = @patId 
  ) AS next_ctl_no_2
from
  pat_unique
where
  pat_id = @patId
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1603, 'update pat_unique set
	physical_info = ''[]''
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
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
  ''[]'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  ''@facilityCd'',
  null
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1201, 'select
  pat_id,
  facility_cd,
  is_same,
  is_implant,
  is_infect,
  is_diabetes,
  is_blood_suger_exam,
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date,
  pat_memo_info,
  addition_info,
  charge_staff_info,
  pat_group_info,
  taboo_allergy_info,
  infect_info,
  implant_info,
  tare_info,
  off_water_info,
  device_set_info,
  acceptance_status_info,
  is_del,
  up_date,
  reg_date,
  is_wheel_chair,
  medical_care_info,
  sch_ext_end_date,
  sch_ext_status,
  card_idm,
  old_up_date,
  host_notification_info,
  (
  SELECT
    (
      COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
    ) AS ctl_no 
  FROM
    pat_main tbl1
    CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
  WHERE
    tbl1.pat_id = @patId 
  ) AS next_ctl_no_1,
  (
  SELECT
    (
      COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
    ) AS ctl_no 
  FROM
    pat_main tbl2
    CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
  WHERE
    tbl2.pat_id = @patId 
  ) AS next_ctl_no_2
from
  pat_main
where
  is_del = ''0''
and
  pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
