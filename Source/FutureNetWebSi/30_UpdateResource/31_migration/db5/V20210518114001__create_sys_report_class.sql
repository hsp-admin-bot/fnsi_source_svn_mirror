-- テーブル削除
DROP TABLE IF EXISTS sys_report_class;
-- テーブル作成
create table sys_report_class (
    report_class_cd bigserial NOT NULL
  , report_class_name character varying
  , report_type jsonb
  , is_disp character varying(1) default '1'
  , is_del character varying(1) default '0'
  , up_date timestamp(3) without time zone
  , reg_date timestamp(3) without time zone
  , primary key (report_class_cd)
);
-- コメント追加
COMMENT ON TABLE "sys_report_class" IS E'帳票種別定義';
COMMENT ON COLUMN "sys_report_class"."report_class_cd" IS E'帳票種別';
COMMENT ON COLUMN "sys_report_class"."report_class_name" IS E'帳票種別名';
COMMENT ON COLUMN "sys_report_class"."report_type" IS E'帳票区分';
COMMENT ON COLUMN "sys_report_class"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_report_class"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_report_class"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_report_class"."up_date" IS E'更新日時';