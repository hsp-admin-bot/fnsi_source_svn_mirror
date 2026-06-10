select
  /*%expand "A" */*
from
  mst_room_bed_group A
where
  A.facility_cd = /*facilityCd*/'999000'
;
