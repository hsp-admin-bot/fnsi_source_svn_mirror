--作成前削除
--DROP TABLE IF EXISTS batch_convert_status;
--DROP TABLE IF EXISTS batch_convert_table_status;
--DROP TABLE IF EXISTS convert_queue;
--DROP SCHEMA IF EXISTS ntss CASCADE;

--スキーマの作成
CREATE SCHEMA ntss;

--カレントスキーマの設定
alter user convert set search_path TO ntss,public;

-- テーブル作成
CREATE TABLE batch_convert_status
(
  convert_proc_id serial NOT NULL,
  facility_cd character varying(6),
  status character varying(10),
  job_instance_id bigint,
  job_name character varying(100) NOT NULL,
  reg_date timestamp(3) without time zone,
  up_date timestamp(3) without time zone,
  CONSTRAINT unq_batch_convert_status_01 PRIMARY KEY (convert_proc_id)
-- USING INDEX TABLESPACE convert_index
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE batch_convert_status OWNER TO convert;

CREATE TABLE "ntss"."convert_pat_ind_approve_ord_no" (
  ord_no int8 NOT NULL,
  facility_cd character varying(6)
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE convert_pat_ind_approve_ord_no OWNER TO convert;

CREATE TABLE "ntss"."pat_group_detail_history" (
  "pat_group_cd" int8 NOT NULL,
  "pat_group_name" varchar,
  "pat_id" int8 NOT NULL,
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default",
   "up_date" timestamp(3),
  "reg_date" timestamp(3)
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE pat_group_detail_history OWNER TO convert;

CREATE TABLE "ntss"."pat_unique_history" (
  "pat_id" int8 NOT NULL,
  "medical_hst_info" jsonb,
  "in_out_visit_history_info" jsonb,
  "physical_info" jsonb,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "up_date" timestamp(3),
  "reg_date" timestamp(3),
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default",
  "old_up_date_unique" timestamp(3)
)WITH (
  OIDS=FALSE
);

ALTER TABLE pat_unique_history OWNER TO convert;

CREATE TABLE "ntss"."pat_main_history" (
  "pat_id" int8 NOT NULL,
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default",
  "facility_name" varchar(40),
  "is_same" varchar(1) COLLATE "pg_catalog"."default",
  "is_implant" varchar(1) COLLATE "pg_catalog"."default",
  "is_infect" varchar(1) COLLATE "pg_catalog"."default",
  "is_diabetes" varchar(1) COLLATE "pg_catalog"."default",
  "is_blood_suger_exam" varchar(1) COLLATE "pg_catalog"."default",
  "in_out_current_state" varchar(2) COLLATE "pg_catalog"."default",
  "in_out_plan_state" varchar(2) COLLATE "pg_catalog"."default",
  "in_out_plan_date" timestamp(3),
  "pat_memo_info" jsonb,
  "addition_info" jsonb,
  "charge_staff_info" jsonb,
  "pat_group_info" jsonb,
  "taboo_allergy_info" jsonb,
  "infect_info" jsonb,
  "implant_info" jsonb,
  "tare_info" jsonb,
  "off_water_info" jsonb,
  "device_set_info" jsonb,
  "acceptance_status_info" jsonb,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "up_date" timestamp(3),
  "reg_date" timestamp(3),
  "is_wheel_chair" varchar(1) COLLATE "pg_catalog"."default",
  "medical_care_info" jsonb DEFAULT '{"ward_cd": null, "facility_cd": null, "dialysis_count": null, "main_course_cd": null, "dialysis_course_cd": null, "purification_count": null, "dialysis_start_date": null, "hospital_start_date": null, "other_dialysis_count": null}'::jsonb,
  "sch_ext_end_date" varchar(8) COLLATE "pg_catalog"."default",
  "sch_ext_status" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "card_idm" varchar COLLATE "pg_catalog"."default",
  "old_up_date" timestamp(3),
  "host_notification_info" jsonb,
  "dialysis_underlying_disease" varchar,
  "wheel_chair_cd" int8,
  "wheel_chair_name" varchar(256),
  "wheel_chair_weight" numeric(6,0)
)WITH (
  OIDS=FALSE
);

ALTER TABLE pat_main_history OWNER TO convert;


CREATE TABLE "ntss"."pat_insurance_history" (
   "insurance_cd" int8,
  "pat_id" int8 NOT NULL,
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default" NOT NULL,
  "ctl_no" int8,
  "fn_pat_id" varchar(20) COLLATE "pg_catalog"."default",
  "insu_class" int4,
  "insu_name" varchar(256) COLLATE "pg_catalog"."default",
  "insu_name_short" varchar(4) COLLATE "pg_catalog"."default",
  "insu_info" jsonb,
  "insu_pub_info" jsonb,
  "insu_set_info" jsonb,
  "insu_self_info" jsonb,
  "is_selected" varchar(1) COLLATE "pg_catalog"."default",
  "is_disp" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '1'::character varying,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "coop_code" varchar(12) COLLATE "pg_catalog"."default",
  "is_coop" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "reg_date" timestamp(3),
  "up_date" timestamp(3),
  "start_date" varchar(8) COLLATE "pg_catalog"."default",
  "end_date" varchar(8) COLLATE "pg_catalog"."default",
  "check_date" varchar(8) COLLATE "pg_catalog"."default",
  "old_up_date" timestamp(3),
  "memo1" varchar COLLATE "pg_catalog"."default",
  "memo2" varchar COLLATE "pg_catalog"."default",
  "fn_ctl_no" varchar(1) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)WITH (
  OIDS=FALSE
);

ALTER TABLE pat_insurance_history OWNER TO convert;

CREATE TABLE "ntss"."pat_personal_main_history" (
  "pat_id" int8 NOT NULL,
  "fn_pat_id" varchar(12) COLLATE "pg_catalog"."default",
  "hosp_pat_id" varchar(12) COLLATE "pg_catalog"."default",
  "nkk_pat_id" varchar(20) COLLATE "pg_catalog"."default",
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default",
  "facility_name" varchar(40),
  "pat_last_name" varchar COLLATE "pg_catalog"."default",
  "pat_first_name" varchar COLLATE "pg_catalog"."default",
  "pat_last_name_kana" varchar COLLATE "pg_catalog"."default",
  "pat_first_name_kana" varchar COLLATE "pg_catalog"."default",
  "pat_last_name_alpha" varchar COLLATE "pg_catalog"."default",
  "pat_first_name_alpha" varchar COLLATE "pg_catalog"."default",
  "pat_birth_name" varchar COLLATE "pg_catalog"."default",
  "pat_birth_name_kana" varchar COLLATE "pg_catalog"."default",
  "pat_birth_name_alpha" varchar COLLATE "pg_catalog"."default",
  "pat_birthday" varchar(8) COLLATE "pg_catalog"."default",
  "pat_sex" int2,
  "nationality" varchar(3) COLLATE "pg_catalog"."default",
  "pat_blood_type_abo" int2,
  "pat_blood_type_rh" int2,
  "pat_blood_type_serovar" int2,
  "in_out_class" int2,
  "is_die" varchar(1) COLLATE "pg_catalog"."default",
  "die_cd" int4,
  "die_name" varchar,
  "die_date" timestamp(3),
  "dial_diff_com_info" jsonb,
  "severity_cd" int4,
  "severity_name" varchar,
  "transport_cd" int4,
  "transport_name" varchar,
  "pat_contact_info" jsonb DEFAULT '{"fax": null, "tel1": null, "tel2": null, "memo1": null, "memo2": null, "e_mail": null, "zip_cd": null, "address": null, "work_tel": null, "work_name": null, "work_address": null}'::jsonb,
  "other_contact_info" jsonb,
  "vendor_contact_info" jsonb,
  "insurance_info" jsonb,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "up_date" timestamp(3),
  "reg_date" timestamp(3),
  "primary_disease_cd" int4,
  "primary_disease_name" varchar,
  "remote_monitor_service" int4,
  "remote_monitor_user_id" varchar COLLATE "pg_catalog"."default",
  "remote_monitor_user_pw" varchar COLLATE "pg_catalog"."default",
  "old_up_date_personal" timestamp(3)
)WITH (
  OIDS=FALSE
);

ALTER TABLE pat_personal_main_history OWNER TO convert;


-- #11690 差分コンバート中にコンバータのデプロイ作業ができない start
CREATE TABLE "ntss"."flyway_schema_history_db4" (
  "installed_rank" int4 NOT NULL,
  "version" varchar(50) COLLATE "pg_catalog"."default",
  "description" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
  "type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "script" varchar(1000) COLLATE "pg_catalog"."default" NOT NULL,
  "checksum" int4,
  "installed_by" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "installed_on" timestamp(6) NOT NULL DEFAULT now(),
  "execution_time" int4 NOT NULL,
  "success" bool NOT NULL
);
CREATE INDEX "flyway_schema_history_db4_s_idx" ON "ntss"."flyway_schema_history_db4" USING btree (
  "success" "pg_catalog"."bool_ops" ASC NULLS LAST
);
ALTER TABLE "ntss"."flyway_schema_history_db4" ADD CONSTRAINT "flyway_schema_history_db4_pk" PRIMARY KEY ("installed_rank");

INSERT INTO "ntss"."flyway_schema_history_db4" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") VALUES (1, '1', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'null', CURRENT_TIMESTAMP, 0, 't');

ALTER TABLE "ntss"."flyway_schema_history_db4" OWNER TO convert;

CREATE TABLE "ntss"."flyway_schema_history_db5" (
  "installed_rank" int4 NOT NULL,
  "version" varchar(50) COLLATE "pg_catalog"."default",
  "description" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
  "type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "script" varchar(1000) COLLATE "pg_catalog"."default" NOT NULL,
  "checksum" int4,
  "installed_by" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "installed_on" timestamp(6) NOT NULL DEFAULT now(),
  "execution_time" int4 NOT NULL,
  "success" bool NOT NULL
);

CREATE INDEX "flyway_schema_history_db5_s_idx" ON "ntss"."flyway_schema_history_db5" USING btree (
  "success" "pg_catalog"."bool_ops" ASC NULLS LAST
);

ALTER TABLE "ntss"."flyway_schema_history_db5" ADD CONSTRAINT "flyway_schema_history_db5_pk" PRIMARY KEY ("installed_rank");

INSERT INTO "ntss"."flyway_schema_history_db5" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") VALUES (1, '1', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'null', CURRENT_TIMESTAMP, 0, 't');

ALTER TABLE "ntss"."flyway_schema_history_db5" OWNER TO convert;

CREATE TABLE "ntss"."flyway_schema_history_db6" (
  "installed_rank" int4 NOT NULL,
  "version" varchar(50) COLLATE "pg_catalog"."default",
  "description" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
  "type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "script" varchar(1000) COLLATE "pg_catalog"."default" NOT NULL,
  "checksum" int4,
  "installed_by" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "installed_on" timestamp(6) NOT NULL DEFAULT now(),
  "execution_time" int4 NOT NULL,
  "success" bool NOT NULL
);
CREATE INDEX "flyway_schema_history_db6_s_idx" ON "ntss"."flyway_schema_history_db6" USING btree (
  "success" "pg_catalog"."bool_ops" ASC NULLS LAST
);
ALTER TABLE "ntss"."flyway_schema_history_db6" ADD CONSTRAINT "flyway_schema_history_db6_pk" PRIMARY KEY ("installed_rank");
INSERT INTO "ntss"."flyway_schema_history_db6" ("installed_rank", "version", "description", "type", "script", "checksum", "installed_by", "installed_on", "execution_time", "success") VALUES (1, '1', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'null', CURRENT_TIMESTAMP, 0, 't');

ALTER TABLE "ntss"."flyway_schema_history_db6" OWNER TO convert;
-- #11690 差分コンバート中にコンバータのデプロイ作業ができない end

-- テーブル作成
CREATE TABLE batch_convert_table_status
(
  order_no bigserial NOT NULL,
  convert_proc_id integer NOT NULL,
  job_instance_id bigint,
  table_name character varying(100),
  facility_cd character varying(6),
  type_name character varying(10),
  sql_file_path character varying(200),
  status character varying(200),
  proc_name character varying(100),
  content character varying(200),
  reg_date timestamp(3) without time zone,
  CONSTRAINT unq_batch_convert_table_status_01 PRIMARY KEY (order_no)
--   USING INDEX TABLESPACE convert_index
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE batch_convert_table_status OWNER TO convert;



--一旦ログアウト
\q
