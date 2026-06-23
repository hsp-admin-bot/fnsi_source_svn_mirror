-- テーブル削除
DROP TABLE IF EXISTS sys_release_info;
-- テーブル作成
CREATE TABLE sys_release_info
(
    ctl_no bigserial NOT NULL,  --管理番号,
    release_date character varying(8),  --リリース日
    title character varying(256),  --タイトル
    system_type character varying(1),  --システム
    path_url  character varying(2000),  --path
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_function_release_info_01 PRIMARY KEY (ctl_no)
);

COMMENT ON TABLE "sys_release_info" IS E'システムリリース情報';
COMMENT ON COLUMN "sys_release_info"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_release_info"."release_date" IS E'リリース日';
COMMENT ON COLUMN "sys_release_info"."title" IS E'タイトル';
COMMENT ON COLUMN "sys_release_info"."system_type" IS E'システムタイプ';
COMMENT ON COLUMN "sys_release_info"."path_url" IS E'path';
COMMENT ON COLUMN "sys_release_info"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_release_info"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_release_info"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_release_info"."up_date" IS E'更新日時';
