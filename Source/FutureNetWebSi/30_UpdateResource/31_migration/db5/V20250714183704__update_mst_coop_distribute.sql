DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no=-1112;

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1112, 'Secom', 'rad_ord', '', 'S', 'セコム', '放射線オーダ', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/RadOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2025-06-19 10:54:36.662', CURRENT_TIMESTAMP, 'Secom');