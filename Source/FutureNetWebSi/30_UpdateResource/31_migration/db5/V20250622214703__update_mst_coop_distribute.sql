DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no in (-1111);
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111, 'Secom', 'karte_ord', '', 'S', 'セコム', 'カルテオーダ', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/work/secom/karte_ord", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2025-04-29 13:39:45.664', '2025-04-29 13:39:45.664', 'Secom');