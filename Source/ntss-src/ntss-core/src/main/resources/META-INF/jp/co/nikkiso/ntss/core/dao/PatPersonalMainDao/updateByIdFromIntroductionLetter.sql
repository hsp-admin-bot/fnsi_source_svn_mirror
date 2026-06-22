update pat_personal_main
set
/*%if pat.fn_pat_id != null*/
  fn_pat_id = /* pat.fn_pat_id */null,
/*%end*/
/*%if pat.hosp_pat_id != null*/
  hosp_pat_id = /* pat.hosp_pat_id */null,
/*%end*/
/*%if pat.nkk_pat_id != null*/
  nkk_pat_id = /* pat.nkk_pat_id */null,
/*%end*/
/*%if pat.facility_cd != null*/
  facility_cd = /* pat.facility_cd */null,
/*%end*/
/*%if pat.pat_last_name != null*/
  pat_last_name = personal_info_encrypt(/* pat.pat_last_name */null),
/*%end*/
/*%if pat.pat_first_name != null*/
  pat_first_name = personal_info_encrypt(/* pat.pat_first_name */null),
/*%end*/
/*%if pat.pat_last_name_kana != null*/
  pat_last_name_kana = personal_info_encrypt(/* pat.pat_last_name_kana */null),
/*%end*/
/*%if pat.pat_first_name_kana != null*/
  pat_first_name_kana = personal_info_encrypt(/* pat.pat_first_name_kana */null),
/*%end*/
/*%if pat.pat_last_name_alpha != null*/
  pat_last_name_alpha = personal_info_encrypt(/* pat.pat_last_name_alpha */null),
/*%end*/
/*%if pat.pat_first_name_alpha != null*/
  pat_first_name_alpha = personal_info_encrypt(/* pat.pat_first_name_alpha */null),
/*%end*/
/*%if pat.pat_birth_name != null*/
  pat_birth_name = personal_info_encrypt(/* pat.pat_birth_name */null),
/*%end*/
/*%if pat.pat_birth_name_kana != null*/
  pat_birth_name_kana = personal_info_encrypt(/* pat.pat_birth_name_kana */null),
/*%end*/
/*%if pat.pat_birth_name_alpha != null*/
  pat_birth_name_alpha = personal_info_encrypt(/* pat.pat_birth_name_alpha */null),
/*%end*/
/*%if pat.pat_birthday != null*/
  pat_birthday = /*pat.pat_birthday*/null,
/*%end*/
/*%if pat.pat_sex != null*/
  pat_sex = /*pat.pat_sex*/null,
/*%end*/
/*%if pat.nationality != null*/
  nationality = /*pat.nationality*/null,
/*%end*/
/*%if pat.pat_blood_type_abo != null*/
  pat_blood_type_abo = /*pat.pat_blood_type_abo*/null,
/*%end*/
/*%if pat.pat_blood_type_rh != null*/
  pat_blood_type_rh = /*pat.pat_blood_type_rh*/null,
/*%end*/
/*%if pat.pat_blood_type_serovar != null*/
  pat_blood_type_serovar = /*pat.pat_blood_type_serovar*/null,
/*%end*/
/*%if pat.in_out_class != null*/
  in_out_class = /*pat.in_out_class*/null,
/*%end*/
/*%if pat.is_die != null*/
  is_die = /*pat.is_die*/null,
/*%end*/
/*%if pat.die_cd != null*/
  die_cd = /*pat.die_cd*/null,
/*%end*/
/*%if pat.die_date != null*/
  die_date = /*pat.die_date*/null,
/*%end*/
/*%if pat.dial_diff_com_info != null*/
  dial_diff_com_info = /*pat.dial_diff_com_info*/null,
/*%end*/
/*%if pat.severity_cd != null*/
  severity_cd = /*pat.severity_cd*/null,
/*%end*/
/*%if pat.transport_cd != null*/
  transport_cd = /*pat.transport_cd*/null,
/*%end*/
/*%if pat.pat_contact_info != null*/
  pat_contact_info = /*pat.pat_contact_info*/null,
/*%end*/
/*%if pat.other_contact_info != null*/
  other_contact_info = /*pat.other_contact_info*/null,
/*%end*/
/*%if pat.vendor_contact_info != null*/
  vendor_contact_info = /*pat.vendor_contact_info*/null,
/*%end*/
/*%if pat.insurance_info != null*/
  insurance_info = /*pat.insurance_info*/null,
/*%end*/
/*%if pat.is_del != null*/
  is_del = /*pat.is_del*/null,
/*%end*/
/*%if pat.reg_date != null*/
  reg_date = /* pat.reg_date */null,
/*%end*/
/*%if pat.primary_disease_cd != null*/
  primary_disease_cd = /*pat.primary_disease_cd*/null,
/*%end*/
/*%if pat.remote_monitor_service != null*/
  remote_monitor_service = /*pat.remote_monitor_service*/null,
/*%end*/
/*%if pat.remote_monitor_user_id != null*/
  remote_monitor_user_id = /*pat.remote_monitor_user_id*/null,
/*%end*/
/*%if pat.remote_monitor_user_id != null*/
  remote_monitor_user_pw = /*pat.remote_monitor_user_id*/null,
/*%end*/
  up_date = to_timestamp(/* pat.up_date */null, 'yyyyMMdd')
where
  pat_id = /*pat_id*/null
;