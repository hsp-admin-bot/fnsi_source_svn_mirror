select
  /*%expand "A" */*
from
  sys_daily_no A
where
  A.facility_cd=/*facilityCd*/'000000'
and
  A.numbering_cd=/*numberingCd*/'X'
and
  A.is_del='0'
;
