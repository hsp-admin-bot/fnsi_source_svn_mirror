SELECT
  /*%expand*/*
FROM
  mst_coop_facility
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  is_disp = '1'
AND
  is_del = '0'
