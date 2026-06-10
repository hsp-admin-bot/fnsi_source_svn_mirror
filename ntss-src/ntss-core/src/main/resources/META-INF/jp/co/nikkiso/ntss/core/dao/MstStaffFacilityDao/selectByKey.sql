select
  /*%expand*/*
from
  mst_staff_facility
where
  user_id = /*userId*/1
  and
  facility_cd = /*facilityCd*/'1'
;
