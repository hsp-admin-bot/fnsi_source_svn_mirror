-- テーブル削除（利用者マスタ）
DROP TABLE IF EXISTS mst_personal_user;
-- テーブル作成（利用者マスタ）
CREATE TABLE mst_personal_user
(
    user_id bigserial NOT NULL,  --利用者ID（内部用ID）
    facility_cd character varying(6),  --施設コード
    user_type numeric(2,0),  --利用者種別
    user_last_name character varying NOT NULL,  --利用者名_姓
    user_first_name character varying NOT NULL,  --利用者名_名
    user_last_name_kana character varying,  --利用者カナ名_姓
    user_first_name_kana character varying,  --利用者カナ名_名
    user_last_name_alpha character varying,  --利用者英字名_姓
    user_first_name_alpha character varying,  --利用者英字名_名
    user_email_address_1 character varying NOT NULL,  --メールアドレス1
    user_email_address_2 character varying,  --メールアドレス2
    extension_no character varying,  --内線番号
    home_no character varying,  --自宅番号
    mobile_phone_no character varying,  --携帯番号
    fax_no character varying,  --FAX番号
    zipcd_3 character varying,  --郵便番号3
    zipcd_4 character varying,  --郵便番号4
    address character varying,  --自宅住所
    address_kana character varying,  --自宅住所かな
    job_cd character varying NOT NULL,  --職種コード
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_personal_user_01 PRIMARY KEY (user_id)
);
-- コメント追加（利用者マスタ）
COMMENT ON TABLE "mst_personal_user" IS E'利用者マスタ';
COMMENT ON COLUMN "mst_personal_user"."user_id" IS E'利用者ID（内部用ID）';
COMMENT ON COLUMN "mst_personal_user"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_personal_user"."user_type" IS E'利用者種別';
COMMENT ON COLUMN "mst_personal_user"."user_last_name" IS E'利用者名_姓';
COMMENT ON COLUMN "mst_personal_user"."user_first_name" IS E'利用者名_名';
COMMENT ON COLUMN "mst_personal_user"."user_last_name_kana" IS E'利用者カナ名_姓';
COMMENT ON COLUMN "mst_personal_user"."user_first_name_kana" IS E'利用者カナ名_名';
COMMENT ON COLUMN "mst_personal_user"."user_last_name_alpha" IS E'利用者英字名_姓';
COMMENT ON COLUMN "mst_personal_user"."user_first_name_alpha" IS E'利用者英字名_名';
COMMENT ON COLUMN "mst_personal_user"."user_email_address_1" IS E'メールアドレス1';
COMMENT ON COLUMN "mst_personal_user"."user_email_address_2" IS E'メールアドレス2';
COMMENT ON COLUMN "mst_personal_user"."extension_no" IS E'内線番号';
COMMENT ON COLUMN "mst_personal_user"."home_no" IS E'自宅番号';
COMMENT ON COLUMN "mst_personal_user"."mobile_phone_no" IS E'携帯番号';
COMMENT ON COLUMN "mst_personal_user"."fax_no" IS E'FAX番号';
COMMENT ON COLUMN "mst_personal_user"."zipcd_3" IS E'郵便番号3';
COMMENT ON COLUMN "mst_personal_user"."zipcd_4" IS E'郵便番号4';
COMMENT ON COLUMN "mst_personal_user"."address" IS E'自宅住所';
COMMENT ON COLUMN "mst_personal_user"."address_kana" IS E'自宅住所かな';
COMMENT ON COLUMN "mst_personal_user"."job_cd" IS E'職種コード';
COMMENT ON COLUMN "mst_personal_user"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_personal_user"."up_date" IS E'更新日時';
