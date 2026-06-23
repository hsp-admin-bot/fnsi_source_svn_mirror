-- テーブル削除
DROP TABLE IF EXISTS pat_event;
-- テーブル作成
CREATE TABLE pat_event
(
    pat_event_cd bigserial NOT NULL,  --システムで管理する一意な患者イベントコード
    pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    facility_cd character varying(6),  --施設コード
    fn_ctl_no bigint,  --FNW+で管理する施設内の一意なシーケンスID
    event_status character varying(1),  --状況区分
    template_cd bigint,  --テンプレートコード
    template_name character varying(20),  --テンプレート名称
    category_cd bigint,  --カテゴリコード
    category_name character varying(20),  --カテゴリ名称
    is_va character varying(1) DEFAULT '0',  --VA画像フラグ
    is_observe character varying(1) DEFAULT '0',  --観察記録対象フラグ
    ord_no bigint,  --システムで管理する一意なオーダ番号
    input_params jsonb,  --項目情報
    event_date timestamp(3),  --イベント日時
    sub_category_cd bigint,  --サブカテゴリコード
    sub_category_name character varying(20),  --サブカテゴリ名称
    result_params jsonb,  --項目実績
    score_total integer,  --スコア合計
    reg_staff_info jsonb DEFAULT E'{"reg_staff_cd":null,"reg_staff_name":null}',  --起票者情報
    up_staff_info jsonb DEFAULT E'{"up_staff_cd":null,"up_staff_name":null}',  --編集者情報
    bbs_ctl_no bigint,  --掲示板管理番号
    is_newest character varying(1) DEFAULT '1',  --最新フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_pat_event_01 PRIMARY KEY (pat_event_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "pat_event" IS E'患者イベント情報';
COMMENT ON COLUMN "pat_event"."pat_event_cd" IS E'システムで管理する一意な患者イベントコード';
COMMENT ON COLUMN "pat_event"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_event"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_event"."fn_ctl_no" IS E'FNW+で管理する施設内の一意なシーケンスID';
COMMENT ON COLUMN "pat_event"."event_status" IS E'状況区分';
COMMENT ON COLUMN "pat_event"."template_cd" IS E'テンプレートコード';
COMMENT ON COLUMN "pat_event"."template_name" IS E'テンプレート名称';
COMMENT ON COLUMN "pat_event"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "pat_event"."category_name" IS E'カテゴリ名称';
COMMENT ON COLUMN "pat_event"."is_va" IS E'VA画像フラグ';
COMMENT ON COLUMN "pat_event"."is_observe" IS E'観察記録対象フラグ';
COMMENT ON COLUMN "pat_event"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "pat_event"."input_params" IS E'項目情報';
COMMENT ON COLUMN "pat_event"."event_date" IS E'イベント日時';
COMMENT ON COLUMN "pat_event"."sub_category_cd" IS E'サブカテゴリコード';
COMMENT ON COLUMN "pat_event"."sub_category_name" IS E'サブカテゴリ名称';
COMMENT ON COLUMN "pat_event"."result_params" IS E'項目実績';
COMMENT ON COLUMN "pat_event"."score_total" IS E'スコア合計';
COMMENT ON COLUMN "pat_event"."reg_staff_info" IS E'起票者情報';
COMMENT ON COLUMN "pat_event"."up_staff_info" IS E'編集者情報';
COMMENT ON COLUMN "pat_event"."bbs_ctl_no" IS E'掲示板管理番号';
COMMENT ON COLUMN "pat_event"."is_newest" IS E'最新フラグ';
COMMENT ON COLUMN "pat_event"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_event"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_event"."up_date" IS E'更新日時';

