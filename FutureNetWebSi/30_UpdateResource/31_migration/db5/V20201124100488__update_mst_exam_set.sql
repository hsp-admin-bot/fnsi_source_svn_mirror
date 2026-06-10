-- 検査セットマスタ json デフォルト
ALTER TABLE ntss.mst_exam_set ALTER COLUMN exam_item_info SET DEFAULT '[]'::jsonb;