select
  /*%expand "A" */*
from
  mst_medicine A
where
  A.facility_cd = /* facilityCd*/'0'
and
  A.medicine_cd = /* medicineCd*/'0'
and
  A.is_del = '0'
;
