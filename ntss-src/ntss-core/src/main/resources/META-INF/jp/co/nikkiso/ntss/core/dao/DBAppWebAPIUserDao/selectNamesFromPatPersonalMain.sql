select
  user_id,
  /*%if cryptoFlag */   --復号しない(暗号化したまま)
  user_last_name as user_last_name,
  user_first_name as user_first_name
  /*%else*/             --復号
  personal_info_decrypt(user_last_name) as user_last_name,
  personal_info_decrypt(user_first_name) as user_first_name
  /*%end*/
from
  mst_personal_user
where
/*%if null != facilityCdList && 0 != facilityCdList.size()*/
  facility_cd in /*facilityCdList*/('000001')
  /*%end */
/*%if null != userIdList && 0 != userIdList.size()*/
and
  user_id in /* userIdList */(1)
/*%end*/
order by
  user_id
;
