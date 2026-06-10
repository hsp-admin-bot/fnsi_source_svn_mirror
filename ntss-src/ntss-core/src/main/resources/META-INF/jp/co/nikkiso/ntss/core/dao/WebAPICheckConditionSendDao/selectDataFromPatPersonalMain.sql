select
	personal_info_decrypt(pat_last_name) as pat_last_name,
	personal_info_decrypt(pat_first_name) as pat_first_name
from
  pat_personal_main
where
  is_del = '0'
and
  pat_id = /* patId */1
;
