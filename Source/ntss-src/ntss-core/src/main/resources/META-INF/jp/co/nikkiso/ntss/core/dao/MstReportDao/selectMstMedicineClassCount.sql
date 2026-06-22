select
  count(1)
from
  mst_medicine_class
where
  facility_cd = /*facilityCd*/null
and
  is_disp = '1'
and
  is_del = '0'
;
