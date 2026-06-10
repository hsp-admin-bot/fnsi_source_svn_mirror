SELECT /*%expand "a" */*
FROM mst_coop_facility AS a
WHERE a.is_del = '0'
/*%if ctlNo != null */
AND a.ctl_no = /*ctlNo*/0
/*%end */
/*%if facilityCd != null */
AND a.facility_cd = /*facilityCd*/null
/*%end */
AND a.is_disp = '1';