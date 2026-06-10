-- テーブル削除
DROP TABLE IF EXISTS sys_facility;

-- テーブル作成
CREATE TABLE sys_facility
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    prefectures_cd character varying(2),  --都道府県コード
    facility_name character varying,  --施設名
    facility_short_name character varying,  --短縮施設名
    jsdt_facility_cd character varying(6),  --JSDT施設コード
    medical_institution_cd character varying(7),  --医療機関コード
    zipcd character varying,  --郵便番号
    address character varying,  --住所
    address_kana character varying,  --住所カナ
    phone_no1 character varying,  --電話番号1
    phone_no2 character varying,  --電話番号2
    fax_no1 character varying,  --FAX1
    fax_no2 character varying,  --FAX2
    is_disp character varying(1),  --表示フラグ
    is_del character varying(1),  --削除フラグ
    up_date timestamp(3),  --更新日時
    reg_date timestamp(3),  --登録日時
    CONSTRAINT unq_sys_facility_01 PRIMARY KEY (facility_cd)
);

-- コメント追加
COMMENT ON TABLE "sys_facility" IS E'全施設マスタ';
COMMENT ON COLUMN "sys_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_facility"."prefectures_cd" IS E'都道府県コード';
COMMENT ON COLUMN "sys_facility"."facility_name" IS E'施設名';
COMMENT ON COLUMN "sys_facility"."facility_short_name" IS E'短縮施設名';
COMMENT ON COLUMN "sys_facility"."jsdt_facility_cd" IS E'JSDT施設コード';
COMMENT ON COLUMN "sys_facility"."medical_institution_cd" IS E'医療機関コード';
COMMENT ON COLUMN "sys_facility"."zipcd" IS E'郵便番号';
COMMENT ON COLUMN "sys_facility"."address" IS E'住所';
COMMENT ON COLUMN "sys_facility"."address_kana" IS E'住所カナ';
COMMENT ON COLUMN "sys_facility"."phone_no1" IS E'電話番号1';
COMMENT ON COLUMN "sys_facility"."phone_no2" IS E'電話番号2';
COMMENT ON COLUMN "sys_facility"."fax_no1" IS E'FAX1';
COMMENT ON COLUMN "sys_facility"."fax_no2" IS E'FAX2';
COMMENT ON COLUMN "sys_facility"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_facility"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_facility"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_facility"."reg_date" IS E'登録日時';
