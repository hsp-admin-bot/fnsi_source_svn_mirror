DELETE FROM mst_coop_distribute WHERE ctl_no IN (
 -1109
  );

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1109, 'Secom', 'accept', '', 'S', 'セコム', '受付情報', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/work/secom/accept", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');