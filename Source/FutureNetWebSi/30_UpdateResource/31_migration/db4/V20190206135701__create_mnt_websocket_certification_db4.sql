-- テーブル削除(WebSocket認証キー情報)
DROP TABLE IF EXISTS mnt_websocket_certification;
-- テーブル作成(WebSocket認証キー情報)
CREATE TABLE mnt_websocket_certification
(
    certification_cd character varying(32) NOT NULL,  --認証コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    reg_date timestamp(3),  --登録日時
    CONSTRAINT unq_mnt_websocket_certification_01 PRIMARY KEY (certification_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(WebSocket認証キー情報)
COMMENT ON TABLE "mnt_websocket_certification" IS E'WebSocket認証キー情報';
COMMENT ON COLUMN "mnt_websocket_certification"."certification_cd" IS E'認証コード';
COMMENT ON COLUMN "mnt_websocket_certification"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_websocket_certification"."reg_date" IS E'登録日時';
