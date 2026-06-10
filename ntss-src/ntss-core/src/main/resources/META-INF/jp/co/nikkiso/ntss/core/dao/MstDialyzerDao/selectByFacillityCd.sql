select
  /*%expand "A" */*
from
  mst_dialyzer A
where
  is_del = '0'
and
  A.facility_cd = /*facilityCd*/'009999'
;
