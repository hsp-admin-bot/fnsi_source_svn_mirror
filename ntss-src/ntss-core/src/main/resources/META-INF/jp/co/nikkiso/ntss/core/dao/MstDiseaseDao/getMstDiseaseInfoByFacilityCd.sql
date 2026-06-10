select
    /*%expand "A" */*
from mst_disease A
where A.is_del = '0'
  and A.facility_cd = /* facilityCd*/'0'
;
