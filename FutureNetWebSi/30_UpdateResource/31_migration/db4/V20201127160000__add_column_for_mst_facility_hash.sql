--mst_facility_hashに列を追加
ALTER TABLE
  mst_facility_hash
ADD COLUMN IF NOT EXISTS url_signin character varying(1) DEFAULT 0;  --URLサインイン設定

COMMENT ON COLUMN "mst_facility_hash"."url_signin" IS E'URLサインイン設定';

ALTER TABLE
  mst_facility_hash
ADD COLUMN IF NOT EXISTS url_signin_secretkey character varying DEFAULT NULL;  --URLサインイン秘密鍵

COMMENT ON COLUMN "mst_facility_hash"."url_signin_secretkey" IS E'URLサインイン秘密鍵';
