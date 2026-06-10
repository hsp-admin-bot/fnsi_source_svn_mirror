SELECT
  /*%expand*/*
FROM
  mst_pat_memo
WHERE
  facility_cd = /*facilityCd*/null
AND
  pat_memo_no = /*patMemoNo*/null
;
