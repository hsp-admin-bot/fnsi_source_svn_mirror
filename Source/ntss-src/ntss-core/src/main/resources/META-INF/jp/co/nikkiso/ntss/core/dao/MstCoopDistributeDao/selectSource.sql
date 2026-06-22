SELECT /*%expand "a" */*
FROM mst_coop_distribute AS a
WHERE a.coop_version = /*coopVersion*/''
AND a.coop_cd = /*coopCd*/''
AND a.direction = /*direction*/''
AND a.ctl_no <= 0
AND a.is_disp = '1'
ORDER BY a.ctl_no
