DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no IN (-1201, -1202);

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1201, 'F_SX', 'rst_dial', '', 'S', '富士通LifeMark SX', '透析実績', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/rst_dial", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1202, 'F_SX', 'exam_ord', '', 'S', '富士通LifeMark SX', '血液検査依頼', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ExamOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": "LOCK_"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');

