--------------------------------------------------
-- ユーザーマスター
--------------------------------------------------
-- テンプレートログ
ALTER TABLE mst_user ADD COLUMN tmp_log_search_condition jsonb;
-- テンプレートログ
COMMENT ON COLUMN "mst_user"."tmp_log_search_condition" IS E'テンプレートログ';
