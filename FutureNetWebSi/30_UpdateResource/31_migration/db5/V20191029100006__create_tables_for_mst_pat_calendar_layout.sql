-- テーブル削除(患者カレンダーレイアウトマスタ)
DROP TABLE IF EXISTS mst_pat_calendar_layout;
-- テーブル作成(患者カレンダーレイアウトマスタ)
CREATE TABLE mst_pat_calendar_layout
(
    pat_calendar_layout_cd bigserial NOT NULL,  --患者カレンダーレイアウトコード
    facility_cd character varying(6),  --施設コード
    pat_calendar_layout_name character varying,  --患者カレンダーレイアウト名
    disp_item_info jsonb,  --表示項目
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_pat_calendar_layout_01 PRIMARY KEY (pat_calendar_layout_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(患者カレンダーレイアウトマスタ)
COMMENT ON TABLE "mst_pat_calendar_layout" IS E'患者カレンダーレイアウトマスタ';
COMMENT ON COLUMN "mst_pat_calendar_layout"."pat_calendar_layout_cd" IS E'患者カレンダーレイアウトコード';
COMMENT ON COLUMN "mst_pat_calendar_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_calendar_layout"."pat_calendar_layout_name" IS E'患者カレンダーレイアウト名';
COMMENT ON COLUMN "mst_pat_calendar_layout"."disp_item_info" IS E'表示項目';
COMMENT ON COLUMN "mst_pat_calendar_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_calendar_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_calendar_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_calendar_layout"."up_date" IS E'更新日時';
