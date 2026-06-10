select
  user_id,
  personal_info_decrypt(user_last_name) as user_last_name,
  personal_info_decrypt(user_first_name) as user_first_name
from
  mst_personal_user
where
  is_del = /* isDel */'0'
  /*%if facilityCd != null */
  And facility_cd = /* facilityCd */'0'
  /*%end */
;
