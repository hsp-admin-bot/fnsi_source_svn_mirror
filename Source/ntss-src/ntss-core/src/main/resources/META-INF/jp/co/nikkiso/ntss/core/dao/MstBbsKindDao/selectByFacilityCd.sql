select
  /*%expand "A" */*
from
  mst_bbs_kind A
where
  facility_cd=/*facility_cd*/'000000'
/*%if null != is_del */
and
  is_del=/*is_del*/null
/*%end*/
;