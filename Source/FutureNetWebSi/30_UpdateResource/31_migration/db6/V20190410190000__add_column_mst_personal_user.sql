--mst_personal_userに列を追加
ALTER TABLE
  mst_personal_user
ADD COLUMN administrator numeric(2,0)  --管理者フラグ
;

COMMENT ON COLUMN "mst_personal_user"."administrator" IS E'管理者フラグ';
