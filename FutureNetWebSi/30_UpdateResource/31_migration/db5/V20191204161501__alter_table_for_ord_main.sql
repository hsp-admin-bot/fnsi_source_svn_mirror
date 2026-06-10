--------------------------------------------------
-- オーダメイン
-- 確定フラグ列を追加
--------------------------------------------------
-- カラム追加
ALTER TABLE ord_main ADD COLUMN is_confirm character varying(1) DEFAULT '0';
-- コメント追加
COMMENT ON COLUMN "ord_main"."is_confirm" IS E'確定フラグ';
