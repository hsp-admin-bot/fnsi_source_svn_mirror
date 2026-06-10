DROP TABLE IF EXISTS sys_notification;

CREATE TABLE sys_notification (
  notification_no bigint NOT NULL,  --通知定義番号
  notification_category bigint,  --通知カテゴリ
  setting_name character varying,  --通知設定名
  message character varying,  --メッセージ定義
  additional_info jsonb,  --付加情報定義
  disp_order numeric(5),  --表示順
  available_keys character varying,  --使用可能キー
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_sys_notification_01 PRIMARY KEY (notification_no)
);

COMMENT ON TABLE "sys_notification" IS E'通知定義';
COMMENT ON COLUMN "sys_notification"."notification_no" IS E'通知定義番号';
COMMENT ON COLUMN "sys_notification"."notification_category" IS E'通知カテゴリ';
COMMENT ON COLUMN "sys_notification"."setting_name" IS E'通知設定名';
COMMENT ON COLUMN "sys_notification"."message" IS E'メッセージ定義';
COMMENT ON COLUMN "sys_notification"."additional_info" IS E'付加情報定義';
COMMENT ON COLUMN "sys_notification"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_notification"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_notification"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_notification"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_notification"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_notification"."available_keys" IS E'使用可能キー';
