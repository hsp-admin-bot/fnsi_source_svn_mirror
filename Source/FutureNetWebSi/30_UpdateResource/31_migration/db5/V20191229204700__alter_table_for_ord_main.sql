-- 列の追加
ALTER TABLE ord_main ADD COLUMN ind_dw numeric(5,2);

-- コメント修正
COMMENT ON COLUMN "ord_main"."ind_dw" IS E'指示：DW';