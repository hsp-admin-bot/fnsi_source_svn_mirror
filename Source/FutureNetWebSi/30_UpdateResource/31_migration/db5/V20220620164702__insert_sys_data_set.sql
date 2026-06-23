delete from sys_data_set where sql_cd = 1885;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1885, 'update pat_unique set
in_out_visit_history_info = ''[{"ctl_no": 1, "in_out": 2, "reason": null, "to_course": null, "to_doctor": null, "disp_order": 0, "period_end": null, "facility_cd": "999998", "from_course": null, "from_doctor": null, "move_in_out": "11", "to_facility": null, "period_start": "@dieDate", "from_facility": null, "course_is_free": "0", "doctor_is_free": "0", "period_end_day": null, "period_end_year": null, "facility_is_free": "0", "period_end_month": null, "period_start_day": "01", "period_start_date": null, "period_start_year": "2022", "period_start_month": "06", "period_end_input_free": "0", "period_start_input_free": "0", "to_medicalInstitutionCd": null, "from_medicalInstitutionCd": null}, {"ctl_no": 2, "in_out": 1, "reason": null, "to_course": null, "to_doctor": null, "disp_order": 0, "period_end": null, "facility_cd": "999998", "from_course": null, "from_doctor": null, "move_in_out": "4", "to_facility": null, "period_start": "20100101", "from_facility": null, "course_is_free": "0", "doctor_is_free": "0", "period_end_day": null, "period_end_year": null, "facility_is_free": "0", "period_end_month": null, "period_start_day": "01", "period_start_date": "20100101", "period_start_year": "2010", "period_start_month": "01", "period_end_input_free": "0", "period_start_input_free": "0", "to_medicalInstitutionCd": null, "from_medicalInstitutionCd": null}]''
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1881;  
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1881, '
with currentTime as (select to_char(CURRENT_TIMESTAMP,''YYYYMMDD'') as nowDate)
update pat_unique set
  medical_hst_info = (''[{"memo":null, "ctl_no":null, "die_date": "@dieDate", "out_come": "10", "course_cd":null, "is_notice":null, "disease_cd":null, "disp_order":null, "disease_day":null, "facility_cd":null, "disease_date":null, "disease_year":null, "is_diagnosed":null, "diagnosis_day":null, "disease_month":null, "out_come_date": "''||currentTime.nowDate||''", "course_is_free":null, "diagnosis_date":null, "diagnosis_year":null, "diagnosis_month":null, "is_main_disease":null, "diagnostician_cd":null, "diagnosis_facility_cd":null, "diagnostician_is_free":null, "is_confirmation_biopsy":null, "diagnosis_facility_is_free":null, "is_dialysis_underlying_disease":null}]'') :: jsonb
	from currentTime
where
  pat_id = 19917
and
  facility_cd = ''999998''
and
  is_del = ''0'';', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_生存情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]');
delete from sys_data_set where sql_cd = 1891;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1891, 'DELETE 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND (treat_date > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND rst_dialysis_state = ''0''))', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。透析予定(ord_main)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1893;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1893, 'DELETE 
FROM
  pat_rad_main 
WHERE
  is_del = ''0'' 
  AND rad_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。一般撮影検査オーダ（pat_rad_main）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1892;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1892, 'DELETE 
FROM
  pat_exam_main 
WHERE
  is_del = ''0'' 
  AND exam_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。検査オーダ（pat_exam_main）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1879;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1879, 'SELECT
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique 
FROM
  pat_unique 
WHERE
  pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報取得JSON', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1884;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1884, 'SELECT
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique 
FROM
  pat_unique 
WHERE
  pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1887;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1887, 'WITH die_info AS (
  SELECT 
    COALESCE(NULLIF(''@isDie'', ''''), ''0'') AS is_die
    , TO_TIMESTAMP(NULLIF(''@dieDate_Date'', ''''), ''YYYY-MM-DD HH24:MI:SS'') AS die_date
)
UPDATE pat_personal_main 
SET
  in_out_class = ''2''
WHERE
  facility_cd = ''@facilityCd'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1886;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1886, 'select
		pat_id,
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
		remote_monitor_user_pw,
		old_up_date_personal
		from
		pat_personal_main
		where
		WHERE
                                      pat_id = @patId 
                                     AND is_del = ''0''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1889;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1889, 'select
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
WHERE
 pat_id = @patId 
 AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from sys_data_set where sql_cd = 1890;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1890, 'update pat_main set
in_out_current_state = 11
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
