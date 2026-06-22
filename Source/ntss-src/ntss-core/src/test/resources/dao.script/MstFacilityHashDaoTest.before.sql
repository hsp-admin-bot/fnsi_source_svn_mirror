truncate table mst_facility_hash;

insert into mst_facility_hash
  (facility_cd, hash_value)
values
  ('900001', '$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy'),
  ('900002', '$2a$10$ZjibZwxMlvxV8wRUQPDmeOlmGIU7092XDEU6sTVUha0si/Qg534rC'),
  ('900003', '$2a$10$9838a90usCPoAHdjrwb6c.GbjO1YuPhrgv/6bIm7cxbXf5Q4nVtkG')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_facility_hash
ADD COLUMN dummy character varying(1) -- ダミー列
;


