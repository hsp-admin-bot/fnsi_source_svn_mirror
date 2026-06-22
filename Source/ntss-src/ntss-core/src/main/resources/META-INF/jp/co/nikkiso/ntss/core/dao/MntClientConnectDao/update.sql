update
  mnt_client_connect
set
  up_date = CURRENT_TIMESTAMP(3)
where
  ip_address = /*mntClientConnect.ipAddress*/'127.0.0.1'
and
  facility_cd = /*mntClientConnect.facilityCd*/'000000'
;
