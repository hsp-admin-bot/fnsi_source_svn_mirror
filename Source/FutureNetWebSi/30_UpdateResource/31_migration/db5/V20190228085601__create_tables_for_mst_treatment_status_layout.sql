-- テーブル作成
DROP TABLE IF EXISTS mst_treatment_status_layout;
CREATE TABLE mst_treatment_status_layout
(
    layout_no bigserial NOT NULL,  --治療状況レイアウト管理番号
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd),  --施設コード
    layout_name character varying(20),  --レイアウト名
    use_class character varying(1) DEFAULT '0',  --使用区分
    dcs_view_items jsonb,  --DCS表示項目一覧
    dab_view_items jsonb,  --DAB表示項目一覧
    dad_view_items jsonb,  --DAD表示項目一覧
    dro_view_items jsonb,  --DRO表示項目一覧
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_treatment_status_layout_01 PRIMARY KEY (layout_no)
);

-- コメント追加
COMMENT ON TABLE "mst_treatment_status_layout" IS E'治療状況レイアウトマスタ';
COMMENT ON COLUMN "mst_treatment_status_layout"."layout_no" IS E'治療状況レイアウト管理番号';
COMMENT ON COLUMN "mst_treatment_status_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_treatment_status_layout"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_treatment_status_layout"."use_class" IS E'使用区分';
COMMENT ON COLUMN "mst_treatment_status_layout"."dcs_view_items" IS E'DCS表示項目一覧';
COMMENT ON COLUMN "mst_treatment_status_layout"."dab_view_items" IS E'DAB表示項目一覧';
COMMENT ON COLUMN "mst_treatment_status_layout"."dad_view_items" IS E'DAD表示項目一覧';
COMMENT ON COLUMN "mst_treatment_status_layout"."dro_view_items" IS E'DRO表示項目一覧';
COMMENT ON COLUMN "mst_treatment_status_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_treatment_status_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_treatment_status_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_treatment_status_layout"."up_date" IS E'更新日時';
