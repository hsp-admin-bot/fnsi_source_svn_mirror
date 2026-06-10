--mst_facility_hashに列を追加
ALTER TABLE
  mst_facility_hash
ADD COLUMN account_lock_setting character varying(1) DEFAULT '1';  --アカウントロック設定

COMMENT ON COLUMN "mst_facility_hash"."account_lock_setting" IS E'アカウントロック設定';

ALTER TABLE
  mst_facility_hash
ADD COLUMN failure_cnt numeric(3,0) DEFAULT 5;  --サインイン失敗回数

COMMENT ON COLUMN "mst_facility_hash"."failure_cnt" IS E'サインイン失敗回数';

ALTER TABLE
  mst_facility_hash
ADD COLUMN otp_failure_cnt numeric(3,0) DEFAULT 5;  --2要素認証失敗回数

COMMENT ON COLUMN "mst_facility_hash"."otp_failure_cnt" IS E'2要素認証失敗回数';