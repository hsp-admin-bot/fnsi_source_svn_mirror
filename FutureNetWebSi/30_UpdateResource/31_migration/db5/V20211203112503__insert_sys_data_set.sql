delete from "sys_data_set" where "sql_cd" in (9307,9306,9305,9304,9303,9302,9301);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9307, 'INSERT INTO ord_personal_prescription( 
  ord_prescription_no
  , facility_cd
  , pat_id
  , insurance_cd
  , insu_pub_no
  , insu_pub_pat_no
  , insu_no
  , insu_pat_mark
  , insu_pat_no
  , is_insured
  , is_dependent
  , insu_kbn
  , insu_dr_id
  , insu_dr_name
  , insu_dr_sign
  , is_doubt
  , is_information
  , is_elderly
  , is_elderly7
  , is_child
  , remarks
  , is_anesthesia
  , remarks_anesthesia
  , remarks_free
  , is_disp
  , is_del
  , reg_date
  , up_date
  , fn_ord_prescription_no
) 
VALUES (
  @ordPrescriptionNo
  , ''@facilityCd''
  , @patId
  , @insuranceCd
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , @insuDrId
  , ''@insuSrName''
  , NULL
  , ''@isDoubt''
  , ''@isInformation''
  , ''@isElderly1''
  , ''@isElderly7''
  , ''@isChild''
  , NULL
  , ''@isAnesthesia''
  , NULL
  , ''@remarksFree''
  , ''1''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の新規登録(ord_personal_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', '[{"sql_cd": 9302, "field_name": "ord_prescription_no", "replace_var": "@ordPrescriptionNo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9306, 'SELECT
  ord_prescription_no
  , facility_cd
  , pat_id
  , insurance_cd
  , insu_pub_no
  , insu_pub_pat_no
  , insu_no
  , insu_pat_mark
  , insu_pat_no
  , is_insured
  , is_dependent
  , insu_kbn
  , insu_dr_id
  , insu_dr_name
  , insu_dr_sign
  , is_doubt
  , is_information
  , is_elderly
  , is_elderly7
  , is_child
  , remarks
  , is_anesthesia
  , remarks_anesthesia
  , remarks_free
  , is_disp
  , is_del
  , reg_date
  , up_date
  , fn_ord_prescription_no 
FROM
  ord_personal_prescription 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd
  AND ord_prescription_no = @ordPrescriptionNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の取得処理(ord_personal_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9305, 'INSERT INTO ord_prescription( 
  facility_cd
  , pat_id
  , prescription_type
  , issue_date
  , issue_state
  , expiration_date
  , prescription_detail
  , is_disp
  , is_del
  , reg_date
  , up_date 
) 
VALUES (
  ''@facilityCd''
  , @patId
  , ''@prescriptionType''
  , ''@issueDate''
  , ''@issueState''
  , ''@expirationDate''
  , ''@prescriptionDetail''
  , ''1''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の新規登録(ord_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9304, 'UPDATE ord_prescription 
SET
  is_del = ''1''
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND prescription_type = ''2'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND issue_date = ''@issueDate''
  AND ord_prescription_no = @ordPrescriptionNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の倫理削除(ord_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9303, 'UPDATE ord_personal_prescription 
SET
  is_del = ''1''
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND ord_prescription_no = @ordPrescriptionNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の倫理削除(ord_personal_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9302, 'SELECT
  ord_prescription_no
  , facility_cd
  , pat_id
  , prescription_type
  , issue_date
  , issue_state
  , expiration_date
  , prescription_detail
  , is_disp
  , is_del
  , reg_date
  , up_date 
FROM
  ord_prescription 
WHERE
  is_del = ''0'' 
  AND prescription_type = ''2''
  AND pat_id = @patId 
  AND facility_cd = @facilityCd
  AND issue_date = @issueDate', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の処方情報の取得処理(ord_prescription)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9301, 'select
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
  ltrim(hosp_pat_id, ''0'') = ltrim(@hospPatId, ''0'')
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC処方情報連携の患者個人情報(SELECT)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:40.841', NULL);
