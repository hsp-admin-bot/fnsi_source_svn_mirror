-- 列の追加
ALTER TABLE pat_main
ADD COLUMN IF NOT EXISTS wheel_chair_cd bigint;


-- コメント修正
COMMENT ON COLUMN "pat_main"."wheel_chair_cd" IS E'車いすコード';