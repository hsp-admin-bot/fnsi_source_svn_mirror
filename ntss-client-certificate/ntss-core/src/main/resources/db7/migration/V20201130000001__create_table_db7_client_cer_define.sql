DROP TABLE IF EXISTS client_cer_define;
-- テーブル作成（システム設定）
CREATE TABLE client_cer_define
(
    ctl_no numeric(4,0) NOT NULL,  --管理番号
    name character varying(256),  --名称
    value jsonb,  --値
    description character varying(4000),  --説明
    is_enable character varying(1),  --編集可否フラグ
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_system_define_01 PRIMARY KEY (ctl_no)
);
-- コメント追加（システム設定）
COMMENT ON TABLE "client_cer_define" IS E'システム設定';
COMMENT ON COLUMN "client_cer_define"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "client_cer_define"."name" IS E'名称';
COMMENT ON COLUMN "client_cer_define"."value" IS E'値';
COMMENT ON COLUMN "client_cer_define"."description" IS E'説明';
COMMENT ON COLUMN "client_cer_define"."is_enable" IS E'編集可否フラグ';
COMMENT ON COLUMN "client_cer_define"."up_date" IS E'更新日時';
