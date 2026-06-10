SELECT /*%expand "a" */*
FROM mst_coop_layout AS a
WHERE a.is_del = '0'
/*%if coopName != null */
AND UPPER(a.coop_name) like '%' || /*coopName*/'' || '%' 
/*%end */
AND a.is_disp = '1';