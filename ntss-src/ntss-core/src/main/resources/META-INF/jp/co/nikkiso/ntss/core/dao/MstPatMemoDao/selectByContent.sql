SELECT
  /*%expand*/*
FROM
  mst_pat_memo
WHERE
  facility_cd = /*facilityCd*/null
AND
  content = /*content*/null
;
