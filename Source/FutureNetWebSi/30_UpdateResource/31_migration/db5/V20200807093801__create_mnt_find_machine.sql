-- 装置自動登録処理用ワークテーブル
-- テーブル削除
DROP TABLE IF EXISTS mnt_find_machine;
-- テーブル作成
CREATE TABLE mnt_find_machine
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    com_format_cd character varying(1),  --通信フォーマット
    machine_serial character varying(8) NOT NULL,  --製造番号
    com_type numeric(1,0),  --通信種別
    ip_address inet,  --IPアドレス
    device_edge_no numeric(2,0),  --デバイスエッジ番号
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_find_machine_01 PRIMARY KEY (facility_cd, com_format_cd, machine_serial, com_type, ip_address )
);
-- コメント追加
COMMENT ON TABLE "mnt_find_machine" IS E'装置自動登録処理用ワークテーブル';
COMMENT ON COLUMN "mnt_find_machine"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_find_machine"."com_format_cd" IS E'通信フォーマット';
COMMENT ON COLUMN "mnt_find_machine"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "mnt_find_machine"."com_type" IS E'通信種別';
COMMENT ON COLUMN "mnt_find_machine"."ip_address" IS E'IPアドレス';
COMMENT ON COLUMN "mnt_find_machine"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mnt_find_machine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_find_machine"."up_date" IS E'更新日時';
