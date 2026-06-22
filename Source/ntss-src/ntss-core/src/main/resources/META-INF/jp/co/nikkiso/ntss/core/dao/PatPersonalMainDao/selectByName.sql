select
  pat_id
from
  pat_personal_main
where
  is_del = '0'
  and facility_cd in /*facilityCds*/(0)
  /*%if keyWord != null && searchFlag */
    and personal_info_decrypt(pat_last_name) || ' ' || personal_info_decrypt(pat_first_name)  like /* keyWord */null
  /*%elseif keyWord != null && !searchFlag */
    and personal_info_decrypt(pat_last_name) || ' ' || personal_info_decrypt(pat_first_name)  not like /* keyWord */null
  /*%end*/
order by
  pat_id;
