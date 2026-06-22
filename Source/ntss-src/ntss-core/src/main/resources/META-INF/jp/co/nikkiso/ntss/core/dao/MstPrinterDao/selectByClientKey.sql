SELECT
  /*%expand "A"*/*
FROM
  mst_printer A
WHERE
  A.facility_cd = /*facilityCd*/'1'
AND
  --A.client_key = /*clientKey*/'1'
  A.client_key like '%' || /*clientKey*/'1''' || '%'
AND
  A.is_del = '0'
ORDER BY
  A.printer_cd
;
