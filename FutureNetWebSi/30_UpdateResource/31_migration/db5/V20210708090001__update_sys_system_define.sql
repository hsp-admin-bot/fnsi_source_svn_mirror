--sys_system_defineのvalueを修正
update sys_system_define set value = '{"vpn_key": ["vpn", "vpn1", "vpn2"]}', is_enable='1'  where ctl_no = 1009