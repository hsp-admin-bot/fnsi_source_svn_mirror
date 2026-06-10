select
  /*%expand "A" */*
from
  mst_bed A
where
  bed_cd = /*bed_cd*/0
/*%if null != is_disp */
and
  is_disp=/*is_disp*/null
/*%end*/
/*%if null != is_del */
and
  is_del=/*is_del*/null
/*%end*/
;