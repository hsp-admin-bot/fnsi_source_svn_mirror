--------------------------------------------------
-- 調整薬剤マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_medicine_mix ADD COLUMN medicate_timing_cd integer;
ALTER TABLE mst_medicine_mix ADD COLUMN procedure_cd integer;

-- コメント追加/変更
COMMENT ON COLUMN "mst_medicine_mix"."medicate_timing_cd" IS E'投与タイミングコード';
COMMENT ON COLUMN "mst_medicine_mix"."procedure_cd" IS E'手技コード';

