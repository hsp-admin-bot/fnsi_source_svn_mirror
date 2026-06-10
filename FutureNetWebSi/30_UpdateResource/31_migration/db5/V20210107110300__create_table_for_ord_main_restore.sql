-- Drop table

-- DROP TABLE ntss.ord_main_restore;

CREATE TABLE ord_main_restore
(
ord_no bigserial NOT NULL,  --システムで管理する一意なオーダ番号
del_date timestamp(3), --削除日時
pat_id bigint,  --システムで管理する一意な患者ID
fn_pat_id character varying(12),  --FNW+で管理する施設内の一意な患者ID
treat_date character varying(8),  --治療日
treat_week smallint,  --治療曜日
facility_cd character varying(6),  --施設コード
facility_name character varying(40),  --施設名
ind_va_cd integer,  --指示：VAコード
ind_treatment_cd integer,  --指示：治療方法コード
ind_treatment_name character varying,  --指示：治療方法名
ind_kur_cd bigint,  --指示：クールコード
ind_kur_name character varying,  --指示：クール名
ind_treat_start_time character varying(4),  --指示：治療開始時刻
ind_bed_cd bigint,  --指示：ベッドコード
ind_bed_name character varying,  --指示：ベッド名
ind_schedule_user_info jsonb,  --指示：治療予定指示者情報
ind_cond_info jsonb,  --指示：治療条件情報
ind_medi_info jsonb,  --指示：投与薬剤情報
ind_equip_info jsonb,  --指示：医療材料情報
ind_ind_comment_info jsonb,  --指示：指示コメント情報
ind_tare_info jsonb,  --指示：風袋補正
ind_off_water_info jsonb,  --指示：除水補正
ind_device_set_info jsonb,  --指示：装置設定情報
rst_fn_dialysis_no bigint,  --実績：FNW+透析番号
rst_relation_dialysis_no bigint,  --実績：関連透析番号
rst_edition integer DEFAULT 0,  --実績：版番号
rst_is_update_edition character varying(1),  --実績：版番号更新フラグ
rst_input_class smallint,  --実績：登録区分
rst_dialysis_state character varying(1) DEFAULT '0',  --実績：治療状況
rst_treatment_cd integer,  --実績：治療方法コード
rst_treatment_name character varying,  --実績：治療方法名
rst_kur_cd bigint,  --実績：クールコード
rst_kur_name character varying,  --実績：クール名
rst_bed_cd bigint,  --実績：ベッドコード
rst_bed_name character varying,  --実績：ベッド名
rst_machine_no bigint,  --実績：装置番号
rst_machine_name character varying(40),  --実績：装置名
rst_cond_send_date timestamp(3),  --実績：条件送信日時
rst_accept_date timestamp(3),  --実績：受付日時
rst_start_date timestamp(3),  --実績：治療開始日時
rst_end_date timestamp(3),  --実績：治療終了日時
rst_return_home_date timestamp(3),  --実績：帰宅日時
rst_in_out_class smallint,  --実績：入外区分
rst_dialysis_cnt integer,  --実績：透析回数
rst_ward_cd integer,  --実績：病棟コード
rst_ward_name character varying,  --実績：病棟名
rst_course_cd integer,  --実績：診療科コード
rst_course_name character varying,  --実績：診療科名
rst_puncture_user_info jsonb,  --実績：穿刺者情報
rst_return_user_info jsonb,  --実績：返血者情報
rst_charge_user_info jsonb,  --実績：担当者情報
rst_blood_circulate_total numeric(6,2),  --実績：血液循環積算値
rst_running_time smallint,  --実績：透析運転時間
rst_kt_v numeric(4,2),  --実績：Kt/V
rec_set_date timestamp(3),  --実績：透析記録確認日時
send_ctl_no bigint,  --実績：送信管理番号
blood_purifier_name character varying(40),  --実績：血液浄化装置名称
pull_leave_amount numeric(3,2),  --実績：プログラム補液引き残し量
rst_cond_info jsonb,  --実績：治療条件情報
rst_medi_info jsonb,  --実績：投与薬剤情報
rst_equip_info jsonb,  --実績：医療材料情報
rst_ind_comment_info jsonb,  --実績：指示コメント情報
rst_tare_info jsonb,  --実績：風袋補正
rst_off_water_info jsonb,  --実績：除水補正
rst_device_set_info jsonb,  --実績：装置設定情報
rst_weight_info jsonb,  --実績：体重情報
rst_vital_info jsonb,  --実績：バイタル情報
rst_complaint_info jsonb,  --実績：愁訴情報
rst_treatment_info jsonb,  --実績：愁訴処置情報
rst_treat_staff_info jsonb,  --実績：愁訴処置者情報
rst_rounds_info jsonb,  --実績：回診記録情報
is_del character varying(1) DEFAULT '0',  --削除フラグ
up_date timestamp(3),  --更新日時
CONSTRAINT unq_ord_main_restore_01 PRIMARY KEY (ord_no, del_date)
);
-- コメント追加
COMMENT ON TABLE "ord_main_restore" IS E'治療情報バックアップ';
COMMENT ON COLUMN "ord_main_restore"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "ord_main_restore"."del_date" IS E'削除日時';
COMMENT ON COLUMN "ord_main_restore"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "ord_main_restore"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "ord_main_restore"."treat_date" IS E'治療日';
COMMENT ON COLUMN "ord_main_restore"."treat_week" IS E'治療曜日';
COMMENT ON COLUMN "ord_main_restore"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_main_restore"."facility_name" IS E'施設名';
COMMENT ON COLUMN "ord_main_restore"."ind_va_cd" IS E'指示：VAコード';
COMMENT ON COLUMN "ord_main_restore"."ind_treatment_cd" IS E'指示：治療方法コード';
COMMENT ON COLUMN "ord_main_restore"."ind_treatment_name" IS E'指示：治療方法名';
COMMENT ON COLUMN "ord_main_restore"."ind_kur_cd" IS E'指示：クールコード';
COMMENT ON COLUMN "ord_main_restore"."ind_kur_name" IS E'指示：クール名';
COMMENT ON COLUMN "ord_main_restore"."ind_treat_start_time" IS E'指示：治療開始時刻';
COMMENT ON COLUMN "ord_main_restore"."ind_bed_cd" IS E'指示：ベッドコード';
COMMENT ON COLUMN "ord_main_restore"."ind_bed_name" IS E'指示：ベッド名';
COMMENT ON COLUMN "ord_main_restore"."ind_schedule_user_info" IS E'指示：治療予定指示者情報';
COMMENT ON COLUMN "ord_main_restore"."ind_cond_info" IS E'指示：治療条件情報';
COMMENT ON COLUMN "ord_main_restore"."ind_medi_info" IS E'指示：投与薬剤情報';
COMMENT ON COLUMN "ord_main_restore"."ind_equip_info" IS E'指示：医療材料情報';
COMMENT ON COLUMN "ord_main_restore"."ind_ind_comment_info" IS E'指示：指示コメント情報';
COMMENT ON COLUMN "ord_main_restore"."ind_tare_info" IS E'指示：風袋補正';
COMMENT ON COLUMN "ord_main_restore"."ind_off_water_info" IS E'指示：除水補正';
COMMENT ON COLUMN "ord_main_restore"."ind_device_set_info" IS E'指示：装置設定情報';
COMMENT ON COLUMN "ord_main_restore"."rst_fn_dialysis_no" IS E'実績：FNW+透析番号';
COMMENT ON COLUMN "ord_main_restore"."rst_relation_dialysis_no" IS E'実績：関連透析番号';
COMMENT ON COLUMN "ord_main_restore"."rst_edition" IS E'実績：版番号';
COMMENT ON COLUMN "ord_main_restore"."rst_is_update_edition" IS E'実績：版番号更新フラグ';
COMMENT ON COLUMN "ord_main_restore"."rst_input_class" IS E'実績：登録区分';
COMMENT ON COLUMN "ord_main_restore"."rst_dialysis_state" IS E'実績：治療状況';
COMMENT ON COLUMN "ord_main_restore"."rst_treatment_cd" IS E'実績：治療方法コード';
COMMENT ON COLUMN "ord_main_restore"."rst_treatment_name" IS E'実績：治療方法名';
COMMENT ON COLUMN "ord_main_restore"."rst_kur_cd" IS E'実績：クールコード';
COMMENT ON COLUMN "ord_main_restore"."rst_kur_name" IS E'実績：クール名';
COMMENT ON COLUMN "ord_main_restore"."rst_bed_cd" IS E'実績：ベッドコード';
COMMENT ON COLUMN "ord_main_restore"."rst_bed_name" IS E'実績：ベッド名';
COMMENT ON COLUMN "ord_main_restore"."rst_machine_no" IS E'実績：装置番号';
COMMENT ON COLUMN "ord_main_restore"."rst_machine_name" IS E'実績：装置名';
COMMENT ON COLUMN "ord_main_restore"."rst_cond_send_date" IS E'実績：条件送信日時';
COMMENT ON COLUMN "ord_main_restore"."rst_accept_date" IS E'実績：受付日時';
COMMENT ON COLUMN "ord_main_restore"."rst_start_date" IS E'実績：治療開始日時';
COMMENT ON COLUMN "ord_main_restore"."rst_end_date" IS E'実績：治療終了日時';
COMMENT ON COLUMN "ord_main_restore"."rst_return_home_date" IS E'実績：帰宅日時';
COMMENT ON COLUMN "ord_main_restore"."rst_in_out_class" IS E'実績：入外区分';
COMMENT ON COLUMN "ord_main_restore"."rst_dialysis_cnt" IS E'実績：透析回数';
COMMENT ON COLUMN "ord_main_restore"."rst_ward_cd" IS E'実績：病棟コード';
COMMENT ON COLUMN "ord_main_restore"."rst_ward_name" IS E'実績：病棟名';
COMMENT ON COLUMN "ord_main_restore"."rst_course_cd" IS E'実績：診療科コード';
COMMENT ON COLUMN "ord_main_restore"."rst_course_name" IS E'実績：診療科名';
COMMENT ON COLUMN "ord_main_restore"."rst_puncture_user_info" IS E'実績：穿刺者情報';
COMMENT ON COLUMN "ord_main_restore"."rst_return_user_info" IS E'実績：返血者情報';
COMMENT ON COLUMN "ord_main_restore"."rst_charge_user_info" IS E'実績：担当者情報';
COMMENT ON COLUMN "ord_main_restore"."rst_blood_circulate_total" IS E'実績：血液循環積算値';
COMMENT ON COLUMN "ord_main_restore"."rst_running_time" IS E'実績：透析運転時間';
COMMENT ON COLUMN "ord_main_restore"."rst_kt_v" IS E'実績：Kt/V';
COMMENT ON COLUMN "ord_main_restore"."rec_set_date" IS E'実績：透析記録確認日時';
COMMENT ON COLUMN "ord_main_restore"."send_ctl_no" IS E'実績：送信管理番号';
COMMENT ON COLUMN "ord_main_restore"."blood_purifier_name" IS E'実績：血液浄化装置名称';
COMMENT ON COLUMN "ord_main_restore"."pull_leave_amount" IS E'実績：プログラム補液引き残し量';
COMMENT ON COLUMN "ord_main_restore"."rst_cond_info" IS E'実績：治療条件情報';
COMMENT ON COLUMN "ord_main_restore"."rst_medi_info" IS E'実績：投与薬剤情報';
COMMENT ON COLUMN "ord_main_restore"."rst_equip_info" IS E'実績：医療材料情報';
COMMENT ON COLUMN "ord_main_restore"."rst_ind_comment_info" IS E'実績：指示コメント情報';
COMMENT ON COLUMN "ord_main_restore"."rst_tare_info" IS E'実績：風袋補正';
COMMENT ON COLUMN "ord_main_restore"."rst_off_water_info" IS E'実績：除水補正';
COMMENT ON COLUMN "ord_main_restore"."rst_device_set_info" IS E'実績：装置設定情報';
COMMENT ON COLUMN "ord_main_restore"."rst_weight_info" IS E'実績：体重情報';
COMMENT ON COLUMN "ord_main_restore"."rst_vital_info" IS E'実績：バイタル情報';
COMMENT ON COLUMN "ord_main_restore"."rst_complaint_info" IS E'実績：愁訴情報';
COMMENT ON COLUMN "ord_main_restore"."rst_treatment_info" IS E'実績：愁訴処置情報';
COMMENT ON COLUMN "ord_main_restore"."rst_treat_staff_info" IS E'実績：愁訴処置者情報';
COMMENT ON COLUMN "ord_main_restore"."rst_rounds_info" IS E'実績：回診記録情報';
COMMENT ON COLUMN "ord_main_restore"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_main_restore"."up_date" IS E'更新日時';

-- Permissions

ALTER TABLE ntss.ord_main_restore OWNER TO nkk5;
GRANT ALL ON TABLE ntss.ord_main_restore TO nkk5;
