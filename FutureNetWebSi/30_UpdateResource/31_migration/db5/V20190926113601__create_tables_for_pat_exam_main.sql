-- テーブル削除(患者検査結果)
DROP TABLE IF EXISTS pat_exam_main;
-- テーブル作成(患者検査結果)
CREATE TABLE pat_exam_main
(
    exam_main_cd bigserial NOT NULL,  --システムで管理する一意な検査結果コード
    pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    facility_cd character varying(6) NOT NULL,  --施設コード
    ord_no bigint,  --オーダ番号
    fn_pat_id character varying(12),  --FNW+で管理する施設内の一意な患者ID
    reg_exam_date timestamp(3) NOT NULL,  --登録時検査日時
    reg_order_class character varying(1) NOT NULL,  --登録時検査区分
    exam_status character varying(1),  --状況区分
    order_comment character varying(50),  --依頼時コメント
    order_exam_set_info jsonb,  --検査依頼セット情報
    exam_order_info jsonb,  --検査依頼情報
    order_label_info jsonb,  --ラベル情報
    data_gen_class character varying(1),  --データ登録区分
    result_exam_date timestamp(3),  --結果時検査日時
    result_comment character varying(50),  --結果時コメント
    exam_result_info jsonb,  --検査結果情報
    cop_order_no1 bigint,  --連携オーダ番号１
    cop_order_no2 bigint,  --連携オーダ番号２
    is_lock character varying(1),  --依頼変更可否フラグ
    ind_user_id bigint,  --指示者
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    reg_staff bigint,  --登録スタッフ
    up_date timestamp(3),  --更新日時
    up_staff bigint,  --最終更新スタッフ
    CONSTRAINT unq_pat_exam_main_01 PRIMARY KEY (exam_main_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(患者検査結果)
COMMENT ON TABLE "pat_exam_main" IS E'患者検査結果';
COMMENT ON COLUMN "pat_exam_main"."exam_main_cd" IS E'システムで管理する一意な検査結果コード';
COMMENT ON COLUMN "pat_exam_main"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_exam_main"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_exam_main"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "pat_exam_main"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "pat_exam_main"."reg_exam_date" IS E'登録時検査日時';
COMMENT ON COLUMN "pat_exam_main"."reg_order_class" IS E'登録時検査区分';
COMMENT ON COLUMN "pat_exam_main"."exam_status" IS E'状況区分';
COMMENT ON COLUMN "pat_exam_main"."order_comment" IS E'依頼時コメント';
COMMENT ON COLUMN "pat_exam_main"."order_exam_set_info" IS E'検査依頼セット情報';
COMMENT ON COLUMN "pat_exam_main"."exam_order_info" IS E'検査依頼情報';
COMMENT ON COLUMN "pat_exam_main"."order_label_info" IS E'ラベル情報';
COMMENT ON COLUMN "pat_exam_main"."data_gen_class" IS E'データ登録区分';
COMMENT ON COLUMN "pat_exam_main"."result_exam_date" IS E'結果時検査日時';
COMMENT ON COLUMN "pat_exam_main"."result_comment" IS E'結果時コメント';
COMMENT ON COLUMN "pat_exam_main"."exam_result_info" IS E'検査結果情報';
COMMENT ON COLUMN "pat_exam_main"."cop_order_no1" IS E'連携オーダ番号１';
COMMENT ON COLUMN "pat_exam_main"."cop_order_no2" IS E'連携オーダ番号２';
COMMENT ON COLUMN "pat_exam_main"."is_lock" IS E'依頼変更可否フラグ';
COMMENT ON COLUMN "pat_exam_main"."ind_user_id" IS E'指示者';
COMMENT ON COLUMN "pat_exam_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_exam_main"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_exam_main"."reg_staff" IS E'登録スタッフ';
COMMENT ON COLUMN "pat_exam_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_exam_main"."up_staff" IS E'最終更新スタッフ';
