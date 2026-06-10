--------------------------------------------------
-- 治療方法マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_treatment ADD COLUMN report_graph_setting jsonb;

-- コメント追加/変更
COMMENT ON COLUMN "mst_treatment"."report_graph_setting" IS E'帳票グラフ設定';
