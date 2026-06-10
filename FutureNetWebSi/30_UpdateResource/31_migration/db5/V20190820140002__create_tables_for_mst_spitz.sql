-- テーブル削除
DROP TABLE IF EXISTS mst_spitz;
-- テーブル作成
CREATE TABLE mst_spitz
(
    spitz_cd bigserial NOT NULL,  --採血管コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    spitz_name character varying(40) NOT NULL,  --採血管名
    label_print character varying(10),  --ラベル印字項目
	is_in_hospital character varying(1),  --院内院外フラグ
	emergency_flg character varying(1) DEFAULT '0',  --至急フラグ
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_spitz_01 PRIMARY KEY (spitz_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_spitz" IS E'採血管マスタ';
COMMENT ON COLUMN "mst_spitz"."spitz_cd" IS E'採血管コード';
COMMENT ON COLUMN "mst_spitz"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_spitz"."spitz_name" IS E'採血管名';
COMMENT ON COLUMN "mst_spitz"."label_print" IS E'ラベル印字項目';
COMMENT ON COLUMN "mst_spitz"."is_in_hospital" IS E'院内院外フラグ';
COMMENT ON COLUMN "mst_spitz"."emergency_flg" IS E'至急フラグ';
COMMENT ON COLUMN "mst_spitz"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_spitz"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_spitz"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_spitz"."up_date" IS E'更新日時';