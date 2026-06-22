SELECT
  /*%expand "mms" */*
FROM
  mst_medicine_support mms
WHERE
  mms.medicine_support_cd = /*cd*/'10'
  AND mms.is_del = '0'
  limit 1
