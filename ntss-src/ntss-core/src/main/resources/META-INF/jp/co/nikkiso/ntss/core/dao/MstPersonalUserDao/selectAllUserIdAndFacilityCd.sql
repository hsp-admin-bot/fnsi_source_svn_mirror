select
  user_id,
  facility_cd
from
  mst_personal_user
where
  is_del = '0'
--   is_del = /* isDel */'0'
--   /*%if facilityCd != null */
--   And facility_cd = /* facilityCd */'0'
--   /*%end */
-- mod bug 6163 修正 chen end
  And user_type != '2'
order by user_id;
