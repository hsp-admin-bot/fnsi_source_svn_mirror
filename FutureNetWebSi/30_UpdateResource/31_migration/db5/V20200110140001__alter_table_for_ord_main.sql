-- 項目追加
ALTER TABLE ord_main
 ADD COLUMN rst_purification_cnt integer;
-- コメント追加
COMMENT ON COLUMN "ord_main"."rst_purification_cnt" IS E'実績：特殊浄化回数';