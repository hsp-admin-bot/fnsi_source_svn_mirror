select 
  /*%expand "A" */*
from mst_wheel_chair A
where A.facility_cd = /*facilityCd*/'999999'
/*%if null != isDisp */
and
  A.is_disp=/*isDisp*/null
/*%end*/
/*%if null != isDel */
and
  A.is_del=/*isDel*/null
/*%end*/
;