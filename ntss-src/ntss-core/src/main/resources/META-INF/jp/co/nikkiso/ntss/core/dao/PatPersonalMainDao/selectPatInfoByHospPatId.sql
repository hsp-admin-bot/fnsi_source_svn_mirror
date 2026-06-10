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
	personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = '0'
and
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
-- --   mod FNSI-終了およびその結果を通知機能で教える 江 start
-- --   to_number(hosp_pat_id, '999999999999') = to_number(/*hospPatId*/0, '999999999999')
--   hosp_pat_id = /*hospPatId*/0
-- --   mod FNSI-終了およびその結果を通知機能で教える 江 end
-- mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
--  ltrim(hosp_pat_id, '0') = ltrim(/*hospPatId*/0, '0')
  hosp_pat_id = /*hospPatId*/0
-- mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
and
  facility_cd = /*facilityCd*/'000001'
;
