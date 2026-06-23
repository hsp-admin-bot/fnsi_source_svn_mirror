-- 列の追加
ALTER TABLE ntss.mst_exam_set
ADD COLUMN IF NOT EXISTS order_class jsonb DEFAULT '["0","1","2"]' NOT NULL;

-- コメント追加
COMMENT ON COLUMN "mst_exam_set"."order_class" IS E'検査区分';
