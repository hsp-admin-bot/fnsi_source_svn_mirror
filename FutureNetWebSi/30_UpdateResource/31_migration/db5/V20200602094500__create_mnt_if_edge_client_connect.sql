-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_client_connect;
-- テーブル作成
CREATE TABLE mnt_if_edge_client_connect
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    ip_address inet,  --通信サービス稼働IPアドレス
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_if_edge_client_connect_01 PRIMARY KEY (facility_cd)

);
-- コメント追加
COMMENT ON TABLE "mnt_if_edge_client_connect" IS E'連携オーダ番号';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."ip_address" IS E'通信サービス稼働IPアドレス';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."up_date" IS E'更新日時';
