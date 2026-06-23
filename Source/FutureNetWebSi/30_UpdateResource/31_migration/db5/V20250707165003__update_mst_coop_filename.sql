DELETE FROM mst_coop_filename
WHERE ctl_no IN (-101, -104, -201, -204, -205, -207, -301, -304, -401, -404, -501, -504, -601, -604, -701, -704);

INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-101, 'nkknkk', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'NKK');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-104, 'nkknkk', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{"name": {"sqlCode": -400007}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'NKK');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-201, 'F_hosp', 'rep_dial', 'nkkpdf', '[{"name": {"ctlNo": 0, "ordNo": 0, "sqlCode": -62}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', 1, '2022-04-04 16:37:06.365', CURRENT_TIMESTAMP, 'GX');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-204, 'F_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -100008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -100008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -100009}}'::jsonb, '{"name": {"sqlCode": -100007}}'::jsonb, '1', '0', -1, '2021-03-09 14:04:13.000', CURRENT_TIMESTAMP, 'GX');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-205, 'F_hosp', 'rep_dial', 'pdf', '[{"name": {"ctlNo": 0, "ordNo": 0, "sqlCode": -62}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', 1, '2023-06-16 17:46:14.773', CURRENT_TIMESTAMP, 'GX');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-207, 'F_hosp', 'rep_dial', 'necpdf', '[{"name": {"ctlNo": 0, "ordNo": 0, "sqlCode": -62}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', 1, '2023-06-16 17:46:14.773', CURRENT_TIMESTAMP, 'GX');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-301, 'N_hosp', 'rep_dial', 'pdf', '[{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600019, "facilityCd": "facilityCd"}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304, 'N_hosp', 'rep_dial', 'tar', '[{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600019, "facilityCd": "facilityCd"}}]'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "xml", "facilityCd": "facilityCd"}}'::jsonb, '{"name": {"key0": "key0", "ctlNo": 0, "sqlCode": -600018, "extension": "tar", "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2024-12-10 08:06:15.568', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-401, 'P_hosp', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -300008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -300008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-03-09 14:04:13.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-404, 'P_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -300008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -300008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -300009}}'::jsonb, '{"name": {"sqlCode": -300007}}'::jsonb, '1', '0', -1, '2021-03-09 14:04:13.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501, 'S_hosp', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -500008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -500008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504, 'S_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -500008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -500008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -500009}}'::jsonb, '{"name": {"sqlCode": -500007}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-601, 'C_hosp', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -200008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -200008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-604, 'C_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -200008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -200008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -200009}}'::jsonb, '{"name": {"sqlCode": -200007}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'CSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-701, 'NEC-iS', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -700008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -700008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2023-06-16 17:44:51.893', CURRENT_TIMESTAMP, 'IS');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-704, 'NEC-iS', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -700008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -700008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -700009}}'::jsonb, '{"name": {"sqlCode": -700007}}'::jsonb, '1', '0', -1, '2023-06-16 17:44:51.893', CURRENT_TIMESTAMP, 'IS');