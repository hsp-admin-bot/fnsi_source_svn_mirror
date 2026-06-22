update
  mst_printer
set
  is_del = '0',
  up_date = /*entity.upDate*/'2000-01-01 00:00:00'
where
  facility_cd = /*entity.facilityCd*/1
  and client_key like '%' || /*entity.clientKey*/'1''' || '%'
  and printer_name = /*entity.printerName*/''
;
