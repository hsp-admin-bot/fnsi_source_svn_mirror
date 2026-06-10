DROP TABLE "mnt_if_edge_client_connect";
CREATE TABLE "mnt_if_edge_client_connect"
(
    "facility_cd"  VARCHAR(6) COLLATE "pg_catalog"."default" NOT NULL,--'施設コード'
    "if_edge_type" int2                                      NOT NULL DEFAULT 1,--'ifedgeタイプ'
    "ip_address"   inet,--'通信サービス稼働IPアドレス'
    "reg_date"     TIMESTAMP(3),--'登録日時'
    "up_date"      TIMESTAMP(3),--'更新日時'
    PRIMARY KEY ("facility_cd", "if_edge_type")
);
COMMENT ON COLUMN "mnt_if_edge_client_connect"."facility_cd" IS '施設コード';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."if_edge_type" IS 'ifedgeタイプ';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."ip_address" IS '通信サービス稼働IPアドレス';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."reg_date" IS '登録日時';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."up_date" IS '更新日時';
COMMENT ON TABLE "mnt_if_edge_client_connect" IS '連携オーダ番号';
