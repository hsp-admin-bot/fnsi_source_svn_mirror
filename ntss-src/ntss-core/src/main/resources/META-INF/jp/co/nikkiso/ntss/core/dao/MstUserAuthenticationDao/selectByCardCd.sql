select
  /*%expand "A" */*
from
  mst_user_authentication A
where
  user_id = /*cardCd*/''
and
  facility_cd = /*facilityCd*/'999999'
;