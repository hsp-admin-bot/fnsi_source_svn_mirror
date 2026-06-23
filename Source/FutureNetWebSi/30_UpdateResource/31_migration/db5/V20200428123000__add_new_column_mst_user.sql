--mst_userに列を追加
ALTER TABLE
  mst_user
ADD COLUMN is_consent numeric(1,0) DEFAULT 0,  --個人情報取扱い同意フラグ
ADD COLUMN consent_date timestamp(3)  --個人情報取扱い同意日時
;

COMMENT ON COLUMN "mst_user"."is_consent" IS E'個人情報取扱い同意フラグ';
COMMENT ON COLUMN "mst_user"."consent_date" IS E'個人情報取扱い同意日時';
