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
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1102;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
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
  null,
  ''@hospPatId'',
  null,
  ''@facilityCd'',
  personal_info_encrypt(''@patLastName''),
  personal_info_encrypt(''　''),
  personal_info_encrypt(''@patLastNmKana''),
  personal_info_encrypt(''　''),
  null,
  null,
  null,
  null,
  null,
  ''@patBirthday'',
  ''@patSex'',
  null,
  null,
  null,
  null,
  ''@inOutClass'',
  null,
  null,
  null,
  null,
  null,
  null,
  json_build_object(''zip_cd'',''@zipCd'',''address'',''@address'',''tel'',''@tel'',''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null),
  ''[]'',
  null,
  null,
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  null,
  null,
  null,
  null
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1103;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'update pat_personal_main set
 pat_last_name = personal_info_encrypt(''@patLastName''),
 pat_last_name_kana = personal_info_encrypt(''@patLastNmKana''),
 pat_birthday = ''@patBirthday'',
 pat_sex = @patSex,
 in_out_class = ''@inOutClass'',
 pat_contact_info = json_build_object(''zip_cd'',''@zipCd'',''address'',''@address'',''tel'',''@tel'',''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null),
 up_date = CURRENT_TIMESTAMP
 where facility_cd = ''@facilityCd'' and hosp_pat_id = ''@hospPatId'' and is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
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
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1202;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'insert into pat_main (
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
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''[]'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  null,
  json_build_object(''main_course_cd'',''@mainCourseCd'',''ward_cd'',''@wardCd''),
  null,
  null,
  null,
  null,
  null
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1203;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'update pat_main set medical_care_info = json_build_object(''main_course_cd'',''@mainCourseCd'',''ward_cd'',''@wardCd''), up_date = CURRENT_TIMESTAMP where pat_id = @patId and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
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
  is_coop = ''1''
and
  ctl_no = @ctlNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1302;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1302, 'insert into 
    pat_insurance
	(
	pat_id,
	facility_cd,
	ctl_no,
	fn_pat_id,
	insu_class,
	insu_name,
	insu_name_short,
	start_date,
	end_date,
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
	)
VALUES
	(
	@patId,
	''@facilityCd'',
	case ''@ctlNo''
		when '''' then null
		else to_number(''@ctlNo'',''999999'')
	end,
	null,
	null,
	''@insuName'',
	null,
	''@startDate'',
	''@endDate'',
	json_build_object(
		''insu_pat_name'', null,
		''insu_no'', ''@insuNo'',
		''insu_kbn'', ''@insuKbn'',
		''insu_pat_mark'', null,
		''insu_pat_no'', null,
		''cki_class'', null,
		''kki_class'', null,
		''und_six'', null,
		''futan-g'', ''@futan-g'',
		''futan-n'', ''@futan-n''
 	),
	json_build_object(
		''insu_pub_name'', null,
		''insu_pub_no'', ''@insuPubNo'',
		''insu_pub_pat_no'', null
 	),
	json_build_object(
		''insu_cd'', null,
		''insu_pub1_cd'', null,
		''insu_pub2_cd'', null,
		''insu_pub3_cd'', null,
		''insu_pub4_cd'', null
 	),
	json_build_object(
		''insu_self_name'', null
	),
	null,
	''1'',
	''0'',
	null,
	''1'',
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP,
	null,
	null
	)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
DELETE FROM "sys_data_set" WHERE "sql_cd"  = 1303;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1303, 'update pat_insurance set
  start_date = ''@startDate'',
  end_date = ''@endDate'',
  insu_info = 	json_build_object(
		''insu_pat_name'', null,
		''insu_no'', ''@insuNo'',
		''insu_kbn'', ''@insuKbn'',
		''insu_pat_mark'', null,
		''insu_pat_no'', null,
		''cki_class'', null,
		''kki_class'', null,
		''und_six'', null,
		''futan-g'', ''@futan-g'',
		''futan-n'', ''@futan-n''
 	),
  insu_pub_info = json_build_object(
		''insu_pub_name'', null,
		''insu_pub_no'', ''@insuPubNo'',
		''insu_pub_pat_no'', null
 	),
  insu_name = ''@insuName'',
 up_date = CURRENT_TIMESTAMP
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
 other_contact_info = other_contact_info || ''[{"tel1":"@tel1","tel2":"@tel2","last_name":"@lastName","relation_cd":"@relationCd","memo1":"@memo1"}]''::jsonb 
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
