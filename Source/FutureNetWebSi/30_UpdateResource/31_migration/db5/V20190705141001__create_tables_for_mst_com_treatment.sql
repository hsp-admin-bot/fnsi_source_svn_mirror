-- テーブル削除
DROP TABLE IF EXISTS mst_comp_treatment;
-- テーブル作成
CREATE TABLE mst_comp_treatment
(
    comp_treatment_cd serial NOT NULL,  --処置コード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    treatment character varying(256),  --処置内容
    treat_class character varying(1),  --処置区分
    treat_medicine_cd integer,  --処置薬剤コード
    amount numeric(12,2),  --数量
    procedure_cd integer,  --手技コード
    take_medicine_cd integer,  --服用コード
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_comp_treatment_01 PRIMARY KEY (comp_treatment_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_comp_treatment" IS E'処置マスタ';
COMMENT ON COLUMN "mst_comp_treatment"."comp_treatment_cd" IS E'処置コード';
COMMENT ON COLUMN "mst_comp_treatment"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_comp_treatment"."treatment" IS E'処置内容';
COMMENT ON COLUMN "mst_comp_treatment"."treat_class" IS E'処置区分';
COMMENT ON COLUMN "mst_comp_treatment"."treat_medicine_cd" IS E'処置薬剤コード';
COMMENT ON COLUMN "mst_comp_treatment"."amount" IS E'数量';
COMMENT ON COLUMN "mst_comp_treatment"."procedure_cd" IS E'手技コード';
COMMENT ON COLUMN "mst_comp_treatment"."take_medicine_cd" IS E'服用コード';
COMMENT ON COLUMN "mst_comp_treatment"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_comp_treatment"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_comp_treatment"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_comp_treatment"."up_date" IS E'更新日時';
