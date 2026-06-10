-- 観察記録で使用するテーブルのCREATE文です。

-- テーブル削除
DROP TABLE IF EXISTS pat_obs_rec;
-- テーブル作成
CREATE TABLE pat_obs_rec
(
    obs_rec_no bigserial NOT NULL,  --管理番号
    pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    facility_cd character varying(6),  --登録施設コード
    rec_date timestamp(3),  --起票日時
    up_cnt smallint,  --更新回数
    kind_info jsonb DEFAULT E'{"kind_no":null,"kind_update":null,"kind_name":null}',  --種別情報
    reg_staff_info jsonb DEFAULT E'{"reg_staff_cd":null,"reg_staff_update":null,"reg_staff_name":null}',  --起票者情報
    up_staff_info jsonb DEFAULT E'{"up_staff_cd":null,"up_staff_update":null,"up_staff_name":null}',  --編集者情報
    obs_rec_info jsonb DEFAULT E'{"detail1":null,"detail2":null,"detail3":null,"detail4":null}',  --観察記録情報
    bbs_ctl_no bigint,  --掲示板管理番号
    ord_no bigint,  --システムで管理する一意なオーダ番号
    is_newest character varying(1) DEFAULT '0',  --最新フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    fn_seq_id bigint,  --FNW+で管理する施設内の一意な観察記録用シーケンス番号
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_pat_obs_rec_01 PRIMARY KEY (obs_rec_no)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "pat_obs_rec" IS E'患者観察記録情報';
COMMENT ON COLUMN "pat_obs_rec"."obs_rec_no" IS E'管理番号';
COMMENT ON COLUMN "pat_obs_rec"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_obs_rec"."facility_cd" IS E'登録施設コード';
COMMENT ON COLUMN "pat_obs_rec"."rec_date" IS E'起票日時';
COMMENT ON COLUMN "pat_obs_rec"."up_cnt" IS E'更新回数';
COMMENT ON COLUMN "pat_obs_rec"."kind_info" IS E'種別情報';
COMMENT ON COLUMN "pat_obs_rec"."reg_staff_info" IS E'起票者情報';
COMMENT ON COLUMN "pat_obs_rec"."up_staff_info" IS E'編集者情報';
COMMENT ON COLUMN "pat_obs_rec"."obs_rec_info" IS E'観察記録情報';
COMMENT ON COLUMN "pat_obs_rec"."bbs_ctl_no" IS E'掲示板管理番号';
COMMENT ON COLUMN "pat_obs_rec"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "pat_obs_rec"."is_newest" IS E'最新フラグ';
COMMENT ON COLUMN "pat_obs_rec"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_obs_rec"."fn_seq_id" IS E'FNW+で管理する施設内の一意な観察記録用シーケンス番号';
COMMENT ON COLUMN "pat_obs_rec"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_obs_rec"."up_date" IS E'更新日時';


-- テーブル削除
DROP TABLE IF EXISTS mst_obs_kind;
-- テーブル作成
CREATE TABLE mst_obs_kind
(
    kind_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    kind_name character varying(40),  --種別名
    kind_class integer NOT NULL,  --種別区分
    is_post_bbs character varying(1) DEFAULT '0',  --掲示板への掲載有無
    post_period integer,  --期間
    post_address_class integer,  --周知先
    is_link_ord_no character varying(1) DEFAULT '0',  --治療実績とリンク有無
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_obs_kind_01 PRIMARY KEY (kind_no)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mst_obs_kind" IS E'観察記録種別情報';
COMMENT ON COLUMN "mst_obs_kind"."kind_no" IS E'管理番号';
COMMENT ON COLUMN "mst_obs_kind"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_obs_kind"."kind_name" IS E'種別名';
COMMENT ON COLUMN "mst_obs_kind"."kind_class" IS E'種別区分';
COMMENT ON COLUMN "mst_obs_kind"."is_post_bbs" IS E'掲示板への掲載有無';
COMMENT ON COLUMN "mst_obs_kind"."post_period" IS E'期間';
COMMENT ON COLUMN "mst_obs_kind"."post_address_class" IS E'周知先';
COMMENT ON COLUMN "mst_obs_kind"."is_link_ord_no" IS E'治療実績とリンク有無';
COMMENT ON COLUMN "mst_obs_kind"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_obs_kind"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_obs_kind"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_obs_kind"."up_date" IS E'更新日時';
