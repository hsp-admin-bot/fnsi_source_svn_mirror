select
  /*%expand "A" */*
from
  mst_moni_item A
where
  (A.facility_cd = /*facility_cd*/'999000' or A.facility_cd = 'all') and
  A.model=/*model*/'001' and
  A.moni_no=/*moni_no*/0
;