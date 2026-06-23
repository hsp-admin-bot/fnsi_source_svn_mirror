-- 患者イベント管理設定用マスタテーブルの作成


-- テーブル削除
DROP TABLE IF EXISTS mst_pat_event_category;

CREATE TABLE mst_pat_event_category
(
    category_cd bigserial NOT NULL,  --カテゴリコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    category_name character varying(20) NOT NULL,  --カテゴリ名
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_pat_event_category_01 PRIMARY KEY (category_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_pat_event_category" IS E'患者イベントカテゴリマスタ';
COMMENT ON COLUMN "mst_pat_event_category"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_pat_event_category"."category_name" IS E'カテゴリ名';
COMMENT ON COLUMN "mst_pat_event_category"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_event_category"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_event_category"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_event_category"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_event_category"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_pat_event_sub_category;

-- テーブル作成
CREATE TABLE mst_pat_event_sub_category
(
    sub_category_cd bigserial NOT NULL,  --サブカテゴリコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    sub_category_name character varying(20) NOT NULL,  --サブカテゴリ名
    category_cd bigint NOT NULL,  --カテゴリコード
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_pat_event_sub_category_01 PRIMARY KEY (sub_category_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_pat_event_sub_category" IS E'患者イベントサブカテゴリマスタ';
COMMENT ON COLUMN "mst_pat_event_sub_category"."sub_category_cd" IS E'サブカテゴリコード';
COMMENT ON COLUMN "mst_pat_event_sub_category"."sub_category_name" IS E'サブカテゴリ名';
COMMENT ON COLUMN "mst_pat_event_sub_category"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_pat_event_sub_category"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_event_sub_category"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_event_sub_category"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_event_sub_category"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_event_sub_category"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_pat_event_data_template;

-- テーブル作成
CREATE TABLE mst_pat_event_data_template
(
    template_cd bigserial NOT NULL,  --テンプレートコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    template_name character varying(20) NOT NULL,  --テンプレート名
    category_cd bigint NOT NULL,  --カテゴリコード
    is_va character varying(1) DEFAULT '0',  --VA画像フラグ
    is_observe character varying(1) DEFAULT '0',  --観察記録対象フラグ
    input_params jsonb,  --項目情報
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時


    CONSTRAINT unq_mst_pat_event_data_template_01 PRIMARY KEY (template_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_pat_event_data_template" IS E'患者イベント項目テンプレート';
COMMENT ON COLUMN "mst_pat_event_data_template"."template_cd" IS E'テンプレートコード';
COMMENT ON COLUMN "mst_pat_event_data_template"."template_name" IS E'テンプレート名';
COMMENT ON COLUMN "mst_pat_event_data_template"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_pat_event_data_template"."is_va" IS E'VA画像フラグ';
COMMENT ON COLUMN "mst_pat_event_data_template"."is_observe" IS E'観察記録対象フラグ';
COMMENT ON COLUMN "mst_pat_event_data_template"."input_params" IS E'項目情報';
COMMENT ON COLUMN "mst_pat_event_data_template"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_event_data_template"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_event_data_template"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_event_data_template"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_event_data_template"."up_date" IS E'更新日時';

