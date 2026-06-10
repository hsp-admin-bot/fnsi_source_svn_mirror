select
	hosp_pat_id,
	pat_id,
    encode(convert_to(personal_info_decrypt(pat_last_name)::text, 'UTF-8'), 'base64') as pat_last_name,
    encode(convert_to(personal_info_decrypt(pat_first_name)::text, 'UTF-8'), 'base64') as pat_first_name,
	pat_birthday
from
  pat_personal_main
where
  is_del = '0'
and
  pat_id = /* patId */0
;
