--------------------------------------------------
-- 国名マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS sys_country;
-- テーブル作成
CREATE TABLE sys_country
(
    country_cd_alpha3 character varying(3) NOT NULL,  --国名コード(alpha-3)
    country_cd_alpha2 character varying(2),  --国名コード(alpha-2)
    country_cd_numeric character varying(3),  --国名コード(Numeric)
    country_name character varying,  --国名
    country_name_alpha character varying,  --国名(英語)
    region character varying,  --地域
    CONSTRAINT unq_sys_country_01 PRIMARY KEY (country_cd_alpha3)
);
-- コメント追加
COMMENT ON TABLE "sys_country" IS E'国名マスタ';
COMMENT ON COLUMN "sys_country"."country_cd_alpha3" IS E'国名コード(alpha-3)';
COMMENT ON COLUMN "sys_country"."country_cd_alpha2" IS E'国名コード(alpha-2)';
COMMENT ON COLUMN "sys_country"."country_cd_numeric" IS E'国名コード(Numeric)';
COMMENT ON COLUMN "sys_country"."country_name" IS E'国名';
COMMENT ON COLUMN "sys_country"."country_name_alpha" IS E'国名(英語)';
COMMENT ON COLUMN "sys_country"."region" IS E'地域';
