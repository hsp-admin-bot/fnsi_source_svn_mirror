TRUNCATE TABLE mst_user_authentication;

INSERT INTO mst_user_authentication (user_id, facility_cd, disp_user_id, user_password, failure_cnt, reg_date, up_date) VALUES
  -- getUserAccountInfo
  (1, 'test', 'userAccount', 'password', 2, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (2, 'test', 'userAccount2', 'password', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  -- alterProvisionalInfo
  (900000000001, '900001', '800000000001', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (900000000002, '900001', '800000000003', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (900000000003, '900001', '800000000004', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (900000000004, '900001', '800000000005', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  -- editUserAccountInfo
  (999900000001, '999001', '999900000901', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (999900000002, '999002', '999900000902', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 6, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405');
