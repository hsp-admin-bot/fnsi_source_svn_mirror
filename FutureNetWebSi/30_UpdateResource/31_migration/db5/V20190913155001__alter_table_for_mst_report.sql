-- 帳票マスタ
-- 項目追加
ALTER TABLE mst_report ADD COLUMN default_printer bigint;
-- コメント追加
COMMENT ON COLUMN "mst_report"."default_printer" IS E'プリンター初期値';
