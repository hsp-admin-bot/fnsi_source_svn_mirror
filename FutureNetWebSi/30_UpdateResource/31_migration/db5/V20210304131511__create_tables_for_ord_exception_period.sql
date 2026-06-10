-- テーブル削除
DROP TABLE IF EXISTS ord_exception_period;
-- シーケンス削除
DROP SEQUENCE IF EXISTS ord_exception_period_seq;
-- シーケンス作成
CREATE SEQUENCE ord_exception_period_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
	CYCLE
  CACHE 10;
-- テーブル作成
CREATE TABLE ord_exception_period
(
    exception_period_no serial NOT NULL,  --管理番号
    facility_cd character varying(6),  --施設コード
    pat_id bigint,  --患者ID
    exception_period_from character varying(8),  --除外期間開始日
    exception_period_to character varying(8),  --除外期間終了日
    reg_date timestamp(3),  --登録日時
    reg_staff_id bigint,  --登録者ID
    up_date timestamp(3),  --更新日時
    upd_staff_id bigint,  --更新者ID
    CONSTRAINT unq_ord_exception_period_01 PRIMARY KEY (exception_period_no)
);
-- コメント追加
COMMENT ON TABLE "ord_exception_period" IS E'除外期間';
COMMENT ON COLUMN "ord_exception_period"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_exception_period"."exception_period_from" IS E'除外期間開始日';
COMMENT ON COLUMN "ord_exception_period"."exception_period_to" IS E'除外期間終了日';
COMMENT ON COLUMN "ord_exception_period"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_exception_period"."reg_staff_id" IS E'登録者ID';
COMMENT ON COLUMN "ord_exception_period"."up_date" IS E'更新日時';
COMMENT ON COLUMN "ord_exception_period"."upd_staff_id" IS E'更新者ID';
