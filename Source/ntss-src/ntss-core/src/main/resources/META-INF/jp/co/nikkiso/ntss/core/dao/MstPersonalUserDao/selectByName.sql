select
  user_id
from
  mst_personal_user
where
  is_del = '0'
  and is_disp = '1'
  and facility_cd in /*facilityCds*/(0)
  /*%if keyWord != null && searchFlag */
    and personal_info_decrypt(user_last_name) || ' ' || personal_info_decrypt(user_first_name)  like /* keyWord */null
  /*%elseif keyWord != null && !searchFlag */
    and personal_info_decrypt(user_last_name) || ' ' || personal_info_decrypt(user_first_name)  not like /* keyWord */null
  /*%end*/
order by
  user_id;



