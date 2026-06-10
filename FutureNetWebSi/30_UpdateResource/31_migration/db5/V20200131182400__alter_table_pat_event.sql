-- 項目追加
ALTER TABLE mst_pat_event_sub_category ADD COLUMN IF NOT EXISTS template_cd bigint;
-- コメント追加
COMMENT ON COLUMN "mst_pat_event_sub_category"."template_cd" IS E'テンプレートコード';

-- 項目削除
ALTER TABLE mst_pat_event_data_template DROP COLUMN IF EXISTS category_cd; -- カテゴリ

-- コメント追加(不足修正)
COMMENT ON COLUMN "mst_pat_event_data_template"."is_intro_letter" IS E'紹介状フラグ';
