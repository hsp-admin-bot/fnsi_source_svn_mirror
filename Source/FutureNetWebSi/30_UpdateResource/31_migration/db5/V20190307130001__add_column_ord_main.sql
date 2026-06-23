-- 列名の修正
ALTER TABLE ord_main ADD COLUMN rst_dw numeric(5,2);

-- コメント修正
COMMENT ON COLUMN "ord_main"."rst_dw" IS E'実績：DW';
