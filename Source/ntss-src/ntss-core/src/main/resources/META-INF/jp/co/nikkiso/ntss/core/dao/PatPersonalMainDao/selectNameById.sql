select
	hosp_pat_id,
	personal_info_decrypt(pat_last_name) as pat_last_name,
	personal_info_decrypt(pat_first_name) as pat_first_name
from
  pat_personal_main
where
  pat_id = /* patId */1
and
  is_del = '0'
;
