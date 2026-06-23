-- テーブル削除
DROP TABLE IF EXISTS mst_monitor_graph;
-- テーブル作成
CREATE TABLE mst_monitor_graph
(
    monitor_graph_cd serial NOT NULL,  --モニタグラフコード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    monitor_graph_name character varying(256),  --モニタグラフ名
    left_data_index integer,  --左項目コード
    left_color character varying(7),  --左グラフ色
    right_data_index integer,  --右項目コード
    right_color character varying(7),  --右グラフ色
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_monitor_graph_01 PRIMARY KEY (monitor_graph_cd)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_monitor_graph" IS E'モニタグラフマスタ';
COMMENT ON COLUMN "mst_monitor_graph"."monitor_graph_cd" IS E'モニタグラフコード';
COMMENT ON COLUMN "mst_monitor_graph"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_monitor_graph"."monitor_graph_name" IS E'モニタグラフ名';
COMMENT ON COLUMN "mst_monitor_graph"."left_data_index" IS E'左項目コード';
COMMENT ON COLUMN "mst_monitor_graph"."left_color" IS E'左グラフ色';
COMMENT ON COLUMN "mst_monitor_graph"."right_data_index" IS E'右項目コード';
COMMENT ON COLUMN "mst_monitor_graph"."right_color" IS E'右グラフ色';
COMMENT ON COLUMN "mst_monitor_graph"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_monitor_graph"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_monitor_graph"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_monitor_graph"."up_date" IS E'更新日時';
