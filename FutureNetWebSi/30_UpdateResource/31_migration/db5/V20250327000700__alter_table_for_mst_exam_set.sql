-- デフォルト列の削除
ALTER TABLE mst_exam_set
DROP COLUMN IF EXISTS is_in_hospital;