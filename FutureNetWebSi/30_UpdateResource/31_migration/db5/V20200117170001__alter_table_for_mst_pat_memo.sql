-- 列の追加
ALTER TABLE mst_pat_memo ADD COLUMN is_disp character varying(1) default '1';
ALTER TABLE mst_pat_memo ADD COLUMN is_del character varying(1) default '0';

-- コメント修正
COMMENT ON COLUMN "mst_pat_memo"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_memo"."is_del" IS E'削除フラグ';