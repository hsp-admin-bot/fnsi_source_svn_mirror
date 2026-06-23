-- テーブル削除
DROP TABLE IF EXISTS notification_list;
-- テーブル作成
CREATE TABLE notification_list
(
    terminal_unique_string character varying(16) NOT NULL,  --端末固有文字列(localStorageに保存)
    facility_cd character varying(6) NOT NULL,  --施設コード
    user_id bigint NOT NULL,  --利用者ID（内部用ID）
    notification_data jsonb,  --Push通知先情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_notification_list_01 PRIMARY KEY (terminal_unique_string)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "notification_list" IS E'通知先リスト';
COMMENT ON COLUMN "notification_list"."terminal_unique_string" IS E'端末固有文字列(localStorageに保存)';
COMMENT ON COLUMN "notification_list"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "notification_list"."user_id" IS E'利用者ID（内部用ID）';
COMMENT ON COLUMN "notification_list"."notification_data" IS E'Push通知先情報';
COMMENT ON COLUMN "notification_list"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "notification_list"."up_date" IS E'更新日時';
