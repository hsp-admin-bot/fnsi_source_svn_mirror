--コンバート用のfn_カラムを追加する

--mst_machine
ALTER TABLE mst_machine ADD COLUMN fn_device_no numeric(10,0);
COMMENT ON COLUMN "mst_machine"."fn_device_no" IS E'FNW+で管理する施設内の一意な装置番号';
--mst_com_fixed_phrase
ALTER TABLE mst_com_fixed_phrase ADD COLUMN fn_addition_cd character varying(10);
COMMENT ON COLUMN "mst_com_fixed_phrase"."fn_addition_cd" IS E'FNW+で管理する施設内の一意な指示簿指示コード';

--mst_pat_event_category
ALTER TABLE mst_pat_event_category ADD COLUMN fn_event_category_cd_1 bigint;
COMMENT ON COLUMN "mst_pat_event_category"."fn_event_category_cd_1" IS E'FNW+で管理する施設内の一意なイベントカテゴリコード';

--mst_pat_event_sub_category
ALTER TABLE mst_pat_event_sub_category ADD COLUMN fn_event_category_cd_2 bigint;
COMMENT ON COLUMN "mst_pat_event_sub_category"."fn_event_category_cd_2" IS E'FNW+で管理する施設内の一意なサブカテゴリコード';

--mst_spitz
ALTER TABLE mst_spitz ADD COLUMN fn_exam_set_cd character varying(4);
COMMENT ON COLUMN "mst_spitz"."fn_exam_set_cd" IS E'FNW+で管理する施設内の一意なコード';

--
ALTER TABLE mst_comp_treatment ADD COLUMN fn_comp_treatment_cd character varying(10);
COMMENT ON COLUMN "mst_comp_treatment"."fn_comp_treatment_cd" IS E'FNW+で管理する施設内の一意なコード';
--
ALTER TABLE mst_complaint ADD COLUMN fn_complaint_cd character varying(10);
COMMENT ON COLUMN "mst_complaint"."fn_complaint_cd" IS E'FNW+で管理する施設内の一意なコード';

ALTER TABLE mst_water_survey_point ADD COLUMN fn_survey_point_cd character varying(10);
COMMENT ON COLUMN "mst_water_survey_point"."fn_survey_point_cd" IS E'FNW+で管理する施設内の一意なコード';

ALTER TABLE mst_water_survey_type ADD COLUMN fn_survey_type_cd character varying(10);
COMMENT ON COLUMN "mst_water_survey_type"."fn_survey_type_cd" IS E'FNW+で管理する施設内の一意なコード';

--mst_medicine_group
ALTER TABLE mst_medicine_group ADD COLUMN fn_medicine_group_cd varchar;
COMMENT ON COLUMN "mst_medicine_group"."fn_medicine_group_cd" IS E'FNW+で管理する施設内の一意な薬剤グループコード';

--pat_group
ALTER TABLE pat_group ADD COLUMN fn_pat_group_cd varchar;
COMMENT ON COLUMN "pat_group"."fn_pat_group_cd" IS E'FNW+で管理する施設内の一意な薬剤グループコード';

--mst_job
ALTER TABLE mst_job ADD COLUMN fn_job_class_cd numeric(4,0);
COMMENT ON COLUMN "mst_job"."fn_job_class_cd" IS E'FNW+で管理する施設内の一意な職種コード';

--ord_main
ALTER TABLE ord_main ADD COLUMN fn_plural numeric(1,0);
COMMENT ON COLUMN "ord_main"."fn_plural" IS E'FNW+で管理する同日複数回';
