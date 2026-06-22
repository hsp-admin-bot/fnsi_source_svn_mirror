SELECT
    /*%expand "A" */*
FROM mst_implant A
WHERE A.is_del = '0'
  and A.facility_cd = /* facilityCd*/'0'
;
