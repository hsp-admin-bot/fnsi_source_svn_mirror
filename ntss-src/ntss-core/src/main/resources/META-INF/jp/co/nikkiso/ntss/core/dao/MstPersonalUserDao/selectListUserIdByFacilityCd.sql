select
  user_id
from
  mst_personal_user
where
  is_del = /* isDel */'0'
  /*%if facilityCd != null */
  And facility_cd = /* facilityCd */'0'
  /*%end */
  And user_type != '2'
;