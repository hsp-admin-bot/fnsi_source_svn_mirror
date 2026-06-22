select
  /*%expand*/*
from
  mst_job
where
  facility_cd = /*facilityCd*/1
and
  is_disp = '1'
and
  is_del = '0'
;
