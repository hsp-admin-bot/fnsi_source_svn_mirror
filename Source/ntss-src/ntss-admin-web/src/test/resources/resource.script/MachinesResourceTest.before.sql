insert into mnt_machine_state
  (facility_cd, machine_type_cd, machine_serial, model,  machine_name, bed_name, process_state, m_notice_cnt, preventive_mainte_cnt, is_preventive_mainte)
values
  ('900001', '999', '90000001', '099', 'テスト装置', 'テストベッド', '01', '0', '0', '0'),
  ('900002', '901', '90000041', '004', 'ESMマシン1', 'ESMベッド1', '-1', '1', '2', '1'),
  ('900002', '902', '90000042', '003', 'ESMマシン2', 'ESMベッド2', '00', '0', '5', '2'),
  ('900002', '903', '90000043', '002', 'ESMマシン3', 'ESMベッド3', '01', '3', '0', '3'),
  ('900002', '904', '90000044', '001', 'ESMマシン4', 'ESMベッド4', '10', '4', '2', '4')
  ;

insert into mst_facility
  (facility_cd, facility_name, prefectures_cd, department_cd)
values
  ('900001', 'テスト施設名', '01', '9001'),
  ('900002', 'ESMクリニック', '01', '9002')
;

insert into mst_machine
  (facility_cd, machine_type_cd, machine_serial, machine_name, com_format_cd, com_type, device_edge_no, is_ftp, is_va, version)
values
  ('900001', '999', '90000001', 'テスト装置', 'A', '0', '1', '0', '0', '1'),
  ('900002', '901', '90000041', 'ESMマシン1', 'B', '1', '2', '0', '0', '2'),
  ('900002', '902', '90000042', 'ESMマシン2', 'C', '2', '3', '0', '0', '3'),
  ('900002', '903', '90000043', 'ESMマシン3', 'D', '3', '4', '1', '0', '4'),
  ('900002', '904', '90000044', 'ESMマシン4', 'E', '1', '5', '1', '0', '5')
;

insert into mst_machine_type
  (machine_type_cd, machine_type)
values
  ('901', 'DAB-A'),
  ('902', 'DAB-B'),
  ('903', 'DAB-C'),
  ('904', 'DAB-D'),
  ('999', 'DAD-10')
;
