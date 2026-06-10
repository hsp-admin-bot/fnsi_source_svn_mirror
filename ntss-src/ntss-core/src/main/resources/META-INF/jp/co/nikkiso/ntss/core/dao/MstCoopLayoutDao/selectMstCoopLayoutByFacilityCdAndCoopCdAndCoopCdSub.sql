SELECT /*%expand "a" */*
FROM mst_coop_layout AS a
WHERE a.is_del = '0'
AND a.is_disp = '1'
AND a.facility_cd = /*facilityCd*/null
AND a.coop_cd = /*coopCd*/null
AND a.coop_cd_sub = /*coopCdSub*/null;