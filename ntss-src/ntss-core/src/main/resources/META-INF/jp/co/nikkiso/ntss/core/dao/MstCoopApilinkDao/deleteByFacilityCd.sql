UPDATE mst_coop_apilink AS a
SET
    is_del = '1'
WHERE 
    a.facility_cd = /*facilityCd*/'000000'
;