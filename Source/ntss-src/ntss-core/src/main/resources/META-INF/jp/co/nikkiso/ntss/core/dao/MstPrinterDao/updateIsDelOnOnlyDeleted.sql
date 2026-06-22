update
  mst_printer
set
  is_del = '1',
  up_date = /*entity.upDate*/'2000-01-01 00:00:00'
where
  facility_cd = /*entity.facilityCd*/1
  and client_key = /*entity.clientKey*/1
  and
--printer_name not in (
--/*%for name : printerNames */
--/*name*/'EPSON LP-S950'
--  /*%if name_has_next */
--/*# "," */
--  /*%end */
--/*%end*/
--  )
 printer_name = /*printerNames*/''
;
