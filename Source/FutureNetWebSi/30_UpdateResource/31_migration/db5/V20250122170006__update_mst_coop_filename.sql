DELETE FROM ntss.mst_coop_filename
WHERE ctl_no IN (-301, -302, -303, -304, -305);

INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-301, 'N_hosp', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "sqlCode": -600019, "facilityCd": "N_posp"}, "report_cd": 359}, {"name": {"ordNo": 0, "sqlCode": -600019, "facilityCd": "N_posp"}, "report_cd": 359}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-302, 'N_hosp', 'rep_dial', 'xml', '[{}]'::jsonb, '{"name": {"ordNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "N_posp"}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-303, 'N_hosp', 'rep_dial', 'listxml', '[{}]'::jsonb, '{"name": {"key": 2, "ordNo": 0, "patId": 0, "sqlCode": -600009}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2023-06-16 17:44:46.415', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304, 'N_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "sqlCode": -600019, "facilityCd": "N_posp"}, "report_cd": 359}, {"name": {"ordNo": 0, "sqlCode": -600019, "facilityCd": "N_posp"}, "report_cd": 359}]'::jsonb, '{"name": {"ordNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "N_posp"}}'::jsonb, '{"name": {"ordNo": 0, "sqlCode": -600018, "extension": "tar", "facilityCd": "N_posp"}}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-305, 'N_hosp', 'rep_dial', '', '[{}]'::jsonb, '{"name": {"ordNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "N_posp"}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');