--------------------------------------------------
-- 帳票マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_report ADD COLUMN report_type integer;
-- コメント追加
COMMENT ON COLUMN "mst_report"."report_type" IS E'帳票区分';
