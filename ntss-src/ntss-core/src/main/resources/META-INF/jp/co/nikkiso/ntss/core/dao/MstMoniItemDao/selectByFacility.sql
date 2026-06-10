select
  /*%expand*/*
from
  mst_moni_item
where
  (facility_cd = /*facility_cd*/'999000' or facility_cd = 'all')
;
