select
  /*%expand "A" */*
from
  mst_wheel_chair A
where
  A.pat_id = /*patId*/'999999'
and
  A.is_personal = '1'
/*%if null != isDisp */
and
  A.is_disp=/*isDisp*/null
/*%end*/
/*%if null != isDel */
and
  A.is_del=/*isDel*/null
/*%end*/
;