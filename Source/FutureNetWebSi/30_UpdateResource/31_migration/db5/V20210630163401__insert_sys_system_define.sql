INSERT INTO sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  2000, 
  '003', 
  'VPN URLキー', 
  '{"vpn_key": ["vpn", "aaa", "bbb"]}', 
  'URLにvpn_keyが含まれている場合は、vpnです。', 
  '0', 
  current_timestamp
);