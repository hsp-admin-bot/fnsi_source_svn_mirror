-- テーブル削除
DROP TABLE IF EXISTS mst_favorite_facility;
-- テーブル作成
CREATE TABLE mst_favorite_facility
(
    master_cd bigserial NOT NULL,  --お気に入り施設マスタコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    favorite_facility_cd character varying(6) NOT NULL,  --お気に入り施設コード
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_favorite_facility_01 PRIMARY KEY (master_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_favorite_facility" IS E'よく使う施設マスタ';
COMMENT ON COLUMN "mst_favorite_facility"."master_cd" IS E'お気に入り施設マスタコード';
COMMENT ON COLUMN "mst_favorite_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_favorite_facility"."favorite_facility_cd" IS E'お気に入り施設コード';
COMMENT ON COLUMN "mst_favorite_facility"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_favorite_facility"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_favorite_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_favorite_facility"."up_date" IS E'更新日時';
