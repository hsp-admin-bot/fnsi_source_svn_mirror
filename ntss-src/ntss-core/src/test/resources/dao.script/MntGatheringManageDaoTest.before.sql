TRUNCATE TABLE mnt_gathering_manage;

insert into mst_facility
   (facility_cd, facility_name, facility_name_kana, department_cd, prefectures_cd)
values
   ('900001', 'テスト施設1', 'テストシセツ1', '9001', '01')
;

INSERT INTO mnt_gathering_manage (gathering_manage_no, facility_cd, gathering_status, gathering_info, ope_info, parent_manage_no, user_id, reg_date, up_date) VALUES
  (1, '000001', 0, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]', 1, NULL, 1, '2017-12-05 16:33:48', '2017-12-06 11:44:18'),
  (2, '000001', 1, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]', 1, NULL, 1, '2017-12-01 16:35:02', '2017-12-06 18:35:02'),
  (3, '000001', 2, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]', 1, NULL, 1, '2017-12-05 16:38:52', '2017-12-06 17:12:40'),
  (4, '000001', 0, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]', 1, NULL, 1, '2017-12-01 16:35:02', '2017-12-07 18:35:02');
