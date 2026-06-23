-- テーブル削除（患者治療パターン）
DROP TABLE IF EXISTS pat_treatment_pattern;
-- テーブル作成（患者治療パターン）
CREATE TABLE pat_treatment_pattern
(
    pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
    ctl_no bigint NOT NULL,  --管理番号
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    treat_type numeric(1,0),  --治療種別
    ind_treat_start_date character varying(8),  --適用開始日
    ind_treatment_cd integer,  --指示：治療方法コード
    ind_kur_cd bigint,  --指示：クールコード
    treat_week smallint,  --治療曜日
    ind_sch_info jsonb,  --指示：スケジュール情報
    ind_cond_info jsonb,  --指示：治療条件情報
    ind_medi_info jsonb,  --指示：投与薬剤情報
    ind_equip_info jsonb,  --指示：医療材料情報
    ind_ind_comment_info jsonb,  --指示：指示コメント情報
    ind_tare_info jsonb,  --指示：風袋補正情報
    ind_off_water_info jsonb,  --指示：除水補正情報
    ind_device_set_info jsonb,  --指示：装置設定情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_pat_treatment_pattern_01 PRIMARY KEY (pat_id,ctl_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（患者治療パターン）
COMMENT ON TABLE "pat_treatment_pattern" IS E'患者治療パターン';
COMMENT ON COLUMN "pat_treatment_pattern"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_treatment_pattern"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "pat_treatment_pattern"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_treatment_pattern"."treat_type" IS E'治療種別';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_treat_start_date" IS E'適用開始日';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_treatment_cd" IS E'指示：治療方法コード';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_kur_cd" IS E'指示：クールコード';
COMMENT ON COLUMN "pat_treatment_pattern"."treat_week" IS E'治療曜日';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_sch_info" IS E'指示：スケジュール情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_cond_info" IS E'指示：治療条件情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_medi_info" IS E'指示：投与薬剤情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_equip_info" IS E'指示：医療材料情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_ind_comment_info" IS E'指示：指示コメント情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_tare_info" IS E'指示：風袋補正情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_off_water_info" IS E'指示：除水補正情報';
COMMENT ON COLUMN "pat_treatment_pattern"."ind_device_set_info" IS E'指示：装置設定情報';
COMMENT ON COLUMN "pat_treatment_pattern"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_treatment_pattern"."up_date" IS E'更新日時';
