delete from mst_machine where facility_cd = '431844' or facility_cd = '431833';

insert into mst_machine
  (facility_cd, machine_type_cd, machine_serial, machine_name, device_edge_no, is_ftp)
values
  ('431833', '999', 'TDC0000', '別テスト装置', 1, 0),
  ('431844', '999', 'TDC0001', 'テスト装置1', 1, 0),
  ('431844', '999', 'TDC0002', 'テスト装置2', 1, 1),
  ('431844', '999', 'TDC0003', 'テスト装置3', 1, 0),
  ('431844', '999', 'TDC0004', 'テスト装置4', 1, 1)
;

insert into mnt_machine_state 
  (facility_cd, machine_type_cd, machine_serial, model,  machine_name, process_state, machine_status, start_date, end_date)
values
  ('431833', '999', 'TDC0000', '999', '別テスト装置', '01', 0, NULL, NULL),
  ('431844', '999', 'TDC0001', '001', 'テスト装置1', '-1', 1, NULL, NULL),
  ('431844', '999', 'TDC0002', '001', 'テスト装置2', '00', 1, '2018/05/15 00:00:00', '2018/05/15 05:00:00'),
  ('431844', '999', 'TDC0003', '001', 'テスト装置3', '01', 2, '2018/05/15 00:00:00', '2018/05/15 05:00:00'),
  ('431844', '999', 'TDC0004', '001', 'テスト装置4', '10', 2, '2018/05/15 00:00:00', NULL)
  ;
