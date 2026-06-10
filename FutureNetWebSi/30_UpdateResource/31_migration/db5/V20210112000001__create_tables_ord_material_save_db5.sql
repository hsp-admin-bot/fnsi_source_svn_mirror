-- テーブル削除
DROP TABLE IF EXISTS ord_material_save;
-- シーケンス削除
DROP SEQUENCE IF EXISTS ord_material_save_seq;
-- シーケンス作成
CREATE SEQUENCE ord_material_save_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
	CYCLE
  CACHE 10;
-- テーブル作成
CREATE TABLE ord_material_save
(
    ord_supplies_no BIGINT DEFAULT nextval('ord_material_save_seq'),  --管理番号
    facility_cd character varying(6),  --施設コード
    pat_id bigint,  --患者ID
    supplies_base_date character varying(8),  --データ基準日
    supplies_base_no bigserial,  --データ基準番号
    supplies_source_class character varying(2),  --データ発生元区分
    supplies_class character varying(2),  --物品区分
    supplies_cd character varying,  --物品コード
    medicine_mix_cd character varying,  --調整薬剤コード
    class_cd character varying,  --分類コード
    ind_rst_class character varying(1),  --指示·実績区分
    ind_rst_value character varying,  --指示·実績値
    receipt_value character varying,  --レセ値
    is_confirm character varying(1),  --確定フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT pk_ord_material_save_01 PRIMARY KEY(ord_supplies_no),
		CONSTRAINT unq_ord_material_save_01 UNIQUE(
			pat_id,
			supplies_base_date,
			supplies_base_no,
			supplies_source_class,
			supplies_class,
			supplies_cd,
			medicine_mix_cd,
			ind_rst_class
		)
)
WITH (
    OIDS=FALSE
);
-- ユーザ設定
ALTER TABLE ord_material_save OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "ord_material_save" IS E'計算材料保持テーブル';
COMMENT ON COLUMN "ord_material_save"."ord_supplies_no" IS E'管理番号';
COMMENT ON COLUMN "ord_material_save"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_material_save"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_material_save"."supplies_base_date" IS E'データ基準日';
COMMENT ON COLUMN "ord_material_save"."supplies_base_no" IS E'データ基準番号';
COMMENT ON COLUMN "ord_material_save"."supplies_source_class" IS E'データ発生元区分';
COMMENT ON COLUMN "ord_material_save"."supplies_class" IS E'物品区分';
COMMENT ON COLUMN "ord_material_save"."supplies_cd" IS E'物品コード';
COMMENT ON COLUMN "ord_material_save"."medicine_mix_cd" IS E'調整薬剤コード';
COMMENT ON COLUMN "ord_material_save"."class_cd" IS E'分類コード';
COMMENT ON COLUMN "ord_material_save"."ind_rst_class" IS E'指示·実績区分';
COMMENT ON COLUMN "ord_material_save"."ind_rst_value" IS E'指示·実績値';
COMMENT ON COLUMN "ord_material_save"."receipt_value" IS E'レセ値';
COMMENT ON COLUMN "ord_material_save"."is_confirm" IS E'確定フラグ';
COMMENT ON COLUMN "ord_material_save"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_material_save"."up_date" IS E'更新日時';
