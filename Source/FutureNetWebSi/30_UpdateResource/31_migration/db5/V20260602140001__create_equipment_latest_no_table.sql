-- テーブル削除
DROP TABLE IF EXISTS equipment_latest_no;
-- テーブル作成
CREATE TABLE equipment_latest_no
(
    facility_cd character varying NOT NULL,  --施設コード
    pat_id bigint NOT NULL,  --患者ID
    equip_info_no bigint NOT NULL,  --医療材料識別番号
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    is_disp character varying DEFAULT '1',  --表示フラグ
    is_del character varying DEFAULT '0',  --削除フラグ
    CONSTRAINT unq_equipment_latest_no_01 PRIMARY KEY (facility_cd, pat_id)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "equipment_latest_no" IS E'医療材料最新識別番号';
COMMENT ON COLUMN "equipment_latest_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "equipment_latest_no"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "equipment_latest_no"."equip_info_no" IS E'医療材料識別番号';
COMMENT ON COLUMN "equipment_latest_no"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "equipment_latest_no"."up_date" IS E'更新日時';
COMMENT ON COLUMN "equipment_latest_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "equipment_latest_no"."is_del" IS E'削除フラグ';
