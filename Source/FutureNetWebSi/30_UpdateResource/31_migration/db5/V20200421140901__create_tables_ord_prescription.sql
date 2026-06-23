-- テーブル削除
DROP TABLE IF EXISTS ord_prescription;

CREATE TABLE ord_prescription (
  ord_prescription_no bigserial NOT NULL,  --処方オーダー番号
  facility_cd character varying(6) NOT NULL,  --施設コード
  pat_id bigint NOT NULL,  --患者ID
  prescription_type character varying(1) NOT NULL,  --処方種別
  issue_date timestamp(3),  --交付日
  issue_state character varying(1) NOT NULL DEFAULT '0', 
  expiration_date timestamp(3),  --使用期限
  prescription_detail jsonb,  --処方詳細
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_ord_prescription_01 PRIMARY KEY (ord_prescription_no)
);
-- コメント追加
COMMENT ON TABLE "ord_prescription" IS E'処方情報';
COMMENT ON COLUMN "ord_prescription"."ord_prescription_no" IS E'処方オーダー番号';
COMMENT ON COLUMN "ord_prescription"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_prescription"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_prescription"."prescription_type" IS E'処方種別';
COMMENT ON COLUMN "ord_prescription"."issue_date" IS E'交付日';
COMMENT ON COLUMN "ord_prescription"."issue_state" IS E'交付状態';
COMMENT ON COLUMN "ord_prescription"."expiration_date" IS E'使用期限';
COMMENT ON COLUMN "ord_prescription"."prescription_detail" IS E'処方詳細';
COMMENT ON COLUMN "ord_prescription"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_prescription"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_prescription"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_prescription"."up_date" IS E'更新日時';