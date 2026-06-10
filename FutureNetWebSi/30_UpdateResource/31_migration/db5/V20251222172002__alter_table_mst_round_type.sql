-- 列の追加
ALTER TABLE mst_round_type
ADD COLUMN IF NOT EXISTS highlighting character varying(1) default '0';


-- コメント修正
COMMENT ON COLUMN "mst_round_type"."highlighting" IS E'強調表示';