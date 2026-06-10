-- テーブル削除
DROP TABLE IF EXISTS mst_status_map_bed_layout;
-- テーブル作成
CREATE TABLE mst_status_map_bed_layout
(
    layout_id bigserial NOT NULL,  --システムで管理する一意なレイアウト番号
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd),  --登録施設コード
    layout_name character varying(40),  --レイアウト名
    bed_layout jsonb,  --ベッドレイアウト
    background_image bytea,  --背景画像
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_status_map_bed_layout_01 PRIMARY KEY (layout_id)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_status_map_bed_layout" IS E'ベッドレイアウトマスタ';
COMMENT ON COLUMN "mst_status_map_bed_layout"."layout_id" IS E'システムで管理する一意なレイアウト番号';
COMMENT ON COLUMN "mst_status_map_bed_layout"."facility_cd" IS E'登録施設コード';
COMMENT ON COLUMN "mst_status_map_bed_layout"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_status_map_bed_layout"."bed_layout" IS E'ベッドレイアウト';
COMMENT ON COLUMN "mst_status_map_bed_layout"."background_image" IS E'背景画像';
COMMENT ON COLUMN "mst_status_map_bed_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_status_map_bed_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_status_map_bed_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_status_map_bed_layout"."up_date" IS E'更新日時';
