DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN (-1102, -1103);

INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1102, 'Secom', 'rep_dial', '', 'S', 'セコム', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2025-06-19 10:54:36.662', CURRENT_TIMESTAMP, 'Secom');
