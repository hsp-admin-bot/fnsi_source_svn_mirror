insert into mst_printer
(
  facility_cd,
  client_key,
  printer_name,
  disp_printer_name,
  up_date,
  reg_date
)
VALUES
/*%for name : printerNames */
(/*entity.facilityCd*/null, /*entity.clientKey*/null, /*name.printerName*/'EPSON LP-S950', /*name.dispPrinterName*/'EPSON LP-S950', /*entity.upDate*/'2000-01-01 00:00:00', /*entity.regDate*/'2000-01-01 00:00:00')
  /*%if name_has_next */
/*# "," */
  /*%end */
/*%end*/
;