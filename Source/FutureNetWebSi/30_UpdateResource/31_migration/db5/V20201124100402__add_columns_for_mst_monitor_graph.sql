--mst_monitor_graphに列を追加
ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_line_size int NULL
;
COMMENT ON COLUMN "mst_monitor_graph"."left_line_size" IS E'左線サイズ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_line_type varchar(1) null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_line_type" IS E'左線タイプ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_line_type_value varchar(2) null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_line_type_value" IS E'左線タイプ値';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_point_color varchar(7) null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_point_color" IS E'左ポイント色';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_point_size int null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_point_size" IS E'左ポイントサイズ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_point_type varchar(1) null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_point_type" IS E'左ポイントタイプ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS left_point_type_value varchar(15) null
;
COMMENT ON COLUMN "mst_monitor_graph"."left_point_type_value" IS E'左ポイントタイプ値';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_line_size int null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_line_size" IS E'右線サイズ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_line_type varchar(1) null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_line_type" IS E'右線タイプ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_line_type_value varchar(2) null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_line_type_value" IS E'右線タイプ値';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_point_color varchar(7) null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_point_color" IS E'右ポイント色';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_point_size int null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_point_size" IS E'右ポイントサイズ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_point_type varchar(1) null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_point_type" IS E'右ポイントタイプ';

ALTER TABLE 
	mst_monitor_graph 
	ADD COLUMN IF NOT EXISTS right_point_type_value varchar(15) null
;
COMMENT ON COLUMN "mst_monitor_graph"."right_point_type_value" IS E'右ポイントタイプ値';