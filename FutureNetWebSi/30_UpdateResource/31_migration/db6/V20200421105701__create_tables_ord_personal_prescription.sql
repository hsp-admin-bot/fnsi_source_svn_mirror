-- テーブル削除
DROP TABLE IF EXISTS ord_personal_prescription;

CREATE TABLE ord_personal_prescription (
  ord_prescription_no bigint NOT NULL,  --処方オーダー番号
  facility_cd character varying(6) NOT NULL,  --施設コード
  pat_id bigint NOT NULL,  --患者ID
  insurance_cd bigint,  --保険情報コード
  insu_pub_no character varying,  --公費負担者番号
  insu_pub_pat_no character varying,  --公費負担医療の受給者番号
  insu_no character varying,  --保険者番号
  insu_pat_mark character varying,  --被保険者証・被保険者手帳記号
  insu_pat_no character varying,  --被保険者証・被保険者手帳番号
  is_insured character varying(1),  --被保険者
  is_dependent character varying(1),  --被扶養者
  insu_kbn character varying,  --保険区分
  insu_dr_id bigint,  --保険医ID
  insu_dr_name character varying,  --保険医氏名
  insu_dr_sign character varying,  --保険医署名
  is_doubt character varying(1) NOT NULL,  --疑義照会
  is_information character varying(1) NOT NULL,  --情報提供
  is_elderly character varying(1) NOT NULL,  --高一
  is_elderly7 character varying(1) NOT NULL,  --高７
  is_child character varying(1) NOT NULL,  --６歳未満
  remarks character varying,  --備考情報
  is_anesthesia character varying(1) NOT NULL,  --麻薬処方フラグ
  remarks_anesthesia character varying,  --麻薬備考情報
  remarks_free character varying,  --備考フリーコメント
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_ord_prescription_01 PRIMARY KEY (ord_prescription_no)
);
-- コメント追加
COMMENT ON TABLE "ord_personal_prescription" IS E'処方情報';
COMMENT ON COLUMN "ord_personal_prescription"."ord_prescription_no" IS E'処方オーダー番号';
COMMENT ON COLUMN "ord_personal_prescription"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_personal_prescription"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_personal_prescription"."insurance_cd" IS E'保険情報コード';
COMMENT ON COLUMN "ord_personal_prescription"."insu_pub_no" IS E'公費負担者番号';
COMMENT ON COLUMN "ord_personal_prescription"."insu_pub_pat_no" IS E'公費負担医療の受給者番号';
COMMENT ON COLUMN "ord_personal_prescription"."insu_no" IS E'保険者番号';
COMMENT ON COLUMN "ord_personal_prescription"."insu_pat_mark" IS E'被保険者証・被保険者手帳記号';
COMMENT ON COLUMN "ord_personal_prescription"."insu_pat_no" IS E'被保険者証・被保険者手帳番号';
COMMENT ON COLUMN "ord_personal_prescription"."is_insured" IS E'被保険者';
COMMENT ON COLUMN "ord_personal_prescription"."is_dependent" IS E'被扶養者';
COMMENT ON COLUMN "ord_personal_prescription"."insu_kbn" IS E'保険区分';
COMMENT ON COLUMN "ord_personal_prescription"."insu_dr_id" IS E'保険医ID';
COMMENT ON COLUMN "ord_personal_prescription"."insu_dr_name" IS E'保険医氏名';
COMMENT ON COLUMN "ord_personal_prescription"."insu_dr_sign" IS E'保険医署名';
COMMENT ON COLUMN "ord_personal_prescription"."is_doubt" IS E'疑義照会';
COMMENT ON COLUMN "ord_personal_prescription"."is_information" IS E'情報提供';
COMMENT ON COLUMN "ord_personal_prescription"."is_elderly" IS E'高一';
COMMENT ON COLUMN "ord_personal_prescription"."is_elderly7" IS E'高７';
COMMENT ON COLUMN "ord_personal_prescription"."is_child" IS E'６歳未満';
COMMENT ON COLUMN "ord_personal_prescription"."remarks" IS E'備考情報';
COMMENT ON COLUMN "ord_personal_prescription"."is_anesthesia" IS E'麻薬処方フラグ';
COMMENT ON COLUMN "ord_personal_prescription"."remarks_anesthesia" IS E'麻薬備考情報';
COMMENT ON COLUMN "ord_personal_prescription"."remarks_free" IS E'備考フリーコメント';
COMMENT ON COLUMN "ord_personal_prescription"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_personal_prescription"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_personal_prescription"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_personal_prescription"."up_date" IS E'更新日時';