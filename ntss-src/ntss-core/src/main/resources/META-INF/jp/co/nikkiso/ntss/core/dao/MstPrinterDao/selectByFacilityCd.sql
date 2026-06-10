SELECT
  --/*%expand*/*
  printer_cd
,facility_cd
,client_key
,printer_name
,disp_printer_name
,is_disp
,is_del
,reg_date
,up_date

FROM
  mst_printer
WHERE
  facility_cd = /*facilityCd*/'1'
AND
  is_del = '0'
ORDER BY
  printer_cd
;
