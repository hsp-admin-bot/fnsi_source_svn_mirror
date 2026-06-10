SELECT
    /*%expand "A" */*
FROM mst_relationship A
WHERE A.is_del = '0'
  and A.facility_cd = /* facilityCd*/'0'
;
