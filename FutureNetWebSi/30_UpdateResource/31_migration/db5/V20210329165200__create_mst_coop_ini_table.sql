-- テーブル削除
DROP TABLE IF EXISTS mst_coop_ini;
-- テーブル作成
CREATE TABLE mst_coop_ini
(
    coop_ini_cd bigserial,  --連携設定コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_ini_memo character varying,  --設定時メモ
    coop_ini_info jsonb,  --設定詳細
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ 
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_ini_01 PRIMARY KEY (coop_ini_cd)
)
WITH (
    OIDS=FALSE
);
-- ユーザ設定
ALTER TABLE mst_coop_ini OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_coop_ini" IS E'連携設定マスタ';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_cd" IS E'連携設定コード';
COMMENT ON COLUMN "mst_coop_ini"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_memo" IS E'設定時メモ';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_info" IS E'設定詳細';
COMMENT ON COLUMN "mst_coop_ini"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_ini"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_ini"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_ini"."up_date" IS E'更新日時';
