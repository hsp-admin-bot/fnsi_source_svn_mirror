SELECT
  printer_cd,
  client_key,
  printer_name
FROM
  mst_printer
WHERE
  facility_cd = /*entity.facilityCd*/1
AND client_key like '%' || /*entity.clientKey*/1'' || '%'
AND 
 printer_name not in (
 /*%for name : printerNames */
 /*name*/'EPSON LP-S950'
   /*%if name_has_next */
 /*# "," */
   /*%end */
 /*%end*/
   )
AND
  is_del = '0'
ORDER BY
  printer_cd
;