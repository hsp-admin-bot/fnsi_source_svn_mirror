--------------------------------------------------
-- 警報通知マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_alarm_notification;
-- テーブル作成
CREATE TABLE mst_alarm_notification
(
    alarm_notification_cd bigserial NOT NULL,  --警報通知コード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    alarm_notification_name character varying,  --警報通知名
    destination_facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --送信先施設コード
    destination_group_cd bigint REFERENCES mst_destination_group(destination_group_cd),  --送信先グループコード
    target_machine_record jsonb,  --対象装置記録
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_alarm_notification_01 PRIMARY KEY (alarm_notification_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_alarm_notification" IS E'警報通知マスタ';
COMMENT ON COLUMN "mst_alarm_notification"."alarm_notification_cd" IS E'警報通知コード';
COMMENT ON COLUMN "mst_alarm_notification"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_alarm_notification"."alarm_notification_name" IS E'警報通知名';
COMMENT ON COLUMN "mst_alarm_notification"."destination_facility_cd" IS E'送信先施設コード';
COMMENT ON COLUMN "mst_alarm_notification"."destination_group_cd" IS E'送信先グループコード';
COMMENT ON COLUMN "mst_alarm_notification"."target_machine_record" IS E'対象装置記録';
COMMENT ON COLUMN "mst_alarm_notification"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_alarm_notification"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_alarm_notification"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_alarm_notification"."up_date" IS E'更新日時';
