select
  pat_id,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name
from
  pat_personal_main
where is_del = '0'
  and facility_cd = /* facilityCd */0
order by pat_id;
