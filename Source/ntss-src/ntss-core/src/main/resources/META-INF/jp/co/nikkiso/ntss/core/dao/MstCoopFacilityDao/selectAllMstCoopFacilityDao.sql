SELECT /*%expand "a" */* 
FROM mst_coop_facility AS a
WHERE a.is_del = '0'
AND a.is_disp = '1';