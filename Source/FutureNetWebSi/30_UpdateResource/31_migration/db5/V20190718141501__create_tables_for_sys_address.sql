-- テーブル削除
DROP TABLE IF EXISTS sys_address;
-- テーブル作成
CREATE TABLE sys_address
(
    city_cd character varying(5),  --全国地方公共団体コード
    zip_cd_old character varying(5),  --（旧）郵便番号（5桁）
    zip_cd character varying(7),  --郵便番号（7桁）
    pref_name_kana character varying,  --都道府県名（カナ）
    city_name_kana character varying,  --市区町村名（カナ）
    town_name_kana character varying,  --町域名（カナ）
    pref_name character varying,  --都道府県名
    city_name character varying,  --市区町村名
    town_name character varying,  --町域名
    flag1 character varying(1),  --一町域が二以上の郵便番号で表される場合の表示
    flag2 character varying(1),  --小字毎に番地が起番されている町域の表示
    flag3 character varying(1),  --丁目を有する町域の場合の表示
    flag4 character varying(1),  --一つの郵便番号で二以上の町域を表す場合の表示
    flag5 character varying(1),  --更新の表示
    flag6 character varying(1),  --変更理由
    address character varying NOT NULL,  --住所
    address_kana character varying NOT NULL  --住所（カナ）
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_address" IS E'住所マスタ';
COMMENT ON COLUMN "sys_address"."city_cd" IS E'全国地方公共団体コード';
COMMENT ON COLUMN "sys_address"."zip_cd_old" IS E'（旧）郵便番号（5桁）';
COMMENT ON COLUMN "sys_address"."zip_cd" IS E'郵便番号（7桁）';
COMMENT ON COLUMN "sys_address"."pref_name_kana" IS E'都道府県名（カナ）';
COMMENT ON COLUMN "sys_address"."city_name_kana" IS E'市区町村名（カナ）';
COMMENT ON COLUMN "sys_address"."town_name_kana" IS E'町域名（カナ）';
COMMENT ON COLUMN "sys_address"."pref_name" IS E'都道府県名';
COMMENT ON COLUMN "sys_address"."city_name" IS E'市区町村名';
COMMENT ON COLUMN "sys_address"."town_name" IS E'町域名';
COMMENT ON COLUMN "sys_address"."flag1" IS E'一町域が二以上の郵便番号で表される場合の表示';
COMMENT ON COLUMN "sys_address"."flag2" IS E'小字毎に番地が起番されている町域の表示';
COMMENT ON COLUMN "sys_address"."flag3" IS E'丁目を有する町域の場合の表示';
COMMENT ON COLUMN "sys_address"."flag4" IS E'一つの郵便番号で二以上の町域を表す場合の表示';
COMMENT ON COLUMN "sys_address"."flag5" IS E'更新の表示';
COMMENT ON COLUMN "sys_address"."flag6" IS E'変更理由';
COMMENT ON COLUMN "sys_address"."address" IS E'住所';
COMMENT ON COLUMN "sys_address"."address_kana" IS E'住所（カナ）';
