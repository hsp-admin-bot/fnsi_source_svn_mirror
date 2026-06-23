-- テーブル削除(掲示板種別マスタ)
DROP TABLE IF EXISTS mst_bbs_kind;
-- テーブル作成(掲示板種別マスタ)
CREATE TABLE mst_bbs_kind
(
    kind_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    kind_name character varying,  --種別名
    fixed_phrase character varying,  --定型文
    fn_category_id character varying,  --FNW+で管理する施設内の一意なカテゴリID
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_bbs_kind_01 PRIMARY KEY (kind_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(掲示板種別マスタ)
COMMENT ON TABLE "mst_bbs_kind" IS E'掲示板種別マスタ';
COMMENT ON COLUMN "mst_bbs_kind"."kind_no" IS E'管理番号';
COMMENT ON COLUMN "mst_bbs_kind"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_bbs_kind"."kind_name" IS E'種別名';
COMMENT ON COLUMN "mst_bbs_kind"."fixed_phrase" IS E'定型文';
COMMENT ON COLUMN "mst_bbs_kind"."fn_category_id" IS E'FNW+で管理する施設内の一意なカテゴリID';
COMMENT ON COLUMN "mst_bbs_kind"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_bbs_kind"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_bbs_kind"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_bbs_kind"."up_date" IS E'更新日時';
