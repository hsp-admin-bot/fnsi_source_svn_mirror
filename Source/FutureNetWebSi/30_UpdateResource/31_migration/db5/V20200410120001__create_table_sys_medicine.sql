-- テーブル削除
DROP TABLE IF EXISTS sys_medicine;
-- テーブル作成
CREATE TABLE sys_medicine
(
    standard_no character varying(13),  --基準番号(ＨＯＴコード)
    prescription_no character varying(7),  --処方用番号(ＨＯＴ７)
    company_no character varying(2),  --会社識別番号
    dispensing_no character varying(2),  --調剤用番号
    logistics_no character varying(2),  --物流用番号
    jan_cd character varying(13) NOT NULL,  --ＪＡＮコード
    drug_price_standard_cd character varying(12),  --薬価基準収載医薬品コード
    standard_medicine_cd character varying(12),  --個別医薬品コード
    receipt_cd_1 character varying(9),  --レセプト電算処理システムコード(1)
    receipt_cd_2 character varying(9),  --レセプト電算処理システムコード(2)
    notice_name character varying(120),  --告示名称
    sales_name character varying(120),  --販売名
    receipt_medicine_name character varying(90),  --レセプト電算処理システム医薬品名
    standard_unit character varying(80),  --規格単位
    pkg_presentation character varying(16),  --包装形態
    pkg_amount numeric(12,4),  --包装単位(数)
    pkg_unit character varying(16),  --包装単位(単位)
    pkg_total_amount numeric(12,4),  --包装総量(数)
    pkg_total_unit character varying(16),  --包装総量(単位)
    usage_category_class character varying(1),  --区分
    manufacture_company character varying(30),  --製造会社
    sales_company character varying(25),  --販売会社
    record_class character varying(1),  --レコード区分
    standard_up_date character varying(8),  --更新年月日
    pkg_qty_quantity numeric(12,4),  --包装数量(数量)
    pkg_qty_unit character varying(16),  --包装数量(単位)
    pkg_qty_per_carton_quantity numeric(12,4),  --包装入数(数量)
    pkg_qty_per_carton_unit character varying(16),  --包装入数(単位)
    unit character varying,  --指示単位
    unit_second character varying,  --レセ単位
    unit_converted_amount numeric,  --指示単位換算量
    unit_converted_amount_second numeric,  --レセ単位換算量
    unit_decimal_point integer,  --指示単位小数部桁数
    unit_decimal_point_second integer,  --レセ単位小数部桁数
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_medicine_01 PRIMARY KEY (jan_cd)
);
-- コメント追加
COMMENT ON TABLE "sys_medicine" IS E'標準医薬品マスタ';
COMMENT ON COLUMN "sys_medicine"."standard_no" IS E'基準番号(ＨＯＴコード)';
COMMENT ON COLUMN "sys_medicine"."prescription_no" IS E'処方用番号(ＨＯＴ７)';
COMMENT ON COLUMN "sys_medicine"."company_no" IS E'会社識別番号';
COMMENT ON COLUMN "sys_medicine"."dispensing_no" IS E'調剤用番号';
COMMENT ON COLUMN "sys_medicine"."logistics_no" IS E'物流用番号';
COMMENT ON COLUMN "sys_medicine"."jan_cd" IS E'ＪＡＮコード';
COMMENT ON COLUMN "sys_medicine"."drug_price_standard_cd" IS E'薬価基準収載医薬品コード';
COMMENT ON COLUMN "sys_medicine"."standard_medicine_cd" IS E'個別医薬品コード';
COMMENT ON COLUMN "sys_medicine"."receipt_cd_1" IS E'レセプト電算処理システムコード(1)';
COMMENT ON COLUMN "sys_medicine"."receipt_cd_2" IS E'レセプト電算処理システムコード(2)';
COMMENT ON COLUMN "sys_medicine"."notice_name" IS E'告示名称';
COMMENT ON COLUMN "sys_medicine"."sales_name" IS E'販売名';
COMMENT ON COLUMN "sys_medicine"."receipt_medicine_name" IS E'レセプト電算処理システム医薬品名';
COMMENT ON COLUMN "sys_medicine"."standard_unit" IS E'規格単位';
COMMENT ON COLUMN "sys_medicine"."pkg_presentation" IS E'包装形態';
COMMENT ON COLUMN "sys_medicine"."pkg_amount" IS E'包装単位(数)';
COMMENT ON COLUMN "sys_medicine"."pkg_unit" IS E'包装単位(単位)';
COMMENT ON COLUMN "sys_medicine"."pkg_total_amount" IS E'包装総量(数)';
COMMENT ON COLUMN "sys_medicine"."pkg_total_unit" IS E'包装総量(単位)';
COMMENT ON COLUMN "sys_medicine"."usage_category_class" IS E'区分';
COMMENT ON COLUMN "sys_medicine"."manufacture_company" IS E'製造会社';
COMMENT ON COLUMN "sys_medicine"."sales_company" IS E'販売会社';
COMMENT ON COLUMN "sys_medicine"."record_class" IS E'レコード区分';
COMMENT ON COLUMN "sys_medicine"."standard_up_date" IS E'更新年月日';
COMMENT ON COLUMN "sys_medicine"."pkg_qty_quantity" IS E'包装数量(数量)';
COMMENT ON COLUMN "sys_medicine"."pkg_qty_unit" IS E'包装数量(単位)';
COMMENT ON COLUMN "sys_medicine"."pkg_qty_per_carton_quantity" IS E'包装入数(数量)';
COMMENT ON COLUMN "sys_medicine"."pkg_qty_per_carton_unit" IS E'包装入数(単位)';
COMMENT ON COLUMN "sys_medicine"."unit" IS E'指示単位';
COMMENT ON COLUMN "sys_medicine"."unit_second" IS E'レセ単位';
COMMENT ON COLUMN "sys_medicine"."unit_converted_amount" IS E'指示単位換算量';
COMMENT ON COLUMN "sys_medicine"."unit_converted_amount_second" IS E'レセ単位換算量';
COMMENT ON COLUMN "sys_medicine"."unit_decimal_point" IS E'指示単位小数部桁数';
COMMENT ON COLUMN "sys_medicine"."unit_decimal_point_second" IS E'レセ単位小数部桁数';
COMMENT ON COLUMN "sys_medicine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_medicine"."up_date" IS E'更新日時';
