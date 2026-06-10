DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN(-101,-102,-103,-104,-109)
;

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-101, 'nkknkk', 'profile', '', 'S', '日機装', '患者プロファイル', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/fn-sv1/request", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.683', CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-102, 'nkknkk', 'exam_rst', '', 'S', '日機装', '検査結果(※未開発)', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/fn-sv2/request", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.683', CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-103, 'nkknkk', 'ind_dial', '', 'S', '日機装', '透析予約', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ind_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.683', CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-104, 'nkknkk', 'rst_dial', '', 'S', '日機装', '透析実績', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/rst_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.683', CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-109, 'nkknkk', 'exam_ord', '', 'S', '日機装', '検査オーダ', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ExamOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.683', CURRENT_TIMESTAMP, '');
