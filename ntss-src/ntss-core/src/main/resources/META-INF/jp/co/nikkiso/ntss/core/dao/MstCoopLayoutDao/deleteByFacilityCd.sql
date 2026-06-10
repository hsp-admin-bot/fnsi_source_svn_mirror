UPDATE mst_coop_layout AS a
SET
    is_del = '1'
WHERE 
    a.facility_cd = /*facilityCd*/'000000'
;