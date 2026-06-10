update
  mst_printer
set
  client_key = /*clientKey*/1,
  is_disp = '0',
  is_del = '1',
  up_date = now()
where
  printer_cd = /*printerCd*/1
;
