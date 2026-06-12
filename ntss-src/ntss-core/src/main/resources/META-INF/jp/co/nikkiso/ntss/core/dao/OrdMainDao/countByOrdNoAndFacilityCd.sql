SELECT
  COUNT(*)
FROM
  ord_main
WHERE
  facility_cd = /*facilityCd*/'X'
AND ord_no IN /*ordNoList*/(0)
