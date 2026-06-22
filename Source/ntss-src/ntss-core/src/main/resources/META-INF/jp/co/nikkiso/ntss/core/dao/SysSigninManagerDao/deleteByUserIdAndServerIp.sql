delete from
  sys_signin_manager
where
  user_id = /*userId*/0
and
  server_ip = /*serverIp*/'127.0.0.1'
and
  facility_cd = /*facilityCd*/'0'
;
