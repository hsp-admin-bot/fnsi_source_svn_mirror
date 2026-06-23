-- 加算情報
ALTER TABLE ord_main ADD COLUMN IF NOT EXISTS addition_info jsonb;
-- コメント追加
COMMENT ON COLUMN "ord_main"."addition_info" IS E'加算情報';