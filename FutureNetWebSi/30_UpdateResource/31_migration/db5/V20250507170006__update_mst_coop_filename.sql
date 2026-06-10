DELETE FROM mst_coop_filename
WHERE ctl_no IN (-301, -302, -304, -305);

INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-301, 'N_hosp', 'rep_dial', 'pdf', '[{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600019, "facilityCd": "facilityCd"}, "report_cd": 359}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-302, 'N_hosp', 'rep_dial', 'xml', '[{}]'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "facilityCd"}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304, 'N_hosp', 'rep_dial', 'tar', '[{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600019, "facilityCd": "facilityCd"}, "report_cd": 359}]'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "facilityCd"}}'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "tar", "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-305, 'N_hosp', 'rep_dial', '', '[{}]'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "facilityCd"}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');