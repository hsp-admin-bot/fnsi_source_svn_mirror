select
  pat_id,
  in_out_class,
  hosp_pat_id,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana
from
  pat_personal_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/''
  and pat_id in /* patIdList */(null)
;
