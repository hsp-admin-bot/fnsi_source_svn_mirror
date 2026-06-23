ALTER TABLE ntss.mst_monitor_graph ADD left_graph_upper_limit int4 NULL;
COMMENT ON COLUMN ntss.mst_monitor_graph.left_graph_upper_limit IS '左グラフ上限';
ALTER TABLE ntss.mst_monitor_graph ADD right_graph_upper_limit int4 NULL;
COMMENT ON COLUMN ntss.mst_monitor_graph.right_graph_upper_limit IS '右グラフ上限';
ALTER TABLE ntss.mst_monitor_graph ADD left_graph_lower_limit int4 NULL;
COMMENT ON COLUMN ntss.mst_monitor_graph.left_graph_lower_limit IS '左グラフ下限';
ALTER TABLE ntss.mst_monitor_graph ADD right_graph_lower_limit int4 NULL;
COMMENT ON COLUMN ntss.mst_monitor_graph.right_graph_lower_limit IS '右グラフ下限';
