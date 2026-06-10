-- テーブル削除
DROP TABLE IF EXISTS sys_coop_no;
-- テーブル作成
CREATE TABLE sys_coop_no
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_ord_cd jsonb,  --連携オーダ種別
    cur_coop_ord_no bigint NOT NULL DEFAULT 0,  --現在の連携オーダ番号シーケンス
    no_of_digit bigint NOT NULL,  --連携オーダ番号_桁数
    padding_char character varying(1) NOT NULL DEFAULT '0',  --連携オーダ番号_パディング文字
    padding_pos character varying NOT NULL DEFAULT 'left',  --連携オーダ番号_パディング位置
    range_max bigint,  --連携オーダ番号_最大値
    range_min bigint NOT NULL DEFAULT 0,  --連携オーダ番号_最小値
    prefix_char character varying,  --連携オーダ番号_前置文字
    suffix_char character varying,  --連携オーダ番号_後置文字
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_coop_no_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "sys_coop_no" IS E'患者連携情報';
COMMENT ON COLUMN "sys_coop_no"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_coop_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_coop_no"."coop_ord_cd" IS E'連携オーダ種別';
COMMENT ON COLUMN "sys_coop_no"."cur_coop_ord_no" IS E'現在の連携オーダ番号シーケンス';
COMMENT ON COLUMN "sys_coop_no"."no_of_digit" IS E'連携オーダ番号_桁数';
COMMENT ON COLUMN "sys_coop_no"."padding_char" IS E'連携オーダ番号_パディング文字';
COMMENT ON COLUMN "sys_coop_no"."padding_pos" IS E'連携オーダ番号_パディング位置';
COMMENT ON COLUMN "sys_coop_no"."range_max" IS E'連携オーダ番号_最大値';
COMMENT ON COLUMN "sys_coop_no"."range_min" IS E'連携オーダ番号_最小値';
COMMENT ON COLUMN "sys_coop_no"."prefix_char" IS E'連携オーダ番号_前置文字';
COMMENT ON COLUMN "sys_coop_no"."suffix_char" IS E'連携オーダ番号_後置文字';
COMMENT ON COLUMN "sys_coop_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_coop_no"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_coop_no"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "sys_coop_no"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_coop_no"."up_date" IS E'更新日時';


-- テーブル削除
DROP TABLE IF EXISTS ord_coop_no;
-- テーブル作成
CREATE TABLE ord_coop_no
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    pat_id bigint,  --患者番号
    ord_no bigint,  --オーダ番号
    coop_cd character varying,  --連携種別
    coop_ord_no character varying,  --連携オーダ番号
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_ord_coop_no_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "ord_coop_no" IS E'連携オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "ord_coop_no"."pat_id" IS E'患者番号';
COMMENT ON COLUMN "ord_coop_no"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."coop_cd" IS E'連携種別';
COMMENT ON COLUMN "ord_coop_no"."coop_ord_no" IS E'連携オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_coop_no"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_coop_no"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "ord_coop_no"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_coop_no"."up_date" IS E'更新日時';
