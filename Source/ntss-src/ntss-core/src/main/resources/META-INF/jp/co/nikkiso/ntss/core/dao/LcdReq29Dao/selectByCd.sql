select
  user_id,
  CONCAT(COALESCE(user_last_name, ''), COALESCE(user_first_name, '')) AS user_name
from
  mst_user
where
  facility_cd = /*facilityCd*/'000001'
order by user_id
;