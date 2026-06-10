-- テーブル削除（装置設定デフォルトマスタ）
DROP TABLE IF EXISTS mst_device_set_info_default;
-- テーブル作成（装置設定デフォルトマスタ）
CREATE TABLE mst_device_set_info_default
(
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd),  --施設コード
    device_set_info jsonb,  --装置設定
    tare_info jsonb,  --風袋補正情報
    off_water_info jsonb,  --除水補正情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_device_set_info_default_01 PRIMARY KEY (facility_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（装置設定デフォルトマスタ）
COMMENT ON TABLE "mst_device_set_info_default" IS E'装置設定デフォルトマスタ';
COMMENT ON COLUMN "mst_device_set_info_default"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_device_set_info_default"."device_set_info" IS E'装置設定';
COMMENT ON COLUMN "mst_device_set_info_default"."tare_info" IS E'風袋補正情報';
COMMENT ON COLUMN "mst_device_set_info_default"."off_water_info" IS E'除水補正情報';
COMMENT ON COLUMN "mst_device_set_info_default"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_device_set_info_default"."up_date" IS E'更新日時';
