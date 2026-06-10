--mst_userに列を追加
ALTER TABLE
  mst_user
ADD COLUMN secret_key character varying,  --秘密鍵
ADD COLUMN is_set_qr_code numeric(1,0)  --秘密キー設定フラグ
;

COMMENT ON COLUMN "mst_user"."secret_key" IS E'秘密鍵';
COMMENT ON COLUMN "mst_user"."is_set_qr_code" IS E'秘密キー設定フラグ';
