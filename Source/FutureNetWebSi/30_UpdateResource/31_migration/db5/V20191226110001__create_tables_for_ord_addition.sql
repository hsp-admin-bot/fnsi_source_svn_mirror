-- テーブル削除
DROP TABLE IF EXISTS ord_addition;
-- テーブル作成
CREATE TABLE ord_addition
(
    add_ord_no bigserial,  --加算オーダ番号
    ord_kind character varying(2),  --連動先テーブル
    ord_no bigint,  --連動オーダ番号
    addition_date timestamp(3),  --算定日
    facility_cd character varying(6),  --施設コード
    is_addition character varying(1) DEFAULT '1',  --算定状況
    pat_id bigint,  --患者番号
    addition_cd bigint,  --加算コード
    addition_detail jsonb,  --加算内容
    is_disp character varying DEFAULT '1',  --表示フラグ
    is_del character varying DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_ord_addition_01 PRIMARY KEY (add_ord_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "ord_addition" IS E'加算オーダ';
COMMENT ON COLUMN "ord_addition"."add_ord_no" IS E' 加算オーダ番号';
COMMENT ON COLUMN "ord_addition"."ord_kind" IS E' 連動先テーブル';
COMMENT ON COLUMN "ord_addition"."ord_no" IS E' 連動オーダ番号';
COMMENT ON COLUMN "ord_addition"."addition_date" IS E' 算定日';
COMMENT ON COLUMN "ord_addition"."facility_cd" IS E' 施設コード';
COMMENT ON COLUMN "ord_addition"."is_addition" IS E' 算定状況';
COMMENT ON COLUMN "ord_addition"."pat_id" IS E' 患者番号';
COMMENT ON COLUMN "ord_addition"."addition_cd" IS E' 加算コード';
COMMENT ON COLUMN "ord_addition"."addition_detail" IS E' 加算内容';
COMMENT ON COLUMN "ord_addition"."is_disp" IS E' 表示フラグ';
COMMENT ON COLUMN "ord_addition"."is_del" IS E' 削除フラグ';
COMMENT ON COLUMN "ord_addition"."reg_date" IS E' 登録日時';
COMMENT ON COLUMN "ord_addition"."up_date" IS E' 更新日時';


