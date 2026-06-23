-- テーブル削除
DROP TABLE IF EXISTS mst_addition;
-- テーブル作成
CREATE TABLE mst_addition
(
    addition_cd bigserial NOT NULL,  --加算コード
    facility_cd character varying(6) NOT NULL, --施設マスタ.施設コード
    fn_add_cd character varying(8), --FNWコード
    addition_name character varying(256) NOT NULL, --加算等名称
    addition_short_name character varying(4), --加算略称
    addition_kind character varying(1) DEFAULT '0', --登録区分
    addition_class character varying(2) DEFAULT '0', --種別区分
    addition_class_no character varying(1) DEFAULT '1', --種別区分枝番
    addition_span character varying(1) DEFAULT '0', --算定間隔
    addition_limit bigint,  --算定回数上限
    addition_limit_type character varying(1) DEFAULT '1',
    add_cnt_1 integer,  --算定順番
    week_cnt integer,  --週順番
    addition_cond character varying(1) DEFAULT '0', --算定対象
    addition_tar_cd jsonb,  --算定対象コード
    in_hospital_cd_1 character varying(20), --院内コード1
    in_hospital_cd_2 character varying(20), --院内コード2
    in_hospital_cd_3 character varying(20), --院内コード3
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0', --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_addition_01 PRIMARY KEY (addition_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_addition" IS E'加算マスタ';
COMMENT ON COLUMN "mst_addition"."addition_cd" IS E'加算コード';
COMMENT ON COLUMN "mst_addition"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_addition"."fn_add_cd" IS E'FNWコード';
COMMENT ON COLUMN "mst_addition"."addition_name" IS E'加算等名称';
COMMENT ON COLUMN "mst_addition"."addition_short_name" IS E'加算略称';
COMMENT ON COLUMN "mst_addition"."addition_kind" IS E'登録区分';
COMMENT ON COLUMN "mst_addition"."addition_class" IS E'種別区分';
COMMENT ON COLUMN "mst_addition"."addition_class_no" IS E'種別区分枝番';
COMMENT ON COLUMN "mst_addition"."addition_span" IS E'算定間隔';
COMMENT ON COLUMN "mst_addition"."addition_limit" IS E'算定回数上限';
COMMENT ON COLUMN "mst_addition"."add_cnt_1" IS E'算定順番';
COMMENT ON COLUMN "mst_addition"."week_cnt" IS E'週順番';
COMMENT ON COLUMN "mst_addition"."addition_cond" IS E'算定対象';
COMMENT ON COLUMN "mst_addition"."addition_tar_cd" IS E'算定対象コード';
COMMENT ON COLUMN "mst_addition"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_addition"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_addition"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_addition"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_addition"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_addition"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_addition"."up_date" IS E'更新日時';