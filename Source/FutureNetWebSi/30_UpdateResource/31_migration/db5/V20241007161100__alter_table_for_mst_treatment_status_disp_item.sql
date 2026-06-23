-- 列の削除
ALTER TABLE mst_treatment_status_disp_item
DROP COLUMN IF EXISTS unit;

-- 列の追加
ALTER TABLE mst_treatment_status_disp_item
ADD COLUMN IF NOT EXISTS unit character varying;

-- コメント修正
COMMENT ON COLUMN "mst_treatment_status_disp_item"."unit" IS E'単位';
