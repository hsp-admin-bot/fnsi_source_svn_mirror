DELETE FROM ntss.mst_coop_filename
WHERE ctl_no IN (-1101, -1102, -1103);

INSERT INTO mst_coop_filename
(ctl_no, facility_cd, coop_cd, coop_cd_index, pdf_name, dump_name, compression_name, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1101, 'Secom', 'rep_dial', 'pdf', '[{"name": {"key0": 0, "ctlNo": 0, "ordNo": 0, "patId": 0, "sqlCode": -1108000, "facilityCd": 0}}]'::jsonb, '{}'::jsonb, '{}'::jsonb, '1', '0', -1, '2025-06-19 10:54:36.697', CURRENT_TIMESTAMP, 'Secom');