-- 列の追加
ALTER TABLE mst_exam_item
ADD COLUMN IF NOT EXISTS is_in_hospital character varying(1);

-- コメント修正
COMMENT ON COLUMN "mst_exam_item"."is_in_hospital" IS E'院外院内フラグ';

update mst_exam_item set is_in_hospital = '0' where is_in_hospital is null;