select
 /*%expand */*

from
 mst_self_measure_result

where
 facility_cd = /*facilityCd*/'1'
 and
 is_del = '0'
 and
 is_disp = '1'
;