-- 列の追加
ALTER TABLE mst_facility_hash
ADD COLUMN IF NOT EXISTS is_signin_disp character varying(1) default '1';


-- コメント修正
COMMENT ON COLUMN "mst_facility_hash"."is_signin_disp" IS E'サインインIF表示設定';