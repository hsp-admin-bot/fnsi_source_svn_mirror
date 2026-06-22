update
  mnt_cardapp_port
set
  client_key =/*mntCardappPort.clientKey*/'000000'
  /*%if mntCardappPort.port != null */
  , port =/*mntCardappPort.port*/0
  /*%end */
  /*%if mntCardappPort.port != null */
  , up_date = CURRENT_TIMESTAMP(3)
  /*%end */
where
  facility_cd = /*mntCardappPort.facilityCd*/'000000'
  and guid = /*mntCardappPort.guid*/'000000'
;
