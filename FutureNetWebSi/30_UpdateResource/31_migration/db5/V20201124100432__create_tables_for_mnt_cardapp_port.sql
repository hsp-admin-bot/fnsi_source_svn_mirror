-- テーブル削除
DROP TABLE IF EXISTS mnt_cardapp_port;
-- テーブル作成
CREATE TABLE mnt_cardapp_port
(
    guid character varying(80) NOT NULL,  --カードアプリのGUID
    facility_cd character varying(6) NOT NULL,  --施設コード
    client_key character varying(256) NOT NULL,  --クライアント識別子
    port integer NOT NULL,  --ポート
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3) NOT NULL,  --更新日時

    CONSTRAINT unq_mnt_cardapp_port_01 PRIMARY KEY (guid)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mnt_cardapp_port" IS E'カードアプリポート管理';
COMMENT ON COLUMN "mnt_cardapp_port"."guid" IS E'カードアプリのGUID';
COMMENT ON COLUMN "mnt_cardapp_port"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_cardapp_port"."client_key" IS E'クライアント識別子';
COMMENT ON COLUMN "mnt_cardapp_port"."port" IS E'ポート';
COMMENT ON COLUMN "mnt_cardapp_port"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_cardapp_port"."up_date" IS E'更新日時';
