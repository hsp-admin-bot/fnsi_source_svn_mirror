select
  /*%expand*/*
from
  mst_machine
where
  facility_cd = /*facilityCd*/'1'
  and
  ip_address = /*ip*/null
;
