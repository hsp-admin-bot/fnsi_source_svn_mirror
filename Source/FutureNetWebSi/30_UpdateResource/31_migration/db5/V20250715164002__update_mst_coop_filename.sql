DELETE FROM mst_coop_filename
WHERE ctl_no IN (-501, -502, -503, -504);

INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-501, 'S_hosp', 'rep_dial', 'pdf', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-502, 'S_hosp', 'rep_dial', 'xml', '[{}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-503, 'S_hosp', 'rep_dial', 'listxml', '[{}]'::jsonb, '{"name": {"key": 2, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-504, 'S_hosp', 'rep_dial', 'tar', '[{"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}, {"name": {"ordNo": 0, "patId": 0, "sqlCode": -400008}}]'::jsonb, '{"name": {"key": 1, "ordNo": 0, "patId": 0, "sqlCode": -400009}}'::jsonb, '{"name": {"sqlCode": -400007}}'::jsonb, '1', '0', -1, '2021-09-01 07:38:43.793', CURRENT_TIMESTAMP, 'SSI');