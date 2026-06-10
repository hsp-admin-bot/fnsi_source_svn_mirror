-- 帳票マスタ
-- 項目追加
ALTER TABLE mst_report ADD COLUMN extraction_condition jsonb;
-- コメント追加
COMMENT ON COLUMN "mst_report"."extraction_condition" IS E'抽出条件';
