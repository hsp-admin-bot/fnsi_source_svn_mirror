SELECT
  /*%expand "A" */*
FROM
  mst_rad_set A
WHERE
  A.rad_set_cd = /* radSetCd */0
and
  A.is_disp = '1' 
and
  A.is_del = '0' 
;
