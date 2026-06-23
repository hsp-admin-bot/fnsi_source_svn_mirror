--add グラフセット graph_set  列
ALTER TABLE ntss.mst_exam_set ADD graph_set varchar NULL;
COMMENT ON COLUMN ntss.mst_exam_set.graph_set IS 'グラフセット';