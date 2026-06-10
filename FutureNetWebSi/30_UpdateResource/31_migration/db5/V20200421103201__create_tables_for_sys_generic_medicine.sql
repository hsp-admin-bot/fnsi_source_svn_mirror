-- テーブル作成
DROP TABLE IF EXISTS sys_generic_medicine;
CREATE TABLE sys_generic_medicine
(
    medicine_type character varying NOT NULL, --区分
    generic_cd character varying(12) NOT NULL, --一般名コード
    generic_name character varying, --一般名処方の標準的な記載
    ingredient character varying, --成分名
    strength character varying, --規格
    unit_first character varying, --第一単位
    unit_second character varying, --第二単位
    addition_type character varying, --一般名処方加算対象
    exception_cd character varying, --例外コード
    min_price character varying, --同一剤形・規格内の最低薬価
    notes character varying, --備考
    search_code_list jsonb, --検索コードリスト
    is_disp character varying(1), --表示フラグ
    is_del character varying(1), --削除フラグ
    reg_date timestamp without time zone, --登録日時
    up_date timestamp without time zone, --更新日時
    CONSTRAINT sys_generic_medicine_pkey PRIMARY KEY (generic_cd, medicine_type)
);

-- コメント追加
COMMENT ON TABLE "sys_generic_medicine" IS E'一般名処方マスタ';
COMMENT ON COLUMN "sys_generic_medicine"."medicine_type" IS E'区分';
COMMENT ON COLUMN "sys_generic_medicine"."generic_cd" IS E'一般名コード';
COMMENT ON COLUMN "sys_generic_medicine"."generic_name" IS E'一般名処方の標準的な記載';
COMMENT ON COLUMN "sys_generic_medicine"."ingredient" IS E'成分名';
COMMENT ON COLUMN "sys_generic_medicine"."strength" IS E'規格';
COMMENT ON COLUMN "sys_generic_medicine"."unit_first" IS E'第一単位';
COMMENT ON COLUMN "sys_generic_medicine"."unit_second" IS E'第二単位';
COMMENT ON COLUMN "sys_generic_medicine"."addition_type" IS E'一般名処方加算対象';
COMMENT ON COLUMN "sys_generic_medicine"."exception_cd" IS E'例外コード';
COMMENT ON COLUMN "sys_generic_medicine"."min_price" IS E'同一剤形・規格内の最低薬価';
COMMENT ON COLUMN "sys_generic_medicine"."notes" IS E'備考';
COMMENT ON COLUMN "sys_generic_medicine"."search_code_list" IS E'検索コードリスト';
COMMENT ON COLUMN "sys_generic_medicine"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_generic_medicine"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_generic_medicine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_generic_medicine"."up_date" IS E'更新日時';
