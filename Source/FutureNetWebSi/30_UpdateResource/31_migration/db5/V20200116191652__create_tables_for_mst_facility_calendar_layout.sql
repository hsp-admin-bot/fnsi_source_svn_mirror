-- テーブル削除(施設カレンダーレイアウトマスタ)
DROP TABLE IF EXISTS mst_facility_calendar_layout;
-- テーブル作成(施設カレンダーレイアウトマスタ)
CREATE TABLE mst_facility_calendar_layout
(
    facility_calendar_layout_cd bigserial NOT NULL,  --施設カレンダーレイアウトコード
    facility_cd character varying(6),  --施設コード
    facility_calendar_layout_name character varying,  --施設カレンダーのレイアウト名
    disp_item_info jsonb,  --表示項目
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_facility_calendar_layout_01 PRIMARY KEY (facility_calendar_layout_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(施設カレンダーレイアウトマスタ)
COMMENT ON TABLE "mst_facility_calendar_layout" IS E'施設カレンダーレイアウトマスタ';
COMMENT ON COLUMN "mst_facility_calendar_layout"."facility_calendar_layout_cd" IS E'施設カレンダーレイアウトコード';
COMMENT ON COLUMN "mst_facility_calendar_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_facility_calendar_layout"."facility_calendar_layout_name" IS E'施設カレンダーレイアウト名';
COMMENT ON COLUMN "mst_facility_calendar_layout"."disp_item_info" IS E'表示項目';
COMMENT ON COLUMN "mst_facility_calendar_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_facility_calendar_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_facility_calendar_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_facility_calendar_layout"."up_date" IS E'更新日時';
