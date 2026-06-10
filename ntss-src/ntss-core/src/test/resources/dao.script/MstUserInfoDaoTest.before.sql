insert into mst_user
  (user_cd, facility_cd, user_name, user_type, user_email_address, user_password)
values
  (90000001, '000001', 'testName', '1', 'testAddress', 'testPassword')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_user
ADD COLUMN dummy character varying(1) -- ダミー列
;
