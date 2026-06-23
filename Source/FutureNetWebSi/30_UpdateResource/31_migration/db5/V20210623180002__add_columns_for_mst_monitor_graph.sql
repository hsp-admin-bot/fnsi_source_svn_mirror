ALTER TABLE ntss.mst_monitor_graph ADD left_is_mst_monitor int4 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_monitor_graph.left_is_mst_monitor IS '左項目元';
ALTER TABLE ntss.mst_monitor_graph ADD right_is_mst_monitor int4 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_monitor_graph.right_is_mst_monitor IS '右項目元';