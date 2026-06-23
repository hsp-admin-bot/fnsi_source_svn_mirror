DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN (-303, -304, -305, -306, -307, -308, -310, -311);

INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-303, 'N_hosp', 'ind_dial', '', 'S', 'NEC標準(MegaOakHR)', '透析予約', '1', '{"protocolInfo": {"host": "172.30.15.142", "port": "8003", "timeout": 60, "protocol": "tshsocket", "retryMax": 3, "sendType": "send", "socket-type": "NEC_TSHPlus", "retryInterval": 10}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.953', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304, 'N_hosp', 'rst_dial', '', 'S', 'NEC標準(MegaOakHR)', '透析実績', '1', '{"protocolInfo": {"host": "172.30.15.142", "port": "8004", "timeout": 60, "protocol": "tshsocket", "retryMax": 3, "sendType": "send", "socket-type": "NEC_TSHPlus", "retryInterval": 10}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.956', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-305, 'N_hosp', 'rep_dial', 'pdf', 'S', 'NEC標準(MegaOakHR)', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '0', '1', -1, '2021-11-18 09:14:11.960', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-306, 'N_hosp', 'rep_dial', 'xml', 'S', 'NEC標準(MegaOakHR)', '透析レポート', '1', '{"protocolInfo": {"host": "192.168.1.104", "port": "21", "user": "fnw", "dummy": "false", "delete": "true", "address": "/root/nechr/dia_rep/$HOSP_PAT_ID", "password": "fnw", "protocol": "ftp", "permissionChange": "0", "renameWhenCopying": ".tmp"}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.963', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307, 'N_hosp', 'rep_dial', 'listxml', 'S', 'NEC標準(MegaOakHR)', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.965', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-308, 'N_hosp', 'rep_dial', 'tar', 'S', 'NEC標準(MegaOakHR)', '透析レポート', '1', '{"protocolInfo": {"host": "192.168.1.104", "port": "21", "user": "fnw", "dummy": "false", "delete": "true", "address": "/root/nechr/dia_rep/$HOSP_PAT_ID", "password": "fnw", "protocol": "ftp", "permissionChange": "0", "renameWhenCopying": ".tmp"}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.969', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-310, 'N_hosp', 'vit_cop', '', 'S', 'NEC標準(MegaOakHR)', 'バイタル連携', '1', '{"protocolInfo": {"host": "172.30.15.142", "port": "8006", "timeout": 60, "protocol": "tshsocket", "retryMax": 3, "sendType": "send", "socket-type": "NEC_TSHPlus", "retryInterval": 10}}'::jsonb, '1', '0', -1, '2021-11-18 09:14:11.975', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-311, 'N_hosp', 'rep_dial', '', 'S', 'NEC標準(MegaOakHR)', '透析レポート', '1', '{"protocolInfo": {"host": "192.168.1.104", "port": "21", "user": "fnw", "dummy": "false", "delete": "true", "address": "/root/nechr/dia_rep/$HOSP_PAT_ID", "password": "fnw", "protocol": "ftp", "permissionChange": "0", "renameWhenCopying": ".tmp"}}'::jsonb, '1', '0', -1, '2024-12-18 15:47:21.305', CURRENT_TIMESTAMP, 'HR');