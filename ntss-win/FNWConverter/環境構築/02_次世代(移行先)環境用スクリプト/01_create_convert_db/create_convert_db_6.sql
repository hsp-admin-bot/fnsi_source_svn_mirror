-- ============================================================
-- bbs_info
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."bbs_info_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."bbs_info"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".bbs_info_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_bbs_info_convert_id') THEN
    ALTER TABLE "ntss"."bbs_info" ADD CONSTRAINT "unq_bbs_info_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mni_monitor
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mni_monitor_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mni_monitor"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mni_monitor_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mni_monitor_convert_id') THEN
    ALTER TABLE "ntss"."mni_monitor" ADD CONSTRAINT "unq_mni_monitor_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mnt_mainte_main
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mnt_mainte_main_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_mainte_main"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mnt_mainte_main_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mnt_mainte_main_convert_id') THEN
    ALTER TABLE "ntss"."mnt_mainte_main" ADD CONSTRAINT "unq_mnt_mainte_main_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mnt_motion_record
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mnt_motion_record_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_motion_record"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mnt_motion_record_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mnt_motion_record_convert_id') THEN
    ALTER TABLE "ntss"."mnt_motion_record" ADD CONSTRAINT "unq_mnt_motion_record_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mnt_water_survey
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mnt_water_survey_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_water_survey"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mnt_water_survey_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mnt_water_survey_convert_id') THEN
    ALTER TABLE "ntss"."mnt_water_survey" ADD CONSTRAINT "unq_mnt_water_survey_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_add_monitor
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_add_monitor_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_add_monitor"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_add_monitor_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_add_monitor_convert_id') THEN
    ALTER TABLE "ntss"."mst_add_monitor" ADD CONSTRAINT "unq_mst_add_monitor_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_addition
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_addition_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_addition"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_addition_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_addition_convert_id') THEN
    ALTER TABLE "ntss"."mst_addition" ADD CONSTRAINT "unq_mst_addition_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_bbs_kind
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_bbs_kind_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bbs_kind"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_bbs_kind_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_bbs_kind_convert_id') THEN
    ALTER TABLE "ntss"."mst_bbs_kind" ADD CONSTRAINT "unq_mst_bbs_kind_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_bed
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_bed_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bed"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_bed_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_bed_convert_id') THEN
    ALTER TABLE "ntss"."mst_bed" ADD CONSTRAINT "unq_mst_bed_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_checklist
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_checklist_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_checklist"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_checklist_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_checklist_convert_id') THEN
    ALTER TABLE "ntss"."mst_checklist" ADD CONSTRAINT "unq_mst_checklist_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_com_fixed_phrase
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_com_fixed_phrase_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_com_fixed_phrase"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_com_fixed_phrase_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_com_fixed_phrase_convert_id') THEN
    ALTER TABLE "ntss"."mst_com_fixed_phrase" ADD CONSTRAINT "unq_mst_com_fixed_phrase_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_comp_treatment
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_comp_treatment_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comp_treatment"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_comp_treatment_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_comp_treatment_convert_id') THEN
    ALTER TABLE "ntss"."mst_comp_treatment" ADD CONSTRAINT "unq_mst_comp_treatment_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_complaint
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_complaint_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_complaint"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_complaint_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_complaint_convert_id') THEN
    ALTER TABLE "ntss"."mst_complaint" ADD CONSTRAINT "unq_mst_complaint_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_comsv_setting
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_comsv_setting_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comsv_setting"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_comsv_setting_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_comsv_setting_convert_id') THEN
    ALTER TABLE "ntss"."mst_comsv_setting" ADD CONSTRAINT "unq_mst_comsv_setting_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_course
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_course_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_course"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_course_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_course_convert_id') THEN
    ALTER TABLE "ntss"."mst_course" ADD CONSTRAINT "unq_mst_course_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_dialysis_difficulty
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_dialysis_difficulty_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialysis_difficulty"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_dialysis_difficulty_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_dialysis_difficulty_convert_id') THEN
    ALTER TABLE "ntss"."mst_dialysis_difficulty" ADD CONSTRAINT "unq_mst_dialysis_difficulty_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_dialyzer
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_dialyzer_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialyzer"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_dialyzer_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_dialyzer_convert_id') THEN
    ALTER TABLE "ntss"."mst_dialyzer" ADD CONSTRAINT "unq_mst_dialyzer_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_disease
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_disease_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_disease"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_disease_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_disease_convert_id') THEN
    ALTER TABLE "ntss"."mst_disease" ADD CONSTRAINT "unq_mst_disease_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_equipment
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_equipment_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_equipment_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_equipment_convert_id') THEN
    ALTER TABLE "ntss"."mst_equipment" ADD CONSTRAINT "unq_mst_equipment_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_equipment_class
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_equipment_class_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment_class"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_equipment_class_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_equipment_class_convert_id') THEN
    ALTER TABLE "ntss"."mst_equipment_class" ADD CONSTRAINT "unq_mst_equipment_class_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_exam_item
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_exam_item_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_item"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_exam_item_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_exam_item_convert_id') THEN
    ALTER TABLE "ntss"."mst_exam_item" ADD CONSTRAINT "unq_mst_exam_item_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_exam_set
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_exam_set_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_set"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_exam_set_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_exam_set_convert_id') THEN
    ALTER TABLE "ntss"."mst_exam_set" ADD CONSTRAINT "unq_mst_exam_set_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_favorite_facility
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_favorite_facility_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_favorite_facility"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_favorite_facility_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_favorite_facility_convert_id') THEN
    ALTER TABLE "ntss"."mst_favorite_facility" ADD CONSTRAINT "unq_mst_favorite_facility_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_holiday
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_holiday_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_holiday"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_holiday_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_holiday_convert_id') THEN
    ALTER TABLE "ntss"."mst_holiday" ADD CONSTRAINT "unq_mst_holiday_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_infection
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_infection_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_infection"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_infection_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_infection_convert_id') THEN
    ALTER TABLE "ntss"."mst_infection" ADD CONSTRAINT "unq_mst_infection_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_job
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_job_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_job"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_job_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_job_convert_id') THEN
    ALTER TABLE "ntss"."mst_job" ADD CONSTRAINT "unq_mst_job_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_kur
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_kur_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_kur"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_kur_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_kur_convert_id') THEN
    ALTER TABLE "ntss"."mst_kur" ADD CONSTRAINT "unq_mst_kur_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_machine
