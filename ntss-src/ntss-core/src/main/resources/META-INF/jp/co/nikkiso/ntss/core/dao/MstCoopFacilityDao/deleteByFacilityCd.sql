UPDATE mst_coop_facility AS a
SET
    is_del = '1'
WHERE 
    a.facility_cd = /*facilityCd*/'000000'
;