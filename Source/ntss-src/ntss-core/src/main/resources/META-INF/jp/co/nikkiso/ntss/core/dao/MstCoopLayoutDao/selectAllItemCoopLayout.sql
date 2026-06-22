SELECT /*%expand "a" */*
FROM mst_coop_layout as a
WHERE a.is_del = '0'
AND a.is_disp = '1';