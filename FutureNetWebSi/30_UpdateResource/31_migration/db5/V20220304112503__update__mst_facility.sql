UPDATE
  mst_facility
SET
  vpn_set = '0',
  up_date = now()
WHERE
  vpn_set IS NULL
OR
  vpn_set = ''
;
