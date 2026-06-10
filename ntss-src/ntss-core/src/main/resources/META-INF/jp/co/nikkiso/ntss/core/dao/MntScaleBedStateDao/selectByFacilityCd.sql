select
  /*%expand "A" */*
from mnt_scale_bed_state A
where A.facility_cd = /*facilityCd*/'999900'
;
