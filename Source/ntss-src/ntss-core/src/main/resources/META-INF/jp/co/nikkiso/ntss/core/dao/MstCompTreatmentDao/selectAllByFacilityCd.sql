SELECT
  /*%expand*/*
FROM
  mst_comp_treatment
WHERE
  facility_cd = /*facilityCd*/'1' and
  is_del = '0'
;
