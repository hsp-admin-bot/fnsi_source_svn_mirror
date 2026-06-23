-- テーブル作成
ALTER TABLE mst_addition 
  ADD COLUMN addition_dialysis_time integer --算定治療時間
;

--コメント追加
COMMENT ON COLUMN "mst_addition"."addition_dialysis_time" IS E'算定治療時間';
