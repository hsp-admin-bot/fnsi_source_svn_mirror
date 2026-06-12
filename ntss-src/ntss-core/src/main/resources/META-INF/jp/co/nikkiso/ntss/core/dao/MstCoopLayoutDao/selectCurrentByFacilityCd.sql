SELECT /*%expand "a" */*
FROM mst_coop_layout AS a
WHERE a.facility_cd = /*facilityCd*/''
AND a.is_disp = '1'
ORDER BY a.ctl_no
