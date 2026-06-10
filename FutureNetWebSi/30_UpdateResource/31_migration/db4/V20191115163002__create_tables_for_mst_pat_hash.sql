-- テーブル削除(患者用施設マスタハッシュ)
DROP TABLE IF EXISTS mst_pat_hash;
-- テーブル作成(患者用施設マスタハッシュ)
CREATE TABLE mst_pat_hash
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    hash_value character varying(100) NOT NULL,  --ハッシュ値
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_pat_hash_01 PRIMARY KEY (facility_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(患者用施設マスタハッシュ)
COMMENT ON TABLE "mst_pat_hash" IS E'患者用施設マスタハッシュ';
COMMENT ON COLUMN "mst_pat_hash"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_hash"."hash_value" IS E'ハッシュ値';
COMMENT ON COLUMN "mst_pat_hash"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_hash"."up_date" IS E'更新日時';
