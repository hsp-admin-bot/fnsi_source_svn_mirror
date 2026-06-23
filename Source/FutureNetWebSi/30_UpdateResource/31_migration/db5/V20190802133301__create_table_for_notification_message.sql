-- 通知メッセージマスタ
-- テーブル削除
DROP TABLE IF EXISTS mst_notification_message;
-- テーブル作成
CREATE TABLE mst_notification_message
(
    notification_message_cd serial NOT NULL,  --通知メッセージコード
    facility_cd character varying(6),  --施設コード
    title character varying,  --メッセージタイトル
    content character varying,  --メッセージ本文
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_notification_message_01 PRIMARY KEY (notification_message_cd)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_notification_message" IS E'通知メッセージマスタ';
COMMENT ON COLUMN "mst_notification_message"."notification_message_cd" IS E'通知メッセージコード';
COMMENT ON COLUMN "mst_notification_message"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_notification_message"."title" IS E'メッセージタイトル';
COMMENT ON COLUMN "mst_notification_message"."content" IS E'メッセージ本文';
COMMENT ON COLUMN "mst_notification_message"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_notification_message"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_notification_message"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_notification_message"."up_date" IS E'更新日時';

-- 通知メッセージテーブル
-- テーブル削除
DROP TABLE IF EXISTS mnt_notification_message;
-- テーブル作成
CREATE TABLE mnt_notification_message
(
    notification_message_no bigserial NOT NULL,  --通知メッセージ番号
    content character varying,  --メッセージ本文
    additional_info jsonb,  --付加情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_notification_message_01 PRIMARY KEY (notification_message_no)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mnt_notification_message" IS E'通知メッセージテーブル';
COMMENT ON COLUMN "mnt_notification_message"."notification_message_no" IS E'通知メッセージ番号';
COMMENT ON COLUMN "mnt_notification_message"."content" IS E'メッセージ本文';
COMMENT ON COLUMN "mnt_notification_message"."additional_info" IS E'付加情報';
COMMENT ON COLUMN "mnt_notification_message"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_notification_message"."up_date" IS E'更新日時';

-- 通知状態管理
-- テーブル削除
DROP TABLE IF EXISTS mnt_notification_status;
-- テーブル作成
CREATE TABLE mnt_notification_status
(
    notification_message_no bigint NOT NULL REFERENCES mnt_notification_message(notification_message_no) ON DELETE CASCADE,  --通知メッセージ番号
    user_id bigint NOT NULL REFERENCES mst_user(user_id),  --利用者ID
    is_notified character varying(1) DEFAULT '0',  --通知済フラグ
    is_read character varying(1) DEFAULT '0',  --既読フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_notification_status_01 PRIMARY KEY (notification_message_no,user_id)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mnt_notification_status" IS E'通知状態管理';
COMMENT ON COLUMN "mnt_notification_status"."notification_message_no" IS E'通知メッセージ番号';
COMMENT ON COLUMN "mnt_notification_status"."user_id" IS E'利用者ID';
COMMENT ON COLUMN "mnt_notification_status"."is_notified" IS E'通知済フラグ';
COMMENT ON COLUMN "mnt_notification_status"."is_read" IS E'既読フラグ';
COMMENT ON COLUMN "mnt_notification_status"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_notification_status"."up_date" IS E'更新日時';
