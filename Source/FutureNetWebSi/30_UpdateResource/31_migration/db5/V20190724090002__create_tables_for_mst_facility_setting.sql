-- テーブル削除（施設設定マスタ）
DROP TABLE IF EXISTS mst_facility_setting;
-- テーブル作成（施設設定マスタ）
CREATE TABLE mst_facility_setting
(
    facility_setting_no character varying(4) NOT NULL,  --施設設定番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    value character varying,  --値
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
            
    CONSTRAINT unq_mst_facility_setting_01 PRIMARY KEY (facility_setting_no,facility_cd)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mst_facility_setting" IS E'施設設定マスタ';
COMMENT ON COLUMN "mst_facility_setting"."facility_setting_no" IS E'施設設定番号';
COMMENT ON COLUMN "mst_facility_setting"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_facility_setting"."value" IS E'値';
COMMENT ON COLUMN "mst_facility_setting"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_facility_setting"."up_date" IS E'更新日時';

