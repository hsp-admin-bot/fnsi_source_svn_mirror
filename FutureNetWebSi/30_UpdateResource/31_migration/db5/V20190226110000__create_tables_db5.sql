--------------------------------------------------
-- 送信先グループマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_destination_group;
-- テーブル作成
CREATE TABLE mst_destination_group
(
    destination_group_cd bigserial NOT NULL,  --送信先グループコード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    destination_group_name character varying,  --送信先グループ名
    destination_target jsonb,  --送信対象
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_destination_group_01 PRIMARY KEY (destination_group_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_destination_group" IS E'送信先グループマスタ';
COMMENT ON COLUMN "mst_destination_group"."destination_group_cd" IS E'送信先グループコード';
COMMENT ON COLUMN "mst_destination_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_destination_group"."destination_group_name" IS E'送信先グループ名';
COMMENT ON COLUMN "mst_destination_group"."destination_target" IS E'送信対象';
COMMENT ON COLUMN "mst_destination_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_destination_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_destination_group"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_destination_group"."up_date" IS E'更新日時';
