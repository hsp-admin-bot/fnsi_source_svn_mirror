select
  /*%expand*/*
from
  mst_facility_hash
where
    facility_cd in /*facilityCdList*/('1')
;
