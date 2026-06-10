TRUNCATE TABLE mst_device_edge;
INSERT INTO mst_device_edge (serial_no, device_edge_no, facility_cd, device_name, reg_date, up_date) VALUES
  (1, 1, '000001', 'deviceA1', '2019-09-13 00:01:00', '2019-09-13 10:01:00'),
  (2, 1, '000002', 'deviceB1', '2019-09-13 00:02:00', '2019-09-13 10:02:00'),
  (3, 1, '000003', 'deviceC1', '2019-09-13 00:03:00', '2019-09-13 10:03:00'),
  (4, 1, '000004', 'deviceD1', '2019-09-13 00:04:00', '2019-09-13 10:04:00'),
  (5, 1, '000005', 'deviceE1', '2019-09-13 00:05:00', '2019-09-13 10:05:00'),
  (6, 2, '000001', 'deviceA2', '2019-09-13 00:06:00', '2019-09-13 10:06:00'),
  (7, 2, '000002', 'deviceB2', '2019-09-13 00:07:00', '2019-09-13 10:07:00'),
  (8, 2, '000003', 'deviceC2', '2019-09-13 00:08:00', '2019-09-13 10:08:00')
;

TRUNCATE TABLE mnt_motion_record;
INSERT INTO mnt_motion_record
  (motion_record_no, event_reg_date, m_notice_status, facility_cd, machine_type_cd, machine_serial, data_type, contents, remarks)
VALUES
  (21,  '2018-03-29 12:13:14',  1, '000001', '901', '90000001', 1, '{"key":"value"}', ''),
  (52,  '2018-05-02 09:47:14', -1, '000002', '901', '90000001', 1, '{"key":"value"}', ''),
  (934, '2018-03-29 12:13:14', -1, '000001', '901', '90000001', 1, '{"key":"value"}', ''),
  (935, '2018-03-28 11:22:33', -1, '000001', '901', '90000001', 1, '{"key":"value"}', '')
;
SELECT setval('mnt_motion_record_motion_record_no_seq', 1);
