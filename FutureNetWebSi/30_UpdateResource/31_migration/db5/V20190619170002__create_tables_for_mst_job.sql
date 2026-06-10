-- テーブル削除
DROP TABLE IF EXISTS mst_job;
-- テーブル作成
CREATE TABLE mst_job
(
    job_cd bigserial NOT NULL,  --職種コード
    facility_cd character varying(6),  --施設コード
    job_name character varying(40),  --職種名
    is_doctor character varying(1) DEFAULT '0',  --医師フラグ
    default_menu_settings jsonb NOT NULL DEFAULT '{"initial_menu_function": "005", "default_menu_functions": ["005"]}',  --デフォルトメニュー設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_job_01 PRIMARY KEY (job_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_job" IS E'職種マスタ';
COMMENT ON COLUMN "mst_job"."job_cd" IS E'職種コード';
COMMENT ON COLUMN "mst_job"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_job"."job_name" IS E'職種名';
COMMENT ON COLUMN "mst_job"."is_doctor" IS E'医師フラグ';
COMMENT ON COLUMN "mst_job"."default_menu_settings" IS E'デフォルトメニュー設定';
COMMENT ON COLUMN "mst_job"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_job"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_job"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_job"."up_date" IS E'更新日時';
