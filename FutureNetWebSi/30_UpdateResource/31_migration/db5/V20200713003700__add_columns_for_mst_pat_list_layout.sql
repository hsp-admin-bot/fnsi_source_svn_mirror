--mst_pat_list_layoutに列を追加
ALTER TABLE
  mst_pat_list_layout
  ADD COLUMN IF NOT EXISTS template_cd integer --テンプレートコード
;
COMMENT ON COLUMN "mst_pat_list_layout"."template_cd" IS E'テンプレートコード';
