DELETE FROM mst_coop_filename WHERE ctl_no IN 
(-1203,-1204,-1201,-1202);

INSERT INTO ntss.mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1201, 'F_SX', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}, "report_cd": 359}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}, "report_cd": 359}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1202, 'F_SX', 'rep_dial', 'xml', '[{}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1203, 'F_SX', 'rep_dial', 'listxml', '[{}]'::jsonb, '{"name": {"key": 2, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1204, 'F_SX', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}, "report_cd": 359}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}, "report_cd": 359}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{"name": {"sqlCode": -400007}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
