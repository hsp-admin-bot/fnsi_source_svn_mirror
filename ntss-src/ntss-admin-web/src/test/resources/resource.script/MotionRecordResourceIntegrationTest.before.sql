truncate table mnt_motion_record;
truncate table mnt_gathering_manage;

insert into mnt_motion_record
  (motion_record_no, facility_cd, machine_type_cd, machine_serial, event_reg_date, data_type, contents)
values
  (1234567890, '900001', '901', '90000001', '2001-01-01 00:00:01', 1, '{"key": "value"}'),
  (901, '900002', '902', '90000002', '2014-12-14 14:44:43', 3, '{"key1": "value1"}'),
  (902, '900002', '902', '90000002', '2014-12-13 14:44:44', 5, '{"key2": "value2"}'),
  (903, '900002', '902', '90000002', '2003-12-31 23:59:59', 6, '{"key3": "value3"}'),
  (904, '900002', '902', '90000002', '2014-12-12 14:44:44', 4, '{"key4": "value4"}')
 ;

insert into mst_facility
   (facility_cd, facility_name, facility_name_kana, prefectures_cd, department_cd, alive_moni_interval)
values
   ('000001', '施設名１', 'シセツカナメイ１', '01', 'S1A1', 1)
;

insert into mst_user
  (user_id, is_provisional)
values
  (2, 0)
;

 INSERT INTO mnt_gathering_manage (gathering_manage_no, facility_cd, gathering_status, gathering_info, ope_info, parent_manage_no, user_id, reg_date, up_date) VALUES
  (1, '000001', 0, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]', 1, NULL, 1, '2017-12-05 16:33:48', '2017-12-06 11:44:18'),
  (2, '000001', 1, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]', 1, NULL, 1, '2017-12-01 16:35:02', '2017-12-06 18:35:02'),
  (3, '000001', 2, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]', 1, NULL, 1, '2017-12-05 16:38:52', '2017-12-06 17:12:40'),
  (4, '000001', 0, '[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]', 1, NULL, 1, '2017-12-01 16:35:02', '2017-12-07 18:35:02');
