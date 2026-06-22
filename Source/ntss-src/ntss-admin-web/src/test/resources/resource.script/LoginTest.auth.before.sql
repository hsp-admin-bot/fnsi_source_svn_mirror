truncate table mst_user_authentication;
truncate table mst_facility_hash;

INSERT INTO mst_user_authentication (user_id, facility_cd, disp_user_id, user_password, failure_cnt, reg_date, up_date) VALUES
  (900000000001, '900001', '800000000001', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (900000000002, '900001', '800000000002', '$2a$10$gJv8X8lhSPyjQjMqn1Z80uT4vz0G.z83Lh2cNtMu4Kh2Iu8SqOR2u', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405');

insert into mst_facility_hash
  (facility_cd, hash_value)
values
  ('900001', '$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy'),
  ('900002', '$2a$10$ZjibZwxMlvxV8wRUQPDmeOlmGIU7092XDEU6sTVUha0si/Qg534rC'),
  ('900003', '$2a$10$9838a90usCPoAHdjrwb6c.GbjO1YuPhrgv/6bIm7cxbXf5Q4nVtkG')
;
