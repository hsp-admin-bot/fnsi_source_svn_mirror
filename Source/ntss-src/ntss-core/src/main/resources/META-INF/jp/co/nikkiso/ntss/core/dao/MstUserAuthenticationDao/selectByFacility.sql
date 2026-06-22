select
  /*%expand "A" */*
from
  mst_user_authentication A
where
  A.facility_cd = /*facilityCd*/'999999'
order by
  A.user_id
;
