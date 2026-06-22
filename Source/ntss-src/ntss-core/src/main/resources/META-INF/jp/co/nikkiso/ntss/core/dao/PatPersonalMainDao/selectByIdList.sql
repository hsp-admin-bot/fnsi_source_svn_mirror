select
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
	personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw,
	up_date as old_up_date_personal
from
  pat_personal_main
where
  is_del = '0'
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
