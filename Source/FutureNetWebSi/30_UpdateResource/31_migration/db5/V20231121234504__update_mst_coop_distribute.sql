DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no = -409
;

INSERT INTO ntss.mst_coop_distribute
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_vender, description, is_editable, distribute_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-409, 'P_hosp', 'exam_ord', '', 'S', 'Medicom', '検査オーダ', '1', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "/mnt/share/ExamOrder", "replace": "report_merge", "protocol": "file", "renameWhenCopying": ".tmp"}}'::jsonb, '1', '0', -1, '2020-01-16 10:00:18.164', CURRENT_TIMESTAMP, '');
