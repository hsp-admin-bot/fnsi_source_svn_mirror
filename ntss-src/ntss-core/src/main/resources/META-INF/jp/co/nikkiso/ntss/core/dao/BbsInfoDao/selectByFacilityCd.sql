select
  /*%expand "A" */*
from
  bbs_info A
where
  facility_cd=/*facility_cd*/'000000'
;
