-- テーブル削除
DROP TABLE IF EXISTS pat_exam_pattern;
-- テーブル作成
CREATE TABLE pat_exam_pattern
(
    exam_pattern_cd bigserial NOT NULL,  --システムで管理する一意な患者検査パターンコード
	pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    facility_cd character varying(6) NOT NULL,  --施設コード
    fn_pat_id character varying(12),  --FNW+で管理する施設内の一意な患者ID
    reg_exam_date timestamp(3) NOT NULL,  --登録時検査日時
    reg_order_class character varying(1) NOT NULL,  --登録時検査区分
    exam_pattern smallint, --検査依頼パターン
	exam_week smallint,  --指定曜日
    exam_from timestamp(3),  --指定期間開始日
    exam_to timestamp(3),  --指定期間終了日
    order_exam_set_cd bigint,  --検査依頼セットコード
    exam_order_info jsonb,  --検査依頼情報
    order_label_info jsonb,  --ラベル情報
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    reg_staff bigint,  --登録スタッフ
    up_date timestamp(3), --更新日時
    up_staff bigint,  --最終更新スタッフ
	CONSTRAINT unq_pat_exam_pattern_01 PRIMARY KEY (exam_pattern_cd)

)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "pat_exam_pattern" IS E'患者検査パターン';
COMMENT ON COLUMN "pat_exam_pattern"."exam_pattern_cd" IS E'システムで管理する一意な患者検査パターンコード';
COMMENT ON COLUMN "pat_exam_pattern"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_exam_pattern"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_exam_pattern"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "pat_exam_pattern"."reg_exam_date" IS E'登録時検査日時';
COMMENT ON COLUMN "pat_exam_pattern"."reg_order_class" IS E'登録時検査区分';
COMMENT ON COLUMN "pat_exam_pattern"."exam_pattern" IS E'検査依頼パターン';
COMMENT ON COLUMN "pat_exam_pattern"."exam_week" IS E'指定曜日';
COMMENT ON COLUMN "pat_exam_pattern"."exam_from" IS E'指定期間開始日';
COMMENT ON COLUMN "pat_exam_pattern"."exam_to" IS E'指定期間終了日';
COMMENT ON COLUMN "pat_exam_pattern"."order_exam_set_cd" IS E'検査依頼セットコード';
COMMENT ON COLUMN "pat_exam_pattern"."exam_order_info" IS E'検査依頼情報';
COMMENT ON COLUMN "pat_exam_pattern"."order_label_info" IS E'ラベル情報';
COMMENT ON COLUMN "pat_exam_pattern"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_exam_pattern"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_exam_pattern"."reg_staff" IS E'登録スタッフ';
COMMENT ON COLUMN "pat_exam_pattern"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_exam_pattern"."up_staff" IS E'最終更新スタッフ';
