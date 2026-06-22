SELECT
  /*%expand*/*
FROM
  mst_complaint
WHERE
  facility_cd = /*facilityCd*/'1' and
  is_del = '0'
;
