-- テーブル削除(マルチ患者レイアウトマスタ)
DROP TABLE IF EXISTS mst_pat_list_layout;
-- テーブル作成(マルチ患者レイアウトマスタ)
CREATE TABLE mst_pat_list_layout
(
    pat_list_layout_cd bigserial NOT NULL,  --マルチ患者レイアウトコード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    pat_list_layout_name character varying,  --マルチ患者レイアウト名
    disp_item_info jsonb,  --表示項目
    occupations jsonb,  --職種
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_pat_list_layout_01 PRIMARY KEY (pat_list_layout_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(マルチ患者レイアウトマスタ)
COMMENT ON TABLE "mst_pat_list_layout" IS E'マルチ患者レイアウトマスタ';
COMMENT ON COLUMN "mst_pat_list_layout"."pat_list_layout_cd" IS E'マルチ患者レイアウトコード';
COMMENT ON COLUMN "mst_pat_list_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_list_layout"."pat_list_layout_name" IS E'マルチ患者レイアウト名';
COMMENT ON COLUMN "mst_pat_list_layout"."disp_item_info" IS E'表示項目';
COMMENT ON COLUMN "mst_pat_list_layout"."occupations" IS E'職種';
COMMENT ON COLUMN "mst_pat_list_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_list_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_list_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_list_layout"."up_date" IS E'更新日時';
