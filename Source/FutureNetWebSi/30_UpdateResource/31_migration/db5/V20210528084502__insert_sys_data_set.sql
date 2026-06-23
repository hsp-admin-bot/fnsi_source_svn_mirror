DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1101;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1101, 'select

	pat_id,

	fn_pat_id,

	hosp_pat_id,

	nkk_pat_id,

	facility_cd,

	personal_info_decrypt(pat_last_name) as pat_last_name,

	personal_info_decrypt(pat_first_name) as pat_first_name,

	personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,

	personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,

	personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,

	personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,

	personal_info_decrypt(pat_birth_name) as pat_birth_name,

	personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,

	personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,

	pat_birthday,

	pat_sex,

	nationality,

	pat_blood_type_abo,

	pat_blood_type_rh,

	pat_blood_type_serovar,

	in_out_class,

	is_die,

	die_cd,

	die_date,

	dial_diff_com_info,

	severity_cd,

	transport_cd,

	personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,

	personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,

	personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,

	insurance_info,

	is_del,

	up_date,

	reg_date,

	primary_disease_cd,

	remote_monitor_service,

	personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,

	personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw

from

  pat_personal_main

where

  is_del = ''0''

and

  hosp_pat_id = @hospPatId

and

  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1102;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  pat_last_name,
  pat_first_name,
  pat_last_name_kana,
  pat_first_name_kana,
  pat_last_name_alpha,
  pat_first_name_alpha,
  pat_birth_name,
  pat_birth_name_kana,
  pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  pat_contact_info,
  other_contact_info,
  vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  remote_monitor_user_id,
  remote_monitor_user_pw
) values (
  NULLIF(''@fnPatId'',''''),
  NULLIF(''@hospPatId'',''''),
  NULLIF(''@nkkPatId'',''''),
  NULLIF(''@facilityCd'',''''),
  personal_info_encrypt(''@patLastName''),
  personal_info_encrypt(''@patFirstName''),
  personal_info_encrypt(''@patLastNmKana''),
  personal_info_encrypt(''@patFirstNmKana''),
  NULLIF(''@patLastNmAlpha'',''''),
  NULLIF(''@patFirstNmAlpha'',''''),
  NULLIF(''@patBirthName'',''''),
  NULLIF(''@patBirthNmKana'',''''),
  NULLIF(''@patBirthNmAlpha'',''''),
  NULLIF(''@patBirthday'',''''),
  case ''@patSex''
    when '''' then null
    else to_number(''@patSex'',''9999999999999999'')
  end,
  NULLIF(''@nationality'',''''),
  case ''@patBloodTypeAbo''
    when '''' then null
    else to_number(''@patBloodTypeAbo'',''9999999999999999'')
  end,
  case ''@patBloodTypeRh''
    when '''' then null
    else to_number(''@patBloodTypeRh'',''9999999999999999'')
  end,
  case ''@patBloodTypeSerovar''
    when '''' then null
    else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
  end,
  case ''@inOutClass''
    when '''' then null
    else to_number(''@inOutClass'',''9999999999999999'')
  end,
  NULLIF(''@isDie'',''''),
  case ''@dieCd''
    when '''' then null
    else to_number(''@dieCd'',''99999999999999999999999999999999'')
  end,
  case ''@dieDate_Date''
    when '''' then null
    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''@dialDiffComInfoValue'',
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(''@patContactInfo.address'',''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
  end,
  ''@otherContactInfoValue'',
  ''@vendorContactInfoValue'',
  ''@insuranceInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  case ''@primaryDiseaseCd''
    when '''' then null
    else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
  end,
  case ''@remoteMonitorService''
    when '''' then null
    else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@remoteMonitorUserId'',''''),
  NULLIF(''@remoteMonitorUserPw'','''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1103;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'update pat_personal_main set
  fn_pat_id = NULLIF(''@fnPatId'',''''),
  hosp_pat_id = NULLIF(''@hospPatId'',''''),
  nkk_pat_id = NULLIF(''@nkkPatId'',''''),
  facility_cd = NULLIF(''@facilityCd'',''''),
  pat_last_name = personal_info_encrypt(''@patLastName''),
  pat_first_name = personal_info_encrypt(''@patFirstName''),
  pat_last_name_kana = personal_info_encrypt(''@patLastNmKana''),
  pat_first_name_kana = personal_info_encrypt(''@patFirstNmKana''),
  pat_last_name_alpha = NULLIF(''@patLastNmAlpha'',''''),
  pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'',''''),
  pat_birth_name = NULLIF(''@patBirthName'',''''),
  pat_birth_name_kana = NULLIF(''@patBirthNmKana'',''''),
  pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'',''''),
  pat_birthday = NULLIF(''@patBirthday'',''''),
  pat_sex = case ''@patSex''
              when '''' then null
              else to_number(''@patSex'',''9999999999999999'')
            end,
  nationality = NULLIF(''@nationality'',''''),
  pat_blood_type_abo = case ''@patBloodTypeAbo''
                         when '''' then null
                         else to_number(''@patBloodTypeAbo'',''9999999999999999'')
                       end,
  pat_blood_type_rh = case ''@patBloodTypeRh''
                        when '''' then null
                        else to_number(''@patBloodTypeRh'',''9999999999999999'')
                      end,
  pat_blood_type_serovar = case ''@patBloodTypeSerovar''
                             when '''' then null
                             else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
                           end,
  in_out_class = case ''@inOutClass''
                   when '''' then null
                   else to_number(''@inOutClass'',''9999999999999999'')
                 end,
  is_die = NULLIF(''@isDie'',''''),
  die_cd = case ''@dieCd''
             when '''' then null
             else to_number(''@dieCd'',''99999999999999999999999999999999'')
           end,
  die_date = case ''@dieDate_Date''
               when '''' then null
               else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
             end,
  dial_diff_com_info = ''@dialDiffComInfoValue'',
  severity_cd = case ''@severityCd''
                  when '''' then null
                  else to_number(''@severityCd'',''99999999999999999999999999999999'')
                end,
  transport_cd = case ''@transportCd''
                   when '''' then null
                   else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  pat_contact_info = case ''@patContactInfoFlg''
                       when '''' then ''@patContactInfoValue''
                       else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(''@patContactInfo.address'',''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
                     end,
  other_contact_info = ''@otherContactInfoValue'',
  vendor_contact_info = ''@vendorContactInfoValue'',
  insurance_info = ''@insuranceInfoValue'',
  reg_date = ''@regDate'',
  up_date = CURRENT_TIMESTAMP,
  primary_disease_cd = case ''@primaryDiseaseCd''
                         when '''' then null
                         else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
                       end,
  remote_monitor_service = case ''@remoteMonitorService''
                             when '''' then null
                             else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
                           end,
  remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'',''''),
  remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'','''')
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and
  facility_cd = ''@facilityCd''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1104;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1104, 'delete from pat_personal_main where facility_cd = ''@facilityCd'' and hosp_pat_id = ''@hospPatId'' and is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1201;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1201, 'select

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

  host_notification_info

from

  pat_main

where

  is_del = ''0''

and

  pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1202;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'insert into pat_main (
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
  host_notification_info
) values (
  @patId,
  ''@facilityCd'',
  NULLIF(''@isSame'',''''),
  NULLIF(''@isImplant'',''''),
  NULLIF(''@isInfect'',''''),
  NULLIF(''@isDiabetes'',''''),
  NULLIF(''@isBloodSugerExam'',''''),
  NULLIF(''@inOutCurrentState'',''''),
  NULLIF(''@inOutPlanState'',''''),
  case ''@inOutPlanDate_Date''
    when '''' then null
    else to_timestamp(''@inOutPlanDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''@patMemoInfoValue'',
  ''@additionInfoValue'',
  ''@chargeStaffInfoValue'',
  ''@patGroupInfoValue'',
  ''@tabooAllergyInfoValue'',
  ''@infectInfoValue'',
  ''@implantInfoValue'',
  ''@tareInfoValue'',
  ''@offWaterInfoValue'',
  ''@deviceSetInfoValue'',
  ''@acceptanceStatusInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@isWheelChair'',''''),
  case ''@medicalCareInfoFlg''
    when '''' then json_build_object(''main_course_cd'',null,''dialysis_course_cd'',null,''ward_cd'',null,''dialysis_count'',null,''purification_count'',null,''other_dialysis_count'',null,''facility_cd'',null,''dialysis_start_date'',null,''hospital_start_date'',null)
    else json_build_object(''main_course_cd'',NULLIF(''@medicalCareInfo.mainCourseCd'',''''),''dialysis_course_cd'',NULLIF(''@medicalCareInfo.dialysisCourseCd'',''''),''ward_cd'',NULLIF(''@medicalCareInfo.wardCd'',''''),''dialysis_count'',NULLIF(''@medicalCareInfo.dialysisCount'',''''),''purification_count'',NULLIF(''@medicalCareInfo.purificationCount'',''''),''other_dialysis_count'',NULLIF(''@medicalCareInfo.otherDialysisCount'',''''),''facility_cd'',NULLIF(''@medicalCareInfo.facilityCd'',''''),''dialysis_start_date'',NULLIF(''@medicalCareInfo.dialysisStartDate'',''''),''hospital_start_date'',NULLIF(''@medicalCareInfo.hospitalStartDate'',''''))
  end,
  NULLIF(''@schExtEndDate'',''''),
  NULLIF(''@schExtStatus'',''''),
  NULLIF(''@cardIdm'',''''),
  case ''@oldUpDate_Date''
    when '''' then null
    else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  null
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1203;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'update pat_main set
  pat_id = @patId,
  facility_cd = ''@facilityCd'',
  is_same = NULLIF(''@isSame'',''''),
  is_implant = NULLIF(''@isImplant'',''''),
  is_infect = NULLIF(''@isInfect'',''''),
  is_diabetes = NULLIF(''@isDiabetes'',''''),
  is_blood_suger_exam = NULLIF(''@isBloodSugerExam'',''''),
  in_out_current_state = NULLIF(''@inOutCurrentState'',''''),
  in_out_plan_state = NULLIF(''@inOutPlanState'',''''),
  in_out_plan_date = case ''@inOutPlanDate_Date''
                       when '''' then null
                       else to_timestamp(''@inOutPlanDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
                     end,
  pat_memo_info = ''@patMemoInfoValue'',
  addition_info = ''@additionInfoValue'',
  charge_staff_info = ''@chargeStaffInfoValue'',
  pat_group_info = ''@patGroupInfoValue'',
  taboo_allergy_info = ''@tabooAllergyInfoValue'',
  infect_info = ''@infectInfoValue'',
  implant_info = ''@implantInfoValue'',
  tare_info = ''@tareInfoValue'',
  off_water_info = ''@offWaterInfoValue'',
  device_set_info = ''@deviceSetInfoValue'',
  acceptance_status_info = ''@acceptanceStatusInfoValue'',
  up_date = CURRENT_TIMESTAMP,
  is_wheel_chair = NULLIF(''@isWheelChair'',''''),
  medical_care_info = case ''@medicalCareInfoFlg''
                        when '''' then ''@medicalCareInfoValue''
                        else json_build_object(''main_course_cd'',NULLIF(''@medicalCareInfo.mainCourseCd'',''''),''dialysis_course_cd'',NULLIF(''@medicalCareInfo.dialysisCourseCd'',''''),''ward_cd'',NULLIF(''@medicalCareInfo.wardCd'',''''),''dialysis_count'',NULLIF(''@medicalCareInfo.dialysisCount'',''''),''purification_count'',NULLIF(''@medicalCareInfo.purificationCount'',''''),''other_dialysis_count'',NULLIF(''@medicalCareInfo.otherDialysisCount'',''''),''facility_cd'',NULLIF(''@medicalCareInfo.facilityCd'',''''),''dialysis_start_date'',NULLIF(''@medicalCareInfo.dialysisStartDate'',''''),''hospital_start_date'',NULLIF(''@medicalCareInfo.hospitalStartDate'',''''))
                      end,
  sch_ext_end_date = NULLIF(''@schExtEndDate'',''''),
  sch_ext_status = NULLIF(''@schExtStatus'',''''),
  card_idm = NULLIF(''@cardIdm'',''''),
  old_up_date = case ''@oldUpDate_Date''
                  when '''' then null
                  else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
                end
where
  is_del = ''0''
and
  pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1204;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1204, 'delete from pat_main where pat_id = @patId and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1301;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1301, 'select

	pat_id,

	facility_cd,

	ctl_no,

	fn_pat_id,

	insu_class,

	insu_name,

	insu_name_short,

	start_date,

	end_date,

	check_date,

	insu_info,

	insu_pub_info,

	insu_set_info,

	insu_self_info,

	is_selected,

	is_disp,

	is_del,

	coop_code,

	is_coop,

	reg_date,

	up_date,

	check_date,

	old_up_date

from

  pat_insurance

where

  pat_id = @patId

and

  facility_cd = @facilityCd

and

  is_del = ''0''

and

  ctl_no = @ctlNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1302;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1302, 'insert into pat_insurance (
  pat_id,
  facility_cd,
  ctl_no,
  fn_pat_id,
  insu_class,
  insu_name,
  insu_name_short,
  insu_info,
  insu_pub_info,
  insu_set_info,
  insu_self_info,
  is_selected,
  is_disp,
  is_del,
  coop_code,
  is_coop,
  reg_date,
  up_date,
  start_date,
  end_date,
  check_date,
  old_up_date
  )
VALUES
(
  @patId,
  ''@facilityCd'',
  case ''@ctlNo''
    when '''' then null
    else to_number(''@ctlNo'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@fnPatId'',''''),
  case ''@insuClass''
    when '''' then null
    else to_number(''@insuClass'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@insuName'',''''),
  NULLIF(''@insuNmShort'',''''),
  case ''@insuInfoFlg''
    when '''' then json_build_object(''insu_pat_name'',null,''insu_no'',null,''insu_kbn'',null,''insu_pat_mark'',null,''insu_pat_no'',null,''cki_class'',null,''kki_class'',null,''und_six'',null,''futan-g'',null,''futan-n'',null)
    else json_build_object(''insu_pat_name'',NULLIF(''@insuInfo.insuPatName'',''''),''insu_no'',NULLIF(''@insuInfo.insuNo'',''''),''insu_kbn'',NULLIF(''@insuInfo.insuKbn'',''''),''insu_pat_mark'',NULLIF(''@insuInfo.insuPatMark'',''''),''insu_pat_no'',NULLIF(''@insuInfo.insuPatNo'',''''),''cki_class'',NULLIF(''@insuInfo.ckiClass'',''''),''kki_class'',NULLIF(''@insuInfo.kkiClass'',''''),''und_six'',NULLIF(''@insuInfo.undSix'',''''),''futan-g'',NULLIF(''@insuInfo.futan-g'',''''),''futan-n'',NULLIF(''@insuInfo.futan-n'',''''))
  end,
  case ''@insuPubInfoFlg''
    when '''' then json_build_object(''insu_pub_name'',null,''insu_pub_no'',null,''insu_pub_pat_no'',null)
    else json_build_object(''insu_pub_name'',NULLIF(''@insuPubInfo.insuPubName'',''''),''insu_pub_no'',NULLIF(''@insuPubInfo.insuPubNo'',''''),''insu_pub_pat_no'',NULLIF(''@insuPubInfo.insuPubPatNo'',''''))
  end,
  case ''@insuSetInfoFlg''
    when '''' then json_build_object(''insu_cd'',null,''insu_pub1_cd'',null,''insu_pub2_cd'',null,''insu_pub3_cd'',null,''insu_pub4_cd'',null)
    else json_build_object(''insu_cd'',NULLIF(''@insuSetInfo.insuCd'',''''),''insu_pub1_cd'',NULLIF(''@insuSetInfo.insuPub1Cd'',''''),''insu_pub2_cd'',NULLIF(''@insuSetInfo.insuPub2Cd'',''''),''insu_pub3_cd'',NULLIF(''@insuSetInfo.insuPub3Cd'',''''),''insu_pub4_cd'',NULLIF(''@insuSetInfo.insuPub4Cd'',''''))
  end,
  null,
  NULLIF(''@isSelected'',''''),
  NULLIF(''@isDisp'',''''),
  ''0'',
  NULLIF(''@coopCode'',''''),
  NULLIF(''@isCoop'',''''),
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@startDate'',''''),
  NULLIF(''@endDate'',''''),
  NULLIF(''@checkDate'',''''),
  case ''@oldUpDate_Date''
    when '''' then null
    else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1303;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1303, 'update pat_insurance set
  pat_id = @patId,
  facility_cd = ''@facilityCd'',
  ctl_no = case ''@ctlNo''
             when '''' then null
             else to_number(''@ctlNo'',''99999999999999999999999999999999'')
           end,
  fn_pat_id = NULLIF(''@fnPatId'',''''),
  insu_class = case ''@insuClass''
                 when '''' then null
                 else to_number(''@insuClass'',''99999999999999999999999999999999'')
               end,
  insu_name = NULLIF(''@insuName'',''''),
  insu_name_short = NULLIF(''@insuNmShort'',''''),
  insu_info = case ''@insuInfoFlg''
                when '''' then ''@insuInfoValue''
                else json_build_object(''insu_pat_name'',NULLIF(''@insuInfo.insuPatName'',''''),''insu_no'',NULLIF(''@insuInfo.insuNo'',''''),''insu_kbn'',NULLIF(''@insuInfo.insuKbn'',''''),''insu_pat_mark'',NULLIF(''@insuInfo.insuPatMark'',''''),''insu_pat_no'',NULLIF(''@insuInfo.insuPatNo'',''''),''cki_class'',NULLIF(''@insuInfo.ckiClass'',''''),''kki_class'',NULLIF(''@insuInfo.kkiClass'',''''),''und_six'',NULLIF(''@insuInfo.undSix'',''''),''futan-g'',NULLIF(''@insuInfo.futan-g'',''''),''futan-n'',NULLIF(''@insuInfo.futan-n'',''''))
              end,
  insu_pub_info = case ''@insuPubInfoFlg''
                    when '''' then ''@insuPubInfoValue''
                    else json_build_object(''insu_pub_name'',NULLIF(''@insuPubInfo.insuPubName'',''''),''insu_pub_no'',NULLIF(''@insuPubInfo.insuPubNo'',''''),''insu_pub_pat_no'',NULLIF(''@insuPubInfo.insuPubPatNo'',''''))
                  end,
  insu_set_info = case ''@insuSetInfoFlg''
                    when '''' then ''@insuSetInfoValue''
                    else json_build_object(''insu_cd'',NULLIF(''@insuSetInfo.insuCd'',''''),''insu_pub1_cd'',NULLIF(''@insuSetInfo.insuPub1Cd'',''''),''insu_pub2_cd'',NULLIF(''@insuSetInfo.insuPub2Cd'',''''),''insu_pub3_cd'',NULLIF(''@insuSetInfo.insuPub3Cd'',''''),''insu_pub4_cd'',NULLIF(''@insuSetInfo.insuPub4Cd'',''''))
                  end,
  insu_self_info = null,
  is_selected = NULLIF(''@isSelected'',''''),
  is_disp = NULLIF(''@isDisp'',''''),
  coop_code = NULLIF(''@coopCode'',''''),
  is_coop = NULLIF(''@isCoop'',''''),
  up_date = CURRENT_TIMESTAMP,
  start_date = NULLIF(''@startDate'',''''),
  end_date = NULLIF(''@endDate'',''''),
  check_date = NULLIF(''@checkDate'',''''),
  old_up_date = case ''@oldUpDate_Date''
                  when '''' then null
                  else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
                end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''
and
  ctl_no = @ctlNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1304;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1304, 'delete 

from

  pat_insurance

where

  pat_id = @patId

and

  facility_cd = ''@facilityCd''

and

  is_del = ''0''

and

  is_coop = ''1''

order by

  ctl_no', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1401;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1401, 'select

	pat_id,

	fn_pat_id,

	hosp_pat_id,

	nkk_pat_id,

	facility_cd,

	personal_info_decrypt(pat_last_name) as pat_last_name,

	personal_info_decrypt(pat_first_name) as pat_first_name,

	personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,

	personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,

	personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,

	personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,

	personal_info_decrypt(pat_birth_name) as pat_birth_name,

	personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,

	personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,

	pat_birthday,

	pat_sex,

	nationality,

	pat_blood_type_abo,

	pat_blood_type_rh,

	pat_blood_type_serovar,

	in_out_class,

	is_die,

	die_cd,

	die_date,

	dial_diff_com_info,

	severity_cd,

	transport_cd,

	personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,

	personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,

	personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,

	insurance_info,

	is_del,

	up_date,

	reg_date,

	primary_disease_cd,

	remote_monitor_service,

	personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,

	personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw

from

  pat_personal_main

where

  is_del = ''0''

and

  hosp_pat_id = @hospPatId

and

  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1402;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1402, 'update pat_personal_main set

	other_contact_info = ''[]''

where

  is_del = ''0''

and

  hosp_pat_id = ''@hospPatId''

and

  facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1403;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1403, 'update pat_personal_main set
  dial_diff_com_info = case ''@dialDiffComInfoFlg''
                         when '''' then ''@dialDiffComInfoValue''
                         else dial_diff_com_info || ''[{"ctl_no":"@dialDiffComInfo.ctlNo","dial_diff_cd":"@dialDiffComInfo.dialDiffCd","is_main":"@dialDiffComInfo.isMain","is_dial_diff":"@dialDiffComInfo.isDialDiff","reg_date":"@dialDiffComInfo.regDate"}]''::jsonb
                       end,
  other_contact_info = case ''@otherContactInfoFlg''
                         when '''' then ''@otherContactInfoValue''
                         else other_contact_info || ''[{"ctl_no":"@otherContactInfo.ctlNo","disp_order":"@otherContactInfo.dispOrder","is_key_person":"@otherContactInfo.isKeyPerson","pat_id":"@otherContactInfo.patId","last_name":"@otherContactInfo.lastName","first_name":"@otherContactInfo.firstName","last_name_kana":"@otherContactInfo.lastNmKana","first_name_kana":"@otherContactInfo.firstNmKana","relation_cd":"@otherContactInfo.relationCd","relation_name":"@otherContactInfo.relationName","zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":"@otherContactInfo.eMail","work_name":"@otherContactInfo.workName","work_tel":"@otherContactInfo.workTel","tel1":"@otherContactInfo.tel1","tel2":"@otherContactInfo.tel2","fax":"@otherContactInfo.fax","memo1":"otherContactInfo.@memo1","memo2":"otherContactInfo.@memo2"}]''::jsonb
                       end,
  vendor_contact_info = case ''@vendorContactInfoFlg''
                          when '''' then ''@vendorContactInfoValue''
                          else vendor_contact_info || ''[{"ctl_no":"@vendorContactInfo.ctlNo","disp_order":"@vendorContactInfo.dispOrder","company_name":"@vendorContactInfo.companyName","zip_cd":"@vendorContactInfo.zipCd","address":"@vendorContactInfo.address","company_tel":"@vendorContactInfo.companyTel","fax":"@vendorContactInfo.fax","worker_last_name":"@vendorContactInfo.workerLastName","worker_first_name":"@vendorContactInfo.workerFirstName","worker_tel":"@vendorContactInfo.workerTel","worker_e_mail":"@vendorContactInfo.workerEMail","memo1":"@vendorContactInfo.memo1","memo2":"@vendorContactInfo.memo2"}]''::jsonb
                        end,
  insurance_info = case ''@insuranceInfoFlg''
                          when '''' then ''@insuranceInfoValue''
                          else insurance_info || ''[{"insurance_no":"@insuranceInfo.insuranceNo","insurance_class":"@insuranceInfo.insuranceClass","insured_cd":"@insuranceInfo.insuredCd","insured_no":"@insuranceInfo.insuredNo","insurance_ratio":"@insuranceInfo.insuranceRatio","pub_insu_no1":"@insuranceInfo.pubInsuNo1","pub_insu_no2":"@insuranceInfo.pubInsuNo2","pub_insu_rec_no1":"@insuranceInfo.pubInsuRecNo1","pub_insu_rec_no2":"@insuranceInfo.pubInsuRecNo2","insurance_memo1":"@insuranceInfo.insuranceMemo1","insurance_memo2":"@insuranceInfo.insuranceMemo2","disability_no":"@insuranceInfo.disabilityNo"}]''::jsonb
                        end
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and
  facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1501;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1501, 'select

	pat_id,

	fn_pat_id,

	hosp_pat_id,

	nkk_pat_id,

	facility_cd,

	personal_info_decrypt(pat_last_name) as pat_last_name,

	personal_info_decrypt(pat_first_name) as pat_first_name,

	personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,

	personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,

	personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,

	personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,

	personal_info_decrypt(pat_birth_name) as pat_birth_name,

	personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,

	personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,

	pat_birthday,

	pat_sex,

	nationality,

	pat_blood_type_abo,

	pat_blood_type_rh,

	pat_blood_type_serovar,

	in_out_class,

	is_die,

	die_cd,

	die_date,

	dial_diff_com_info,

	severity_cd,

	transport_cd,

	personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,

	personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,

	personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,

	insurance_info,

	is_del,

	up_date,

	reg_date,

	primary_disease_cd,

	remote_monitor_service,

	personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,

	personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw

from

  pat_personal_main

where

  is_del = ''0''

and

  hosp_pat_id = @hospPatId

and

  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1502;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1502, 'update pat_personal_main set

 is_die = ''@isDie'',

 die_date = 

  case ''@dieDate_Date''

    when '''' then null

    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')

  end

where facility_cd = ''@facilityCd'' and hosp_pat_id = ''@hospPatId'' and is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
