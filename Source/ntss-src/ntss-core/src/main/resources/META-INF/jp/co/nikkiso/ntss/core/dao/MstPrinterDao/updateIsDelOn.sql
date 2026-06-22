update
  mst_printer
set
  is_del = '1',
  up_date = /*entity.upDate*/'2000-01-01 00:00:00'
where
  facility_cd = /*entity.facilityCd*/1
  and client_key = /*entity.clientKey*/1
;
