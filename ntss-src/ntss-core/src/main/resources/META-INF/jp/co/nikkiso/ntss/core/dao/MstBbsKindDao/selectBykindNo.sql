select
  /*%expand "A" */*
from
  mst_bbs_kind A
where
  facility_cd=/*facility_cd*/'000000'
and
  is_del='0'
and
  kind_no=/*kind_no*/0L

;