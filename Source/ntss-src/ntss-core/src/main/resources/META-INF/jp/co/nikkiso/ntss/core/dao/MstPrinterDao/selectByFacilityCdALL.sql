SELECT
  /*%expand*/*
FROM
  mst_printer
WHERE
  facility_cd = /*facilityCd*/'1'
ORDER BY
  printer_cd
;