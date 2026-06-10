select
  /*%expand "A" */*
from
  mnt_cardapp_port A
where
  A.facility_cd = /*mntCardappPort.facilityCd*/'000000'
  and (A.guid = /*mntCardappPort.guid*/'000000'
   or A.client_key = /*mntCardappPort.clientKey*/'000000')
;
