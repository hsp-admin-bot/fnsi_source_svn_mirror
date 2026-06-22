DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN (-1201,-1202,-1203,-1204,-1205,-1206);

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1201, 'F_SX', 'rst_dial', '', 'S', '富士通LifeMark SX', '透析実績', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/coop/rst_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2025-05-27 13:22:17.826', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1202, 'F_SX', 'exam_ord', '', 'S', '富士通LifeMark SX', '血液検査依頼', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/coop/ExamOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, '2025-05-27 13:22:17.826', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1203, 'F_SX', 'rep_dial', 'pdf', 'S', '富士通LifeMark SX', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/nkkweb/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2025-08-01 10:50:20.491', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1204, 'F_SX', 'rep_dial', 'xml', 'S', '富士通LifeMark SX', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/nkkweb/dia_rep/$HOSP_PAT_ID", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2025-08-01 10:50:20.491', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1205, 'F_SX', 'rep_dial', 'listxml', 'S', '富士通LifeMark SX', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/nkkweb/dia_rep", "replace": "report_merge", "protocol": "file", "hospPatIdLen": "0", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2025-08-01 10:50:20.491', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1206, 'F_SX', 'rep_dial', 'tar', 'S', '富士通LifeMark SX', '透析レポート', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/pc/nkkweb/dia_rep", "replace": "report_merge", "protocol": "file", "renameWhenCopying": ""}}'::jsonb, '1', '0', -1, '2025-08-01 10:50:20.491', CURRENT_TIMESTAMP, 'F_SX');
