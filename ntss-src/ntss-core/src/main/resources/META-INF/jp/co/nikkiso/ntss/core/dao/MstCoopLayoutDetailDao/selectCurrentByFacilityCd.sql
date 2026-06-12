SELECT /*%expand "a" */*
FROM mst_coop_layout_detail AS a
WHERE a.facility_cd = /*facilityCd*/''
AND a.is_disp = '1'
ORDER BY a.ctl_no
