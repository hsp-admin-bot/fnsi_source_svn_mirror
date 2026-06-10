-- テーブル削除（種別マスタ）
DROP TABLE IF EXISTS mst_round_type;
-- テーブル作成（種別マスタ）
CREATE TABLE mst_round_type
(
    round_type_cd bigserial NOT NULL,  --種別コード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    round_type_name character varying(40) NOT NULL,  --種別名
    content character varying,  --内容
    is_content_omission character varying(1) DEFAULT '0',  --内容省略フラグ
    comment_post_default character varying(1) DEFAULT '0',  --指示コメント転記初期値
    posting_class_default character varying(1) DEFAULT '0',  --転記区分初期値
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_round_type_01 PRIMARY KEY (round_type_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（種別マスタ）
COMMENT ON TABLE "mst_round_type" IS E'種別マスタ';
COMMENT ON COLUMN "mst_round_type"."round_type_cd" IS E'種別コード';
COMMENT ON COLUMN "mst_round_type"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_round_type"."round_type_name" IS E'種別名';
COMMENT ON COLUMN "mst_round_type"."content" IS E'内容';
COMMENT ON COLUMN "mst_round_type"."is_content_omission" IS E'内容省略フラグ';
COMMENT ON COLUMN "mst_round_type"."comment_post_default" IS E'指示コメント転記初期値';
COMMENT ON COLUMN "mst_round_type"."posting_class_default" IS E'転記区分初期値';
COMMENT ON COLUMN "mst_round_type"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_round_type"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_round_type"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_round_type"."up_date" IS E'更新日時';