-- ============================================================
-- ----------------------------
-- 2. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_machine_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 3. convert_id 列を追加し）
-- ----------------------------
ALTER TABLE "ntss"."mst_machine"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_machine_convert_id_seq'::regclass);

-- ============================================================
-- mst_mainte_category
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_mainte_category_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_category"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_mainte_category_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_mainte_category_convert_id') THEN
    ALTER TABLE "ntss"."mst_mainte_category" ADD CONSTRAINT "unq_mst_mainte_category_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_mainte_detail
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_mainte_detail_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_detail"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_mainte_detail_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_mainte_detail_convert_id') THEN
    ALTER TABLE "ntss"."mst_mainte_detail" ADD CONSTRAINT "unq_mst_mainte_detail_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_mainte_layout
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_mainte_layout_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_mainte_layout_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_mainte_layout_convert_id') THEN
    ALTER TABLE "ntss"."mst_mainte_layout" ADD CONSTRAINT "unq_mst_mainte_layout_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_mainte_layout_group
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_mainte_layout_group_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout_group"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_mainte_layout_group_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_mainte_layout_group_convert_id') THEN
    ALTER TABLE "ntss"."mst_mainte_layout_group" ADD CONSTRAINT "unq_mst_mainte_layout_group_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicate_timing
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicate_timing_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicate_timing"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicate_timing_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicate_timing_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicate_timing" ADD CONSTRAINT "unq_mst_medicate_timing_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicine
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicine_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicine_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicine_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicine" ADD CONSTRAINT "unq_mst_medicine_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicine_class
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicine_class_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_class"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicine_class_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicine_class_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicine_class" ADD CONSTRAINT "unq_mst_medicine_class_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicine_group
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicine_group_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_group"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicine_group_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicine_group_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicine_group" ADD CONSTRAINT "unq_mst_medicine_group_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicine_mix
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicine_mix_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_mix"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicine_mix_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicine_mix_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicine_mix" ADD CONSTRAINT "unq_mst_medicine_mix_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_medicine_support
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_medicine_support_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_support"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_medicine_support_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_medicine_support_convert_id') THEN
    ALTER TABLE "ntss"."mst_medicine_support" ADD CONSTRAINT "unq_mst_medicine_support_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_monitor_graph
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_monitor_graph_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_monitor_graph"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_monitor_graph_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_monitor_graph_convert_id') THEN
    ALTER TABLE "ntss"."mst_monitor_graph" ADD CONSTRAINT "unq_mst_monitor_graph_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_calendar_layout
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_calendar_layout_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_calendar_layout"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_calendar_layout_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_calendar_layout_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_calendar_layout" ADD CONSTRAINT "unq_mst_pat_calendar_layout_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_event_category
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_event_category_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_category"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_event_category_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_event_category_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_event_category" ADD CONSTRAINT "unq_mst_pat_event_category_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_event_data_template
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_event_data_template_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_data_template"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_event_data_template_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_event_data_template_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_event_data_template" ADD CONSTRAINT "unq_mst_pat_event_data_template_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_event_sub_category
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_event_sub_category_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_sub_category"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_event_sub_category_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_event_sub_category_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_event_sub_category" ADD CONSTRAINT "unq_mst_pat_event_sub_category_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_list_layout
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_list_layout_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_list_layout"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_list_layout_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_list_layout_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_list_layout" ADD CONSTRAINT "unq_mst_pat_list_layout_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_pat_viewer_layout
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_pat_viewer_layout_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_viewer_layout"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_pat_viewer_layout_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_pat_viewer_layout_convert_id') THEN
    ALTER TABLE "ntss"."mst_pat_viewer_layout" ADD CONSTRAINT "unq_mst_pat_viewer_layout_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_procedure
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_procedure_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_procedure"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_procedure_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_procedure_convert_id') THEN
    ALTER TABLE "ntss"."mst_procedure" ADD CONSTRAINT "unq_mst_procedure_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_rad_set
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_rad_set_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_rad_set"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_rad_set_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_rad_set_convert_id') THEN
    ALTER TABLE "ntss"."mst_rad_set" ADD CONSTRAINT "unq_mst_rad_set_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_room_bed_group
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_room_bed_group_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_room_bed_group"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_room_bed_group_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_room_bed_group_convert_id') THEN
    ALTER TABLE "ntss"."mst_room_bed_group" ADD CONSTRAINT "unq_mst_room_bed_group_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_self_measure_result
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_self_measure_result_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_self_measure_result"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_self_measure_result_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_self_measure_result_convert_id') THEN
    ALTER TABLE "ntss"."mst_self_measure_result" ADD CONSTRAINT "unq_mst_self_measure_result_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_severity
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_severity_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_severity"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_severity_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_severity_convert_id') THEN
    ALTER TABLE "ntss"."mst_severity" ADD CONSTRAINT "unq_mst_severity_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_taboo_allergy
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_taboo_allergy_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_taboo_allergy"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_taboo_allergy_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_taboo_allergy_convert_id') THEN
    ALTER TABLE "ntss"."mst_taboo_allergy" ADD CONSTRAINT "unq_mst_taboo_allergy_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_take_medicine
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_take_medicine_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_take_medicine"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_take_medicine_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_take_medicine_convert_id') THEN
    ALTER TABLE "ntss"."mst_take_medicine" ADD CONSTRAINT "unq_mst_take_medicine_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_transport
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_transport_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_transport"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_transport_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_transport_convert_id') THEN
    ALTER TABLE "ntss"."mst_transport" ADD CONSTRAINT "unq_mst_transport_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_treatment
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_treatment_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_treatment_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_treatment_convert_id') THEN
    ALTER TABLE "ntss"."mst_treatment" ADD CONSTRAINT "unq_mst_treatment_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_treatment_set
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_treatment_set_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_set"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_treatment_set_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_treatment_set_convert_id') THEN
    ALTER TABLE "ntss"."mst_treatment_set" ADD CONSTRAINT "unq_mst_treatment_set_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_treatment_status_layout
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_treatment_status_layout_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_status_layout"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_treatment_status_layout_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_treatment_status_layout_convert_id') THEN
    ALTER TABLE "ntss"."mst_treatment_status_layout" ADD CONSTRAINT "unq_mst_treatment_status_layout_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_trend_graph_monitor_set
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_trend_graph_monitor_set_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_monitor_set"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_trend_graph_monitor_set_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_trend_graph_monitor_set_convert_id') THEN
    ALTER TABLE "ntss"."mst_trend_graph_monitor_set" ADD CONSTRAINT "unq_mst_trend_graph_monitor_set_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_trend_graph_template
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_trend_graph_template_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_template"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_trend_graph_template_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_trend_graph_template_convert_id') THEN
    ALTER TABLE "ntss"."mst_trend_graph_template" ADD CONSTRAINT "unq_mst_trend_graph_template_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_va
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_va_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_va"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_va_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_va_convert_id') THEN
    ALTER TABLE "ntss"."mst_va" ADD CONSTRAINT "unq_mst_va_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_vital_graph
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_vital_graph_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_vital_graph"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_vital_graph_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_vital_graph_convert_id') THEN
    ALTER TABLE "ntss"."mst_vital_graph" ADD CONSTRAINT "unq_mst_vital_graph_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_ward
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_ward_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_ward"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_ward_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_ward_convert_id') THEN
    ALTER TABLE "ntss"."mst_ward" ADD CONSTRAINT "unq_mst_ward_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_water_survey_point
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_water_survey_point_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_point"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_water_survey_point_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_water_survey_point_convert_id') THEN
    ALTER TABLE "ntss"."mst_water_survey_point" ADD CONSTRAINT "unq_mst_water_survey_point_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_water_survey_type
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_water_survey_type_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_type"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_water_survey_type_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_water_survey_type_convert_id') THEN
    ALTER TABLE "ntss"."mst_water_survey_type" ADD CONSTRAINT "unq_mst_water_survey_type_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_weight
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_weight_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_weight_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_weight_convert_id') THEN
    ALTER TABLE "ntss"."mst_weight" ADD CONSTRAINT "unq_mst_weight_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_weight_scale
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_weight_scale_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight_scale"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_weight_scale_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_weight_scale_convert_id') THEN
    ALTER TABLE "ntss"."mst_weight_scale" ADD CONSTRAINT "unq_mst_weight_scale_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_wheel_chair
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_wheel_chair_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_wheel_chair"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_wheel_chair_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_wheel_chair_convert_id') THEN
    ALTER TABLE "ntss"."mst_wheel_chair" ADD CONSTRAINT "unq_mst_wheel_chair_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_checklist
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_checklist_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_checklist"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_checklist_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_checklist_convert_id') THEN
    ALTER TABLE "ntss"."ord_checklist" ADD CONSTRAINT "unq_ord_checklist_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_coop_no
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_coop_no_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_coop_no"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_coop_no_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_coop_no_convert_id') THEN
    ALTER TABLE "ntss"."ord_coop_no" ADD CONSTRAINT "unq_ord_coop_no_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_exception_period
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_exception_period_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_exception_period"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_exception_period_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_exception_period_convert_id') THEN
    ALTER TABLE "ntss"."ord_exception_period" ADD CONSTRAINT "unq_ord_exception_period_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_main
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_main_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_main"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_main_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_main_convert_id') THEN
    ALTER TABLE "ntss"."ord_main" ADD CONSTRAINT "unq_ord_main_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_material_save
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_material_save_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_material_save"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_material_save_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_material_save_convert_id') THEN
    ALTER TABLE "ntss"."ord_material_save" ADD CONSTRAINT "unq_ord_material_save_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_prescription
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_prescription_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_prescription"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_prescription_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_prescription_convert_id') THEN
    ALTER TABLE "ntss"."ord_prescription" ADD CONSTRAINT "unq_ord_prescription_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_treat_condition
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_treat_condition_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_treat_condition"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_treat_condition_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_treat_condition_convert_id') THEN
    ALTER TABLE "ntss"."ord_treat_condition" ADD CONSTRAINT "unq_ord_treat_condition_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- ord_weight_scale
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."ord_weight_scale_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_weight_scale"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".ord_weight_scale_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_ord_weight_scale_convert_id') THEN
    ALTER TABLE "ntss"."ord_weight_scale" ADD CONSTRAINT "unq_ord_weight_scale_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_coop_detail
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_coop_detail_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_coop_detail"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_coop_detail_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_coop_detail_convert_id') THEN
    ALTER TABLE "ntss"."pat_coop_detail" ADD CONSTRAINT "unq_pat_coop_detail_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_event
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_event_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_event"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_event_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_event_convert_id') THEN
    ALTER TABLE "ntss"."pat_event" ADD CONSTRAINT "unq_pat_event_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_exam_main
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_exam_main_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_exam_main"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_exam_main_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_exam_main_convert_id') THEN
    ALTER TABLE "ntss"."pat_exam_main" ADD CONSTRAINT "unq_pat_exam_main_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_group  (主キー制約なし; シーケンスあり)
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_group_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_group"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_group_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_group_convert_id') THEN
    ALTER TABLE "ntss"."pat_group" ADD CONSTRAINT "unq_pat_group_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_ind_approve_history
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_ind_approve_history_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_ind_approve_history"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_ind_approve_history_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_ind_approve_history_convert_id') THEN
    ALTER TABLE "ntss"."pat_ind_approve_history" ADD CONSTRAINT "unq_pat_ind_approve_history_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_rad_main
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_rad_main_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_rad_main"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_rad_main_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_rad_main_convert_id') THEN
    ALTER TABLE "ntss"."pat_rad_main" ADD CONSTRAINT "unq_pat_rad_main_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- mst_personal_user
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."mst_personal_user_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_personal_user"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".mst_personal_user_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_mst_personal_user_convert_id') THEN
    ALTER TABLE "ntss"."mst_personal_user" ADD CONSTRAINT "unq_mst_personal_user_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_insurance
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_insurance_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_insurance"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_insurance_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_insurance_convert_id') THEN
    ALTER TABLE "ntss"."pat_insurance" ADD CONSTRAINT "unq_pat_insurance_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;

-- ============================================================
-- pat_personal_main
-- ============================================================
-- ----------------------------
-- 3. 新しい主キー列 convert_id 用のシーケンスを作成（冪等）
-- ----------------------------
CREATE SEQUENCE IF NOT EXISTS "ntss"."pat_personal_main_convert_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- 4. convert_id 列を追加し、主キーに設定（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_personal_main"
    ADD COLUMN IF NOT EXISTS "convert_id" int8 NOT NULL DEFAULT nextval('"ntss".pat_personal_main_convert_id_seq'::regclass);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_pat_personal_main_convert_id') THEN
    ALTER TABLE "ntss"."pat_personal_main" ADD CONSTRAINT "unq_pat_personal_main_convert_id" PRIMARY KEY ("convert_id");
  END IF;
END $$;



