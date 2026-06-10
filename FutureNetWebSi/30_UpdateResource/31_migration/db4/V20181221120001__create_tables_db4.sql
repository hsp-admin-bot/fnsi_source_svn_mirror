-- テーブル削除（利用者マスタ）
DROP TABLE IF EXISTS mst_user_authentication;
-- テーブル作成（利用者マスタ）
CREATE TABLE mst_user_authentication
(
    user_id bigint NOT NULL,  --利用者ID（内部用ID）
    facility_cd character varying(6),  --施設コード
    disp_user_id character varying(12),  --表示用利用者ID
    user_password character varying(75) NOT NULL,  --パスワード
    failure_cnt numeric(3,0) NOT NULL DEFAULT 0,  --サインイン失敗回数
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_user_authentication_01 PRIMARY KEY (user_id),
    CONSTRAINT unq_mst_user_authentication_02 UNIQUE(facility_cd, disp_user_id)
);
-- コメント追加
COMMENT ON TABLE "mst_user_authentication" IS E'利用者マスタ';
COMMENT ON COLUMN "mst_user_authentication"."user_id" IS E'利用者ID（内部用ID）';
COMMENT ON COLUMN "mst_user_authentication"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_user_authentication"."disp_user_id" IS E'表示用利用者ID';
COMMENT ON COLUMN "mst_user_authentication"."user_password" IS E'パスワード';
COMMENT ON COLUMN "mst_user_authentication"."failure_cnt" IS E'サインイン失敗回数';
COMMENT ON COLUMN "mst_user_authentication"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_user_authentication"."up_date" IS E'更新日時';

-- テーブル削除（施設マスタハッシュ）
DROP TABLE IF EXISTS mst_facility_hash;
-- テーブル作成（施設マスタハッシュ）
CREATE TABLE mst_facility_hash
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    hash_value character varying(100) NOT NULL,  --ハッシュ値
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_facility_hash_01 PRIMARY KEY (facility_cd)
);
-- コメント追加（施設マスタハッシュ）
COMMENT ON TABLE "mst_facility_hash" IS E'施設マスタハッシュ';
COMMENT ON COLUMN "mst_facility_hash"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_facility_hash"."hash_value" IS E'ハッシュ値';
COMMENT ON COLUMN "mst_facility_hash"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_facility_hash"."up_date" IS E'更新日時';
