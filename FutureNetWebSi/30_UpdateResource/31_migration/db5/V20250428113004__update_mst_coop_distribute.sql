DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN (-1101, -1102, -1103, -1104, -1105, -1106, -1107, -1108);

INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1101, 'Secom', 'rep_dial', 'pdf', 'S', 'セコム', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1102, 'Secom', 'rep_dial', 'xml', 'S', 'セコム', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1103, 'Secom', 'rep_dial', 'listxml', 'S', 'セコム', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/dia_rep", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104, 'Secom', 'profile', '', 'S', 'セコム', '患者プロファイル', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/fn-sv1/request", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1105, 'Secom', 'exam_rst', '', 'S', 'セコム', '検査結果(※未開発)', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/fn-sv2/request", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1106, 'Secom', 'ind_dial', '', 'S', 'セコム', '透析予約', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ind_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107, 'Secom', 'rst_dial', '', 'S', 'セコム', '透析実績', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/rst_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1108, 'Secom', 'exam_ord', '', 'S', 'セコム', '検査オーダ', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ExamOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');