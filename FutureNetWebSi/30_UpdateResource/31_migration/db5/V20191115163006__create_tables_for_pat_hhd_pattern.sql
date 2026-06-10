-- テーブル削除
-- テーブル削除
DROP TABLE IF EXISTS pat_hhd_pattern;
-- テーブル作成
CREATE TABLE pat_hhd_pattern
(
    pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    revision integer NOT NULL,  --版番号
    facility_cd character varying(6),  --施設コード
    ind_treat_start_date character varying(8),  --適用開始日
    bed_cd bigint,  --ベッドコード
    machine_no bigint,  --装置番号
    ind_treatment_cd integer,  --指示：治療方法コード
    ind_cond_info jsonb,  --指示：治療条件情報
    ind_medi_info jsonb,  --指示：投与薬剤情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_pat_hhd_pattern_01 PRIMARY KEY (pat_id,revision)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "pat_hhd_pattern" IS E'在宅患者治療パターン';
COMMENT ON COLUMN "pat_hhd_pattern"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_hhd_pattern"."revision" IS E'版番号';
COMMENT ON COLUMN "pat_hhd_pattern"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_hhd_pattern"."ind_treat_start_date" IS E'適用開始日';
COMMENT ON COLUMN "pat_hhd_pattern"."bed_cd" IS E'ベッドコード';
COMMENT ON COLUMN "pat_hhd_pattern"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "pat_hhd_pattern"."ind_treatment_cd" IS E'指示：治療方法コード';
COMMENT ON COLUMN "pat_hhd_pattern"."ind_cond_info" IS E'指示：治療条件情報';
COMMENT ON COLUMN "pat_hhd_pattern"."ind_medi_info" IS E'指示：投与薬剤情報';
COMMENT ON COLUMN "pat_hhd_pattern"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_hhd_pattern"."up_date" IS E'更新日時';
