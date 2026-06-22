SELECT
  /*%expand*/*
FROM
  mst_round_type
WHERE
  facility_cd = /*facilityCd*/'1'
ORDER BY
  round_type_cd
;
