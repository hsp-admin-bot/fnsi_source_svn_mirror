ALTER TABLE ntss.mst_trend_graph_template ADD com_format_cd varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_trend_graph_template.com_format_cd IS '通信フォーマット';
