SELECT
  printer_cd,
  facility_cd,
  client_key,
  printer_name,
  disp_printer_name,
  is_del
FROM
  mst_printer
WHERE
  facility_cd = /*facilityCd*/'1'
ORDER BY
  printer_cd
;
