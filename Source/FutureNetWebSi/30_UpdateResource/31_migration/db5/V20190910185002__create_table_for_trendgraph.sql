-- トレンドグラフ設定用マスタテーブルの作成


-- テーブル削除
DROP TABLE IF EXISTS mst_trend_graph_template;
-- テーブル作成
CREATE TABLE mst_trend_graph_template
(
    template_cd bigserial NOT NULL,  --テンプレートコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    template_name character varying(50),  --テンプレート名称
    model character varying(3),  --装置種別
    vertical_range_right_max numeric(6,2),  --縦軸範囲(右)最大値
    vertical_range_right_min numeric(6,2),  --縦軸範囲(右)最小値
    vertical_range_left_max numeric(6,2),  --縦軸範囲(左)最大値
    vertical_range_left_min numeric(6,2),  --縦軸範囲(左)最小値
    series_info jsonb,  --グラフ系列情報
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時



    CONSTRAINT unq_mst_trend_graph_template_01 PRIMARY KEY (template_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_trend_graph_template" IS E'トレンドグラフテンプレートマスタ';
COMMENT ON COLUMN "mst_trend_graph_template"."template_cd" IS E'テンプレートコード';
COMMENT ON COLUMN "mst_trend_graph_template"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_trend_graph_template"."template_name" IS E'テンプレート名称';
COMMENT ON COLUMN "mst_trend_graph_template"."model" IS E'装置種別';
COMMENT ON COLUMN "mst_trend_graph_template"."vertical_range_right_max" IS E'縦軸範囲(右)最大値';
COMMENT ON COLUMN "mst_trend_graph_template"."vertical_range_right_min" IS E'縦軸範囲(右)最小値';
COMMENT ON COLUMN "mst_trend_graph_template"."vertical_range_left_max" IS E'縦軸範囲(左)最大値';
COMMENT ON COLUMN "mst_trend_graph_template"."vertical_range_left_min" IS E'縦軸範囲(左)最小値';
COMMENT ON COLUMN "mst_trend_graph_template"."series_info" IS E'グラフ系列情報';
COMMENT ON COLUMN "mst_trend_graph_template"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_trend_graph_template"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_trend_graph_template"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_trend_graph_template"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_trend_graph_monitor_set;
-- テーブル作成
CREATE TABLE mst_trend_graph_monitor_set
(
    monitor_set_cd bigserial NOT NULL,  --項目セットコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    monitor_set_name character varying(50),  --項目セット名称
    model character varying(3),  --装置種別
    series_info jsonb,  --モニタ項目一覧セット
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時



    CONSTRAINT unq_mst_trend_graph_monitor_set_01 PRIMARY KEY (monitor_set_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_trend_graph_monitor_set" IS E'トレンドグラフモニタ項目一覧セットマスタ';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."monitor_set_cd" IS E'項目セットコード';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."monitor_set_name" IS E'項目セット名称';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."model" IS E'装置種別';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."series_info" IS E'モニタ項目一覧セット';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_trend_graph_monitor_set"."up_date" IS E'更新日時';



