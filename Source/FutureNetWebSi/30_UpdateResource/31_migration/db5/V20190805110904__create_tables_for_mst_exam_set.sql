-- テーブル削除
DROP TABLE IF EXISTS mst_exam_set;
-- テーブル作成
CREATE TABLE mst_exam_set
(
    exam_set_cd bigserial NOT NULL, --システムで管理する一意な検査セットID
    facility_cd character varying(6) NOT NULL, --施設コード
    fn_exam_set_cd character varying(4),  --FNW+で管理する施設内の一意な検査セットコード
    set_class character varying(1) DEFAULT '0', --セット種別
    exam_set_name character varying(40) NOT NULL, --検査セット名
    exam_set_short_name character varying(40), --省略検査セット名
    exam_set_class character varying(1) DEFAULT '0', --セット使用区分
    is_in_hospital character varying(1), --院内院外フラグ
    can_emergency character varying(1) DEFAULT '0', --至急フラグ
    other_exam_time character varying(4) NOT NULL DEFAULT '0000', --その他検査時刻
    exam_item_info jsonb NOT NULL, --検査項目情報
    in_hospital_cd1 character varying(20), --院内コード1
    sbt_cd1 character varying(20), --属性コード1
    in_hospital_cd2 character varying(20), --院内コード2
    sbt_cd2 character varying(20), --属性コード2
    in_hospital_cd3 character varying(20), --院内コード3
    sbt_cd3 character varying(20), --属性コード3
    label_info jsonb, --ラベル情報
    is_disp character varying(1) DEFAULT '1', --表示フラグ
    is_del character varying(1) DEFAULT '0', --削除フラグ
    reg_date timestamp(3), --登録日時
    up_date timestamp(3), --更新日時

    CONSTRAINT unq_mst_exam_set_01 PRIMARY KEY (exam_set_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_exam_set" IS E'検査セットマスタ';
COMMENT ON COLUMN "mst_exam_set"."exam_set_cd" IS E'システムで管理する一意な検査セットID';
COMMENT ON COLUMN "mst_exam_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_exam_set"."fn_exam_set_cd" IS E'FNW+で管理する施設内の一意な検査セットコード';
COMMENT ON COLUMN "mst_exam_set"."set_class" IS E'セット種別';
COMMENT ON COLUMN "mst_exam_set"."exam_set_name" IS E'検査セット名';
COMMENT ON COLUMN "mst_exam_set"."exam_set_short_name" IS E'省略検査セット名';
COMMENT ON COLUMN "mst_exam_set"."exam_set_class" IS E'セット使用区分';
COMMENT ON COLUMN "mst_exam_set"."is_in_hospital" IS E'院内院外フラグ';
COMMENT ON COLUMN "mst_exam_set"."can_emergency" IS E'至急フラグ';
COMMENT ON COLUMN "mst_exam_set"."other_exam_time" IS E'その他検査時刻';
COMMENT ON COLUMN "mst_exam_set"."exam_item_info" IS E'検査項目情報';
COMMENT ON COLUMN "mst_exam_set"."in_hospital_cd1" IS E'院内コード1';
COMMENT ON COLUMN "mst_exam_set"."sbt_cd1" IS E'属性コード1';
COMMENT ON COLUMN "mst_exam_set"."in_hospital_cd2" IS E'院内コード2';
COMMENT ON COLUMN "mst_exam_set"."sbt_cd2" IS E'属性コード2';
COMMENT ON COLUMN "mst_exam_set"."in_hospital_cd3" IS E'院内コード3';
COMMENT ON COLUMN "mst_exam_set"."sbt_cd3" IS E'属性コード3';
COMMENT ON COLUMN "mst_exam_set"."label_info" IS E'ラベル情報';
COMMENT ON COLUMN "mst_exam_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_exam_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_exam_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_exam_set"."up_date" IS E'更新日時';