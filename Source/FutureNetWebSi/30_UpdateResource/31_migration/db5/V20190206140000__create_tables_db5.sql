--------------------------------------------------
-- ベッドマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_bed;
-- テーブル作成
CREATE TABLE mst_bed
(
bed_cd bigserial NOT NULL,  --ベッドコード
facility_cd character varying(6),  --施設コード
bed_no integer,  --ベッド番号
bed_name character varying,  --ベッド名
shunt_position smallint,  --シャント位置
is_infection character varying(1),  --感染症フラグ
emergency_class numeric(1,0),  --緊急区分
machine_no bigint,  --装置番号
output_printer character varying,  --出力先プリンタ名
is_autoprint_before character varying(1),  --前体重測定時の自動印刷有無
is_autoprint_after character varying(1),  --後体重測定時の自動印刷有無
is_autoprint_commit character varying(1),  --実績確定時の自動印刷有無
fn_bed_no numeric(4,0),  --FNW+で管理する施設内の一意なベッド番号
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_bed_01 PRIMARY KEY (bed_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_bed" IS E'ベッドマスタ';
COMMENT ON COLUMN "mst_bed"."bed_cd" IS E'ベッドコード';
COMMENT ON COLUMN "mst_bed"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_bed"."bed_no" IS E'ベッド番号';
COMMENT ON COLUMN "mst_bed"."bed_name" IS E'ベッド名';
COMMENT ON COLUMN "mst_bed"."shunt_position" IS E'シャント位置';
COMMENT ON COLUMN "mst_bed"."is_infection" IS E'感染症フラグ';
COMMENT ON COLUMN "mst_bed"."emergency_class" IS E'緊急区分';
COMMENT ON COLUMN "mst_bed"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "mst_bed"."output_printer" IS E'出力先プリンタ名';
COMMENT ON COLUMN "mst_bed"."is_autoprint_before" IS E'前体重測定時の自動印刷有無';
COMMENT ON COLUMN "mst_bed"."is_autoprint_after" IS E'後体重測定時の自動印刷有無';
COMMENT ON COLUMN "mst_bed"."is_autoprint_commit" IS E'実績確定時の自動印刷有無';
COMMENT ON COLUMN "mst_bed"."fn_bed_no" IS E'FNW+で管理する施設内の一意なベッド番号';
COMMENT ON COLUMN "mst_bed"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_bed"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_bed"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_bed"."up_date" IS E'更新日時';

--------------------------------------------------
-- 共通定型文マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_com_fixed_phrase;
-- テーブル作成
CREATE TABLE mst_com_fixed_phrase
(
com_fixed_phrase_cd serial NOT NULL,  --共通定型文コード
facility_cd character varying(6),  --施設コード
com_fixed_phrase character varying,  --定型文
occupations jsonb,  --職種
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_com_fixed_phrase_01 PRIMARY KEY (com_fixed_phrase_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_com_fixed_phrase" IS E'共通定型文マスタ';
COMMENT ON COLUMN "mst_com_fixed_phrase"."com_fixed_phrase_cd" IS E'共通定型文コード';
COMMENT ON COLUMN "mst_com_fixed_phrase"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_com_fixed_phrase"."com_fixed_phrase" IS E'定型文';
COMMENT ON COLUMN "mst_com_fixed_phrase"."occupations" IS E'職種';
COMMENT ON COLUMN "mst_com_fixed_phrase"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_com_fixed_phrase"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_com_fixed_phrase"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_com_fixed_phrase"."up_date" IS E'更新日時';

--------------------------------------------------
-- 診療科マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_course;
-- テーブル作成
CREATE TABLE mst_course
(
course_cd serial NOT NULL,  --診療科コード
facility_cd character varying(6),  --施設コード
fn_course_cd character varying(4),  --FNW+で管理する施設内の一意な診療科コード
course_name character varying,  --診療科名
standard_course_cd smallint,  --標準診療科コード
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_course_01 PRIMARY KEY (course_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_course" IS E'診療科マスタ';
COMMENT ON COLUMN "mst_course"."course_cd" IS E'診療科コード';
COMMENT ON COLUMN "mst_course"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_course"."fn_course_cd" IS E'FNW+で管理する施設内の一意な診療科コード';
COMMENT ON COLUMN "mst_course"."course_name" IS E'診療科名';
COMMENT ON COLUMN "mst_course"."standard_course_cd" IS E'標準診療科コード';
COMMENT ON COLUMN "mst_course"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_course"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_course"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_course"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_course"."up_date" IS E'更新日時';

--------------------------------------------------
-- 透析困難マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_dialysis_difficulty;
-- テーブル作成
CREATE TABLE mst_dialysis_difficulty
(
dialysis_difficulty_cd serial NOT NULL,  --透析困難コード
facility_cd character varying(6),  --施設コード
fn_dialysis_difficulty_cd character varying(4),  --FNW+で管理する施設内の一意な透析困難コード
dialysis_difficulty_name character varying,  --透析困難名
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_dialysis_difficulty_01 PRIMARY KEY (dialysis_difficulty_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_dialysis_difficulty" IS E'透析困難マスタ';
COMMENT ON COLUMN "mst_dialysis_difficulty"."dialysis_difficulty_cd" IS E'透析困難コード';
COMMENT ON COLUMN "mst_dialysis_difficulty"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_dialysis_difficulty"."fn_dialysis_difficulty_cd" IS E'FNW+で管理する施設内の一意な透析困難コード';
COMMENT ON COLUMN "mst_dialysis_difficulty"."dialysis_difficulty_name" IS E'透析困難名';
COMMENT ON COLUMN "mst_dialysis_difficulty"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_dialysis_difficulty"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_dialysis_difficulty"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_dialysis_difficulty"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_dialysis_difficulty"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_dialysis_difficulty"."up_date" IS E'更新日時';

--------------------------------------------------
-- ダイアライザマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_dialyzer;
-- テーブル作成
CREATE TABLE mst_dialyzer
(
dialyzer_cd serial NOT NULL,  --ダイアライザコード
facility_cd character varying(6),  --施設コード
fn_dialyzer_cd character varying(10),  --FNW+で管理する施設内の一意なダイアライザコード
maker character varying,  --メーカ名
model_number character varying,  --型番
dialyzer_type character varying(1) DEFAULT '0',  --ダイアライザ種別
function_class character varying,  --機能分類
area numeric(2,1) DEFAULT 0,  --面積
ufr numeric(8,2) DEFAULT 0,  --UFR
koa numeric(4),  --KoA
material character varying,  --材質
wetdry character varying(1) DEFAULT '0',  --WET/DRY
sterilization character varying,  --滅菌
ufr_warning_max numeric(5,2) DEFAULT 1,  --UFR警告点上限
ufr_warning_min numeric(5,2) DEFAULT 0,  --UFR警告点下限
ufr_warning_reduction numeric(2) DEFAULT 0,  --UFR低下警報点
bloodamt numeric(3) DEFAULT 200,  --血流量
alqd_flood_vol numeric(3) DEFAULT 500,  --透析液流量
urea_clearance numeric(3) DEFAULT 190,  --尿素クリアランス
gas_purge_time numeric(2) DEFAULT 5,  --ガスパージ時間
substituent_wash_amt numeric(4) DEFAULT 1000,  --置換洗浄量（透析液）
membrane_wash character varying(1) DEFAULT '0',  --膜洗浄（中空糸）
in_number numeric(5),  --入り数
use_start_date character varying(8),  --使用開始日
use_end_date character varying(8),  --使用終了日
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
in_hospital_cd_3 character varying(20),  --院内コード3
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_dialyzer_01 PRIMARY KEY (dialyzer_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_dialyzer" IS E'ダイアライザマスタ';
COMMENT ON COLUMN "mst_dialyzer"."dialyzer_cd" IS E'ダイアライザコード';
COMMENT ON COLUMN "mst_dialyzer"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_dialyzer"."fn_dialyzer_cd" IS E'FNW+で管理する施設内の一意なダイアライザコード';
COMMENT ON COLUMN "mst_dialyzer"."maker" IS E'メーカ名';
COMMENT ON COLUMN "mst_dialyzer"."model_number" IS E'型番';
COMMENT ON COLUMN "mst_dialyzer"."dialyzer_type" IS E'ダイアライザ種別';
COMMENT ON COLUMN "mst_dialyzer"."function_class" IS E'機能分類';
COMMENT ON COLUMN "mst_dialyzer"."area" IS E'面積';
COMMENT ON COLUMN "mst_dialyzer"."ufr" IS E'UFR';
COMMENT ON COLUMN "mst_dialyzer"."koa" IS E'KoA';
COMMENT ON COLUMN "mst_dialyzer"."material" IS E'材質';
COMMENT ON COLUMN "mst_dialyzer"."wetdry" IS E'WET/DRY';
COMMENT ON COLUMN "mst_dialyzer"."sterilization" IS E'滅菌';
COMMENT ON COLUMN "mst_dialyzer"."ufr_warning_max" IS E'UFR警告点上限';
COMMENT ON COLUMN "mst_dialyzer"."ufr_warning_min" IS E'UFR警告点下限';
COMMENT ON COLUMN "mst_dialyzer"."ufr_warning_reduction" IS E'UFR低下警報点';
COMMENT ON COLUMN "mst_dialyzer"."bloodamt" IS E'血流量';
COMMENT ON COLUMN "mst_dialyzer"."alqd_flood_vol" IS E'透析液流量';
COMMENT ON COLUMN "mst_dialyzer"."urea_clearance" IS E'尿素クリアランス';
COMMENT ON COLUMN "mst_dialyzer"."gas_purge_time" IS E'ガスパージ時間';
COMMENT ON COLUMN "mst_dialyzer"."substituent_wash_amt" IS E'置換洗浄量（透析液）';
COMMENT ON COLUMN "mst_dialyzer"."membrane_wash" IS E'膜洗浄（中空糸）';
COMMENT ON COLUMN "mst_dialyzer"."in_number" IS E'入り数';
COMMENT ON COLUMN "mst_dialyzer"."use_start_date" IS E'使用開始日';
COMMENT ON COLUMN "mst_dialyzer"."use_end_date" IS E'使用終了日';
COMMENT ON COLUMN "mst_dialyzer"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_dialyzer"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_dialyzer"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_dialyzer"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_dialyzer"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_dialyzer"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_dialyzer"."up_date" IS E'更新日時';

--------------------------------------------------
-- 病名マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_disease;
-- テーブル作成
CREATE TABLE mst_disease
(
disease_cd serial NOT NULL,  --病名コード
facility_cd character varying(6),  --施設コード
fn_disease_cd character varying(20),  --FNW+で管理する施設内の一意な病名コード
disease_name character varying,  --病名
disease_short_name character varying,  --省略病名
standard_disease_cd integer,  --標準病名コード
p_disease_biopsy_none_cd character varying,  --原疾患生検なしコード
p_disease_biopsy_exist_cd character varying,  --原疾患生検ありコード
die_confirmed_diagnosis_none_cd character varying,  --死因確診なしコード
die_confirmed_diagnosis_exist_cd character varying,  --死因確診ありコード
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_disease_01 PRIMARY KEY (disease_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_disease" IS E'病名マスタ';
COMMENT ON COLUMN "mst_disease"."disease_cd" IS E'病名コード';
COMMENT ON COLUMN "mst_disease"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_disease"."fn_disease_cd" IS E'FNW+で管理する施設内の一意な病名コード';
COMMENT ON COLUMN "mst_disease"."disease_name" IS E'病名';
COMMENT ON COLUMN "mst_disease"."disease_short_name" IS E'省略病名';
COMMENT ON COLUMN "mst_disease"."standard_disease_cd" IS E'標準病名コード';
COMMENT ON COLUMN "mst_disease"."p_disease_biopsy_none_cd" IS E'原疾患生検なしコード';
COMMENT ON COLUMN "mst_disease"."p_disease_biopsy_exist_cd" IS E'原疾患生検ありコード';
COMMENT ON COLUMN "mst_disease"."die_confirmed_diagnosis_none_cd" IS E'死因確診なしコード';
COMMENT ON COLUMN "mst_disease"."die_confirmed_diagnosis_exist_cd" IS E'死因確診ありコード';
COMMENT ON COLUMN "mst_disease"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_disease"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_disease"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_disease"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_disease"."up_date" IS E'更新日時';

--------------------------------------------------
-- 医療材料マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_equipment;
-- テーブル作成
CREATE TABLE mst_equipment
(
equipment_cd serial NOT NULL,  --医療材料コード
facility_cd character varying(6),  --施設コード
fn_equipment_cd character varying(10),  --FNW+で管理する施設内の一意な医療材料コード
standard_equipment_cd character varying,  --標準医療材料コード
is_trial character varying(1),  --治験フラグ
equipment_name character varying,  --医療材料名
equipment_short_name character varying,  --省略医療材料名
class_cd integer,  --医療材料分類コード
unit character varying,  --単位
use_start_date character varying(8),  --使用開始日
use_end_date character varying(8),  --使用終了日
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
in_hospital_cd_3 character varying(20),  --院内コード3
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_equipment_01 PRIMARY KEY (equipment_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_equipment" IS E'医療材料マスタ';
COMMENT ON COLUMN "mst_equipment"."equipment_cd" IS E'医療材料コード';
COMMENT ON COLUMN "mst_equipment"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_equipment"."fn_equipment_cd" IS E'FNW+で管理する施設内の一意な医療材料コード';
COMMENT ON COLUMN "mst_equipment"."standard_equipment_cd" IS E'標準医療材料コード';
COMMENT ON COLUMN "mst_equipment"."is_trial" IS E'治験フラグ';
COMMENT ON COLUMN "mst_equipment"."equipment_name" IS E'医療材料名';
COMMENT ON COLUMN "mst_equipment"."equipment_short_name" IS E'省略医療材料名';
COMMENT ON COLUMN "mst_equipment"."class_cd" IS E'医療材料分類コード';
COMMENT ON COLUMN "mst_equipment"."unit" IS E'単位';
COMMENT ON COLUMN "mst_equipment"."use_start_date" IS E'使用開始日';
COMMENT ON COLUMN "mst_equipment"."use_end_date" IS E'使用終了日';
COMMENT ON COLUMN "mst_equipment"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_equipment"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_equipment"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_equipment"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_equipment"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_equipment"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_equipment"."up_date" IS E'更新日時';

--------------------------------------------------
-- 医療材料分類マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_equipment_class;
-- テーブル作成
CREATE TABLE mst_equipment_class
(
class_cd serial NOT NULL,  --分類コード
facility_cd character varying(6),  --施設コード
fn_class_cd character varying(3),  --FNW+で管理する施設内の一意な分類コード
class_name character varying,  --分類名称
class_type numeric(2),  --分類区分
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
is_editable character varying(1) DEFAULT '1',  --編集可否フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_equipment_class_01 PRIMARY KEY (class_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_equipment_class" IS E'医療材料分類マスタ';
COMMENT ON COLUMN "mst_equipment_class"."class_cd" IS E'分類コード';
COMMENT ON COLUMN "mst_equipment_class"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_equipment_class"."fn_class_cd" IS E'FNW+で管理する施設内の一意な分類コード';
COMMENT ON COLUMN "mst_equipment_class"."class_name" IS E'分類名称';
COMMENT ON COLUMN "mst_equipment_class"."class_type" IS E'分類区分';
COMMENT ON COLUMN "mst_equipment_class"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_equipment_class"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_equipment_class"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_equipment_class"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_equipment_class"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_equipment_class"."up_date" IS E'更新日時';

--------------------------------------------------
-- 医療材料セットマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_equipment_set;
-- テーブル作成
CREATE TABLE mst_equipment_set
(
equipment_set_cd serial NOT NULL,  --医療材料セットコード
facility_cd character varying(6),  --施設コード
equipment_set_name character varying,  --医療材料セット名
equipment_set_short_name character varying,  --省略医療材料セット名
set_info jsonb,  --セット情報
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_equipment_set_01 PRIMARY KEY (equipment_set_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_equipment_set" IS E'医療材料セットマスタ';
COMMENT ON COLUMN "mst_equipment_set"."equipment_set_cd" IS E'医療材料セットコード';
COMMENT ON COLUMN "mst_equipment_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_equipment_set"."equipment_set_name" IS E'医療材料セット名';
COMMENT ON COLUMN "mst_equipment_set"."equipment_set_short_name" IS E'省略医療材料セット名';
COMMENT ON COLUMN "mst_equipment_set"."set_info" IS E'セット情報';
COMMENT ON COLUMN "mst_equipment_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_equipment_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_equipment_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_equipment_set"."up_date" IS E'更新日時';

--------------------------------------------------
-- インプラントマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_implant;
-- テーブル作成
CREATE TABLE mst_implant
(
implant_cd serial NOT NULL,  --インプラントコード
facility_cd character varying(6),  --施設コード
implant_name character varying,  --インプラント名
standard_implant_cd integer,  --標準インプラントコード
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_implant_01 PRIMARY KEY (implant_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_implant" IS E'インプラントマスタ';
COMMENT ON COLUMN "mst_implant"."implant_cd" IS E'インプラントコード';
COMMENT ON COLUMN "mst_implant"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_implant"."implant_name" IS E'インプラント名';
COMMENT ON COLUMN "mst_implant"."standard_implant_cd" IS E'標準インプラントコード';
COMMENT ON COLUMN "mst_implant"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_implant"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_implant"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_implant"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_implant"."up_date" IS E'更新日時';

--------------------------------------------------
-- 感染症マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_infection;
-- テーブル作成
CREATE TABLE mst_infection
(
infection_cd serial NOT NULL,  --感染症コード
facility_cd character varying(6),  --施設コード
fn_infection_cd character varying(20),  --FNW+で管理する施設内の一意な感染症コード
infection_name character varying,  --感染症名
standard_infection_cd integer,  --標準感染症コード
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_infection_01 PRIMARY KEY (infection_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_infection" IS E'感染症マスタ';
COMMENT ON COLUMN "mst_infection"."infection_cd" IS E'感染症コード';
COMMENT ON COLUMN "mst_infection"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_infection"."fn_infection_cd" IS E'FNW+で管理する施設内の一意な感染症コード';
COMMENT ON COLUMN "mst_infection"."infection_name" IS E'感染症名';
COMMENT ON COLUMN "mst_infection"."standard_infection_cd" IS E'標準感染症コード';
COMMENT ON COLUMN "mst_infection"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_infection"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_infection"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_infection"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_infection"."up_date" IS E'更新日時';

--------------------------------------------------
-- クールマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_kur;
-- テーブル作成
CREATE TABLE mst_kur
(
kur_cd bigserial NOT NULL,  --クールコード
facility_cd character varying(6),  --施設コード
fn_kur_cd character varying(3),  --FNW+で管理する施設内の一意なクールコード
kur_name character varying,  --クール名
kur_start_time character varying(6),  --クール開始時刻
kur_end_time character varying(6),  --クール終了時刻
kur_standard_start_time character varying(6),  --クール内標準治療開始時刻
in_hospital_cd_1 character varying(20),  --院内コード1
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_kur_01 PRIMARY KEY (kur_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_kur" IS E'クールマスタ';
COMMENT ON COLUMN "mst_kur"."kur_cd" IS E'クールコード';
COMMENT ON COLUMN "mst_kur"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_kur"."fn_kur_cd" IS E'FNW+で管理する施設内の一意なクールコード';
COMMENT ON COLUMN "mst_kur"."kur_name" IS E'クール名';
COMMENT ON COLUMN "mst_kur"."kur_start_time" IS E'クール開始時刻';
COMMENT ON COLUMN "mst_kur"."kur_end_time" IS E'クール終了時刻';
COMMENT ON COLUMN "mst_kur"."kur_standard_start_time" IS E'クール内標準治療開始時刻';
COMMENT ON COLUMN "mst_kur"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_kur"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_kur"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_kur"."up_date" IS E'更新日時';

--------------------------------------------------
-- 投与タイミングマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_medicate_timing;
-- テーブル作成
CREATE TABLE mst_medicate_timing
(
medicate_timing_cd serial NOT NULL,  --投与タイミングコード
facility_cd character varying(6),  --施設コード
fn_medicate_timing_cd character varying(3),  --FNW+で管理する施設内の一意な投与タイミングコード
medicate_timing_name character varying(40),  --投与タイミング名称
dialysis_progress_cd character varying(3),  --透析工程コード
alert_time smallint,  --治療開始後通知時間
is_alert character varying(1),  --通知フラグ
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_medicate_timing_01 PRIMARY KEY (medicate_timing_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_medicate_timing" IS E'投与タイミング';
COMMENT ON COLUMN "mst_medicate_timing"."medicate_timing_cd" IS E'投与タイミングコード';
COMMENT ON COLUMN "mst_medicate_timing"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicate_timing"."fn_medicate_timing_cd" IS E'FNW+で管理する施設内の一意な投与タイミングコード';
COMMENT ON COLUMN "mst_medicate_timing"."medicate_timing_name" IS E'投与タイミング名称';
COMMENT ON COLUMN "mst_medicate_timing"."dialysis_progress_cd" IS E'透析工程コード';
COMMENT ON COLUMN "mst_medicate_timing"."alert_time" IS E'治療開始後通知時間';
COMMENT ON COLUMN "mst_medicate_timing"."is_alert" IS E'通知フラグ';
COMMENT ON COLUMN "mst_medicate_timing"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicate_timing"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicate_timing"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicate_timing"."up_date" IS E'更新日時';

--------------------------------------------------
-- 薬剤マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_medicine;
-- テーブル作成
CREATE TABLE mst_medicine
(
medicine_cd serial NOT NULL,  --薬剤コード
facility_cd character varying(6),  --施設コード
fn_medicine_cd character varying(10),  --FNW+で管理する施設内の一意な薬剤コード
standard_medicine_cd character varying(12),  --個別医薬品コード(YJコード)
is_trial character varying(1),  --治験フラグ
medicine_name character varying,  --薬剤名
medicine_short_name character varying,  --省略薬剤名
unit character varying,  --単位
unit_second character varying,  --単位(第2)
class_cd integer,  --薬剤分類コード
is_shot character varying(1),  --注射
use_start_date character varying(8),  --使用開始日
use_end_date character varying(8),  --使用終了日
is_medicated character varying(1),  --投薬実施フラグ
unit_converted_amount integer,  --単位換算量
unit_converted_amount_second integer,  --単位(第2)換算量
anticoagulant_original_quantity integer,  --抗凝固剤元数量
after_anticoagulant_quantity integer,  --抗凝固剤後数量
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
in_hospital_cd_3 character varying(20),  --院内コード3
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_medicine_01 PRIMARY KEY (medicine_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_medicine" IS E'薬剤マスタ';
COMMENT ON COLUMN "mst_medicine"."medicine_cd" IS E'薬剤コード';
COMMENT ON COLUMN "mst_medicine"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine"."fn_medicine_cd" IS E'FNW+で管理する施設内の一意な薬剤コード';
COMMENT ON COLUMN "mst_medicine"."standard_medicine_cd" IS E'個別医薬品コード(YJコード)';
COMMENT ON COLUMN "mst_medicine"."is_trial" IS E'治験フラグ';
COMMENT ON COLUMN "mst_medicine"."medicine_name" IS E'薬剤名';
COMMENT ON COLUMN "mst_medicine"."medicine_short_name" IS E'省略薬剤名';
COMMENT ON COLUMN "mst_medicine"."unit" IS E'単位';
COMMENT ON COLUMN "mst_medicine"."unit_second" IS E'単位(第2)';
COMMENT ON COLUMN "mst_medicine"."class_cd" IS E'薬剤分類コード';
COMMENT ON COLUMN "mst_medicine"."is_shot" IS E'注射';
COMMENT ON COLUMN "mst_medicine"."use_start_date" IS E'使用開始日';
COMMENT ON COLUMN "mst_medicine"."use_end_date" IS E'使用終了日';
COMMENT ON COLUMN "mst_medicine"."is_medicated" IS E'投薬実施フラグ';
COMMENT ON COLUMN "mst_medicine"."unit_converted_amount" IS E'単位換算量';
COMMENT ON COLUMN "mst_medicine"."unit_converted_amount_second" IS E'単位(第2)換算量';
COMMENT ON COLUMN "mst_medicine"."anticoagulant_original_quantity" IS E'抗凝固剤元数量';
COMMENT ON COLUMN "mst_medicine"."after_anticoagulant_quantity" IS E'抗凝固剤後数量';
COMMENT ON COLUMN "mst_medicine"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_medicine"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_medicine"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_medicine"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine"."up_date" IS E'更新日時';

--------------------------------------------------
-- 薬剤分類マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_medicine_class;
-- テーブル作成
CREATE TABLE mst_medicine_class
(
class_cd serial NOT NULL,  --分類コード
facility_cd character varying(6),  --施設コード
fn_class_cd character varying(3),  --FNW+で管理する施設内の一意な分類コード
class_name character varying,  --分類名称
class_type numeric(2),  --分類区分
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
is_editable character varying(1) DEFAULT '1',  --編集可否フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_medicine_class_01 PRIMARY KEY (class_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_medicine_class" IS E'薬剤分類マスタ';
COMMENT ON COLUMN "mst_medicine_class"."class_cd" IS E'分類コード';
COMMENT ON COLUMN "mst_medicine_class"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine_class"."fn_class_cd" IS E'FNW+で管理する施設内の一意な分類コード';
COMMENT ON COLUMN "mst_medicine_class"."class_name" IS E'分類名称';
COMMENT ON COLUMN "mst_medicine_class"."class_type" IS E'分類区分';
COMMENT ON COLUMN "mst_medicine_class"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_medicine_class"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine_class"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine_class"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_medicine_class"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine_class"."up_date" IS E'更新日時';

--------------------------------------------------
-- 薬剤セットマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_medicine_set;
-- テーブル作成
CREATE TABLE mst_medicine_set
(
medicine_set_cd serial NOT NULL,  --薬剤セットコード
facility_cd character varying(6),  --施設コード
medicine_set_name character varying,  --薬剤セット名
medicine_set_short_name character varying,  --省略薬剤セット名
set_info jsonb,  --セット情報
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_medicine_set_01 PRIMARY KEY (medicine_set_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_medicine_set" IS E'薬剤セットマスタ';
COMMENT ON COLUMN "mst_medicine_set"."medicine_set_cd" IS E'薬剤セットコード';
COMMENT ON COLUMN "mst_medicine_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine_set"."medicine_set_name" IS E'薬剤セット名';
COMMENT ON COLUMN "mst_medicine_set"."medicine_set_short_name" IS E'省略薬剤セット名';
COMMENT ON COLUMN "mst_medicine_set"."set_info" IS E'セット情報';
COMMENT ON COLUMN "mst_medicine_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine_set"."up_date" IS E'更新日時';

--------------------------------------------------
-- 患者メモマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_pat_memo;
-- テーブル作成
CREATE TABLE mst_pat_memo
(
facility_cd character varying(6) NOT NULL,  --施設コード
pat_memo_no smallint NOT NULL,  --患者メモ番号
title character varying,  --タイトル
content character varying,  --内容
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_pat_memo_01 PRIMARY KEY (facility_cd,pat_memo_no)
);
-- コメント追加
COMMENT ON TABLE "mst_pat_memo" IS E'患者メモマスタ';
COMMENT ON COLUMN "mst_pat_memo"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_memo"."pat_memo_no" IS E'患者メモ番号';
COMMENT ON COLUMN "mst_pat_memo"."title" IS E'タイトル';
COMMENT ON COLUMN "mst_pat_memo"."content" IS E'内容';
COMMENT ON COLUMN "mst_pat_memo"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_memo"."up_date" IS E'更新日時';

--------------------------------------------------
-- 手技マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_procedure;
-- テーブル作成
CREATE TABLE mst_procedure
(
procedure_cd serial NOT NULL,  --手技コード
facility_cd character varying(6),  --施設コード
fn_procedure_cd character varying(3),  --FNW+で管理する施設内の一意な手技コード
pricedure_name character varying(40),  --手技名称
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_procedure_01 PRIMARY KEY (procedure_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_procedure" IS E'手技マスタ';
COMMENT ON COLUMN "mst_procedure"."procedure_cd" IS E'手技コード';
COMMENT ON COLUMN "mst_procedure"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_procedure"."fn_procedure_cd" IS E'FNW+で管理する施設内の一意な手技コード';
COMMENT ON COLUMN "mst_procedure"."pricedure_name" IS E'手技名称';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_procedure"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_procedure"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_procedure"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_procedure"."up_date" IS E'更新日時';

--------------------------------------------------
-- 続柄マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_relationship;
-- テーブル作成
CREATE TABLE mst_relationship
(
relationship_cd serial NOT NULL,  --続柄コード
facility_cd character varying(6),  --施設コード
relationship_name character varying,  --続柄名
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_relationship_01 PRIMARY KEY (relationship_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_relationship" IS E'続柄マスタ';
COMMENT ON COLUMN "mst_relationship"."relationship_cd" IS E'続柄コード';
COMMENT ON COLUMN "mst_relationship"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_relationship"."relationship_name" IS E'続柄名';
COMMENT ON COLUMN "mst_relationship"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_relationship"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_relationship"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_relationship"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_relationship"."up_date" IS E'更新日時';

--------------------------------------------------
-- ベッドグループ・透析室マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_room_bed_group;
-- テーブル作成
CREATE TABLE mst_room_bed_group
(
room_bed_group_cd serial NOT NULL,  --透析室・ベッドグループコード
facility_cd character varying(6),  --施設コード
room_bed_group_name character varying,  --透析室・ベッドグループ名
bed_list jsonb,  --ベッド一覧
fn_room_bed_group_no character varying(3),  --FNW+で管理する施設内の一意な透析室・ベッドグループ番号
group_class smallint,  --グループ区分
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
in_hospital_cd_3 character varying(20),  --院内コード3
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_room_bed_group_01 PRIMARY KEY (room_bed_group_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_room_bed_group" IS E'ベッドグループ・透析室マスタ';
COMMENT ON COLUMN "mst_room_bed_group"."room_bed_group_cd" IS E'透析室・ベッドグループコード';
COMMENT ON COLUMN "mst_room_bed_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_room_bed_group"."room_bed_group_name" IS E'透析室・ベッドグループ名';
COMMENT ON COLUMN "mst_room_bed_group"."bed_list" IS E'ベッド一覧';
COMMENT ON COLUMN "mst_room_bed_group"."fn_room_bed_group_no" IS E'FNW+で管理する施設内の一意な透析室・ベッドグループ番号';
COMMENT ON COLUMN "mst_room_bed_group"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_room_bed_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_room_bed_group"."group_class" IS E'グループ区分';
COMMENT ON COLUMN "mst_room_bed_group"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_room_bed_group"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_room_bed_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_room_bed_group"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_room_bed_group"."up_date" IS E'更新日時';

--------------------------------------------------
-- 重症度マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_severity;
-- テーブル作成
CREATE TABLE mst_severity
(
severity_cd serial NOT NULL,  --重症度コード
facility_cd character varying(6),  --施設コード
fn_severity_cd character varying(10),  --FNW+で管理する施設内の一意な重症度コード
severity_name character varying,  --重症度名
in_hospital_cd_1 character varying(20),  --院内コード
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_severity_01 PRIMARY KEY (severity_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_severity" IS E'重症度マスタ';
COMMENT ON COLUMN "mst_severity"."severity_cd" IS E'重症度コード';
COMMENT ON COLUMN "mst_severity"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_severity"."fn_severity_cd" IS E'FNW+で管理する施設内の一意な重症度コード';
COMMENT ON COLUMN "mst_severity"."severity_name" IS E'重症度名';
COMMENT ON COLUMN "mst_severity"."in_hospital_cd_1" IS E'院内コード';
COMMENT ON COLUMN "mst_severity"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_severity"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_severity"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_severity"."up_date" IS E'更新日時';

--------------------------------------------------
-- 禁忌・アレルギーマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_taboo_allergy;
-- テーブル作成
CREATE TABLE mst_taboo_allergy
(
taboo_allergy_cd serial NOT NULL,  --禁忌・アレルギーコード
facility_cd character varying(6),  --施設コード
fn_taboo_allergy_cd character varying(10),  --FNW+で管理する施設内の一意な禁忌・アレルギーコード
content character varying(80),  --内容
detail_info jsonb,  --詳細
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_taboo_allergy_01 PRIMARY KEY (taboo_allergy_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_taboo_allergy" IS E'禁忌・アレルギーマスタ';
COMMENT ON COLUMN "mst_taboo_allergy"."taboo_allergy_cd" IS E'禁忌・アレルギーコード';
COMMENT ON COLUMN "mst_taboo_allergy"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_taboo_allergy"."fn_taboo_allergy_cd" IS E'FNW+で管理する施設内の一意な禁忌・アレルギーコード';
COMMENT ON COLUMN "mst_taboo_allergy"."content" IS E'内容';
COMMENT ON COLUMN "mst_taboo_allergy"."detail_info" IS E'詳細';
COMMENT ON COLUMN "mst_taboo_allergy"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_taboo_allergy"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_taboo_allergy"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_taboo_allergy"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_taboo_allergy"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_taboo_allergy"."up_date" IS E'更新日時';

--------------------------------------------------
-- 搬送区分マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_transport;
-- テーブル作成
CREATE TABLE mst_transport
(
transport_cd serial NOT NULL,  --搬送区分コード
facility_cd character varying(6),  --施設コード
fn_transport_cd character varying(10),  --FNW+で管理する施設内の一意な搬送区分コード
transport_name character varying,  --搬送区分名
in_hospital_cd_1 character varying(20),  --院内コード
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_transport_01 PRIMARY KEY (transport_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_transport" IS E'搬送区分マスタ';
COMMENT ON COLUMN "mst_transport"."transport_cd" IS E'搬送区分コード';
COMMENT ON COLUMN "mst_transport"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_transport"."fn_transport_cd" IS E'FNW+で管理する施設内の一意な搬送区分コード';
COMMENT ON COLUMN "mst_transport"."transport_name" IS E'搬送区分名';
COMMENT ON COLUMN "mst_transport"."in_hospital_cd_1" IS E'院内コード';
COMMENT ON COLUMN "mst_transport"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_transport"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_transport"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_transport"."up_date" IS E'更新日時';

--------------------------------------------------
-- 治療方法マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_treatment;
-- テーブル作成
CREATE TABLE mst_treatment
(
treatment_cd serial NOT NULL,  --治療方法コード
facility_cd character varying(6),  --施設コード
fn_treatment_cd character varying(20),  --FNW+で管理する施設内の一意な治療方法コード
treatment_name character varying,  --治療方法名
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
device_mode numeric(2,0),  --装置モード
report_id integer,  --治療経過表ID
report_id_hw integer,  --治療経過表ID（手書き）
report_id_bw integer,  --治療経過表ID（前体重）
report_id_aw integer,  --治療経過表ID（後体重）
report_id_dev integer,  --治療経過表ID（装置画像転送用）
graph_time_scale numeric(2,0),  --グラフ時間幅
treatment_condition_setting jsonb,  --治療条件設定
monitor_data_item_print jsonb,  --モニタデータ項目(帳票用)
monitor_data_item_screen jsonb,  --モニタデータ項目(画面用)
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_treatment_01 PRIMARY KEY (treatment_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_treatment" IS E'治療方法マスタ';
COMMENT ON COLUMN "mst_treatment"."treatment_cd" IS E'治療方法コード';
COMMENT ON COLUMN "mst_treatment"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_treatment"."fn_treatment_cd" IS E'FNW+で管理する施設内の一意な治療方法コード';
COMMENT ON COLUMN "mst_treatment"."treatment_name" IS E'治療方法名';
COMMENT ON COLUMN "mst_treatment"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_treatment"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_treatment"."device_mode" IS E'装置モード';
COMMENT ON COLUMN "mst_treatment"."report_id" IS E'治療経過表ID';
COMMENT ON COLUMN "mst_treatment"."report_id_hw" IS E'治療経過表ID（手書き）';
COMMENT ON COLUMN "mst_treatment"."report_id_bw" IS E'治療経過表ID（前体重）';
COMMENT ON COLUMN "mst_treatment"."report_id_aw" IS E'治療経過表ID（後体重）';
COMMENT ON COLUMN "mst_treatment"."report_id_dev" IS E'治療経過表ID（装置画像転送用）';
COMMENT ON COLUMN "mst_treatment"."graph_time_scale" IS E'グラフ時間幅';
COMMENT ON COLUMN "mst_treatment"."treatment_condition_setting" IS E'治療条件設定';
COMMENT ON COLUMN "mst_treatment"."monitor_data_item_print" IS E'モニタデータ項目(帳票用)';
COMMENT ON COLUMN "mst_treatment"."monitor_data_item_screen" IS E'モニタデータ項目(画面用)';
COMMENT ON COLUMN "mst_treatment"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_treatment"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_treatment"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_treatment"."up_date" IS E'更新日時';

--------------------------------------------------
-- 治療方法セットマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_treatment_set;
-- テーブル作成
CREATE TABLE mst_treatment_set
(
treatment_set_cd serial NOT NULL,  --治療方法セットコード
facility_cd character varying(6),  --施設コード
treatment_set_name character varying,  --治療方法セット名
treatment_cd integer,  --治療方法コード
ind_cond_info jsonb,  --治療条件
ind_medi_info jsonb,  --投与薬剤
ind_equip_info jsonb,  --医療材料
ind_ind_comment_info jsonb,  --指示コメント
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_treatment_set_01 PRIMARY KEY (treatment_set_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_treatment_set" IS E'治療方法セットマスタ';
COMMENT ON COLUMN "mst_treatment_set"."treatment_set_cd" IS E'治療方法セットコード';
COMMENT ON COLUMN "mst_treatment_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_treatment_set"."treatment_set_name" IS E'治療方法セット名';
COMMENT ON COLUMN "mst_treatment_set"."treatment_cd" IS E'治療方法コード';
COMMENT ON COLUMN "mst_treatment_set"."ind_cond_info" IS E'治療条件';
COMMENT ON COLUMN "mst_treatment_set"."ind_medi_info" IS E'投与薬剤';
COMMENT ON COLUMN "mst_treatment_set"."ind_equip_info" IS E'医療材料';
COMMENT ON COLUMN "mst_treatment_set"."ind_ind_comment_info" IS E'指示コメント';
COMMENT ON COLUMN "mst_treatment_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_treatment_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_treatment_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_treatment_set"."up_date" IS E'更新日時';

--------------------------------------------------
-- VAマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_va;
-- テーブル作成
CREATE TABLE mst_va
(
va_cd serial NOT NULL,  --VAコード
facility_cd character varying(6),  --施設コード
fn_va_cd character varying(4),  --FNW+で管理する施設内の一意なVAコード
va_name character varying,  --VA名
va_direct character varying(1),  --VA方向
in_hospital_cd_1 character varying(20),  --院内コード1
in_hospital_cd_2 character varying(20),  --院内コード2
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_va_01 PRIMARY KEY (va_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_va" IS E'VAマスタ';
COMMENT ON COLUMN "mst_va"."va_cd" IS E'VAコード';
COMMENT ON COLUMN "mst_va"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_va"."fn_va_cd" IS E'FNW+で管理する施設内の一意なVAコード';
COMMENT ON COLUMN "mst_va"."va_name" IS E'VA名';
COMMENT ON COLUMN "mst_va"."va_direct" IS E'VA方向';
COMMENT ON COLUMN "mst_va"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_va"."in_hospital_cd_2" IS E'院内コード2';
COMMENT ON COLUMN "mst_va"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_va"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_va"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_va"."up_date" IS E'更新日時';

--------------------------------------------------
-- 病棟マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_ward;
-- テーブル作成
CREATE TABLE mst_ward
(
ward_cd serial NOT NULL,  --病棟コード
facility_cd character varying(6),  --施設コード
fn_ward_cd character varying(4),  --FNW+で管理する施設内の一意な病棟コード
ward_name character varying,  --病棟名
in_hospital_cd_1 character varying(20),  --院内コード1
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_ward_01 PRIMARY KEY (ward_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_ward" IS E'病棟マスタ';
COMMENT ON COLUMN "mst_ward"."ward_cd" IS E'病棟コード';
COMMENT ON COLUMN "mst_ward"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_ward"."fn_ward_cd" IS E'FNW+で管理する施設内の一意な病棟コード';
COMMENT ON COLUMN "mst_ward"."ward_name" IS E'病棟名';
COMMENT ON COLUMN "mst_ward"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_ward"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_ward"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_ward"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_ward"."up_date" IS E'更新日時';

--------------------------------------------------
-- 治療情報
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS ord_main;
-- テーブル作成
CREATE TABLE ord_main
(
ord_no bigserial NOT NULL,  --システムで管理する一意なオーダ番号
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
CONSTRAINT unq_ord_main_01 PRIMARY KEY (ord_no)
);
-- コメント追加
COMMENT ON TABLE "ord_main" IS E'治療情報';
COMMENT ON COLUMN "ord_main"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "ord_main"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "ord_main"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "ord_main"."treat_date" IS E'治療日';
COMMENT ON COLUMN "ord_main"."treat_week" IS E'治療曜日';
COMMENT ON COLUMN "ord_main"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_main"."facility_name" IS E'施設名';
COMMENT ON COLUMN "ord_main"."ind_va_cd" IS E'指示：VAコード';
COMMENT ON COLUMN "ord_main"."ind_treatment_cd" IS E'指示：治療方法コード';
COMMENT ON COLUMN "ord_main"."ind_treatment_name" IS E'指示：治療方法名';
COMMENT ON COLUMN "ord_main"."ind_kur_cd" IS E'指示：クールコード';
COMMENT ON COLUMN "ord_main"."ind_kur_name" IS E'指示：クール名';
COMMENT ON COLUMN "ord_main"."ind_treat_start_time" IS E'指示：治療開始時刻';
COMMENT ON COLUMN "ord_main"."ind_bed_cd" IS E'指示：ベッドコード';
COMMENT ON COLUMN "ord_main"."ind_bed_name" IS E'指示：ベッド名';
COMMENT ON COLUMN "ord_main"."ind_schedule_user_info" IS E'指示：治療予定指示者情報';
COMMENT ON COLUMN "ord_main"."ind_cond_info" IS E'指示：治療条件情報';
COMMENT ON COLUMN "ord_main"."ind_medi_info" IS E'指示：投与薬剤情報';
COMMENT ON COLUMN "ord_main"."ind_equip_info" IS E'指示：医療材料情報';
COMMENT ON COLUMN "ord_main"."ind_ind_comment_info" IS E'指示：指示コメント情報';
COMMENT ON COLUMN "ord_main"."ind_tare_info" IS E'指示：風袋補正';
COMMENT ON COLUMN "ord_main"."ind_off_water_info" IS E'指示：除水補正';
COMMENT ON COLUMN "ord_main"."ind_device_set_info" IS E'指示：装置設定情報';
COMMENT ON COLUMN "ord_main"."rst_fn_dialysis_no" IS E'実績：FNW+透析番号';
COMMENT ON COLUMN "ord_main"."rst_relation_dialysis_no" IS E'実績：関連透析番号';
COMMENT ON COLUMN "ord_main"."rst_edition" IS E'実績：版番号';
COMMENT ON COLUMN "ord_main"."rst_is_update_edition" IS E'実績：版番号更新フラグ';
COMMENT ON COLUMN "ord_main"."rst_input_class" IS E'実績：登録区分';
COMMENT ON COLUMN "ord_main"."rst_dialysis_state" IS E'実績：治療状況';
COMMENT ON COLUMN "ord_main"."rst_treatment_cd" IS E'実績：治療方法コード';
COMMENT ON COLUMN "ord_main"."rst_treatment_name" IS E'実績：治療方法名';
COMMENT ON COLUMN "ord_main"."rst_kur_cd" IS E'実績：クールコード';
COMMENT ON COLUMN "ord_main"."rst_kur_name" IS E'実績：クール名';
COMMENT ON COLUMN "ord_main"."rst_bed_cd" IS E'実績：ベッドコード';
COMMENT ON COLUMN "ord_main"."rst_bed_name" IS E'実績：ベッド名';
COMMENT ON COLUMN "ord_main"."rst_machine_no" IS E'実績：装置番号';
COMMENT ON COLUMN "ord_main"."rst_machine_name" IS E'実績：装置名';
COMMENT ON COLUMN "ord_main"."rst_cond_send_date" IS E'実績：条件送信日時';
COMMENT ON COLUMN "ord_main"."rst_accept_date" IS E'実績：受付日時';
COMMENT ON COLUMN "ord_main"."rst_start_date" IS E'実績：治療開始日時';
COMMENT ON COLUMN "ord_main"."rst_end_date" IS E'実績：治療終了日時';
COMMENT ON COLUMN "ord_main"."rst_return_home_date" IS E'実績：帰宅日時';
COMMENT ON COLUMN "ord_main"."rst_in_out_class" IS E'実績：入外区分';
COMMENT ON COLUMN "ord_main"."rst_dialysis_cnt" IS E'実績：透析回数';
COMMENT ON COLUMN "ord_main"."rst_ward_cd" IS E'実績：病棟コード';
COMMENT ON COLUMN "ord_main"."rst_ward_name" IS E'実績：病棟名';
COMMENT ON COLUMN "ord_main"."rst_course_cd" IS E'実績：診療科コード';
COMMENT ON COLUMN "ord_main"."rst_course_name" IS E'実績：診療科名';
COMMENT ON COLUMN "ord_main"."rst_puncture_user_info" IS E'実績：穿刺者情報';
COMMENT ON COLUMN "ord_main"."rst_return_user_info" IS E'実績：返血者情報';
COMMENT ON COLUMN "ord_main"."rst_charge_user_info" IS E'実績：担当者情報';
COMMENT ON COLUMN "ord_main"."rst_blood_circulate_total" IS E'実績：血液循環積算値';
COMMENT ON COLUMN "ord_main"."rst_running_time" IS E'実績：透析運転時間';
COMMENT ON COLUMN "ord_main"."rst_kt_v" IS E'実績：Kt/V';
COMMENT ON COLUMN "ord_main"."rec_set_date" IS E'実績：透析記録確認日時';
COMMENT ON COLUMN "ord_main"."send_ctl_no" IS E'実績：送信管理番号';
COMMENT ON COLUMN "ord_main"."blood_purifier_name" IS E'実績：血液浄化装置名称';
COMMENT ON COLUMN "ord_main"."pull_leave_amount" IS E'実績：プログラム補液引き残し量';
COMMENT ON COLUMN "ord_main"."rst_cond_info" IS E'実績：治療条件情報';
COMMENT ON COLUMN "ord_main"."rst_medi_info" IS E'実績：投与薬剤情報';
COMMENT ON COLUMN "ord_main"."rst_equip_info" IS E'実績：医療材料情報';
COMMENT ON COLUMN "ord_main"."rst_ind_comment_info" IS E'実績：指示コメント情報';
COMMENT ON COLUMN "ord_main"."rst_tare_info" IS E'実績：風袋補正';
COMMENT ON COLUMN "ord_main"."rst_off_water_info" IS E'実績：除水補正';
COMMENT ON COLUMN "ord_main"."rst_device_set_info" IS E'実績：装置設定情報';
COMMENT ON COLUMN "ord_main"."rst_weight_info" IS E'実績：体重情報';
COMMENT ON COLUMN "ord_main"."rst_vital_info" IS E'実績：バイタル情報';
COMMENT ON COLUMN "ord_main"."rst_complaint_info" IS E'実績：愁訴情報';
COMMENT ON COLUMN "ord_main"."rst_treatment_info" IS E'実績：愁訴処置情報';
COMMENT ON COLUMN "ord_main"."rst_treat_staff_info" IS E'実績：愁訴処置者情報';
COMMENT ON COLUMN "ord_main"."rst_rounds_info" IS E'実績：回診記録情報';
COMMENT ON COLUMN "ord_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_main"."up_date" IS E'更新日時';

--------------------------------------------------
-- 治療スケジュール
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS ord_schedule;
-- テーブル作成
CREATE TABLE ord_schedule
(
facility_cd character varying(6) NOT NULL,  --施設コード
ord_no bigint NOT NULL,  --オーダ番号
treat_date character varying(8) NOT NULL,  --治療日
kur_cd bigint NOT NULL,  --クールコード
bed_cd bigint NOT NULL,  --ベッドコード
pat_id bigint,  --患者ID
is_dummy character varying(1),  --ダミーフラグ
up_date timestamp(3),  --更新日時
treat_week smallint,  --治療曜日
CONSTRAINT unq_ord_schedule_01 PRIMARY KEY (facility_cd,treat_date,kur_cd,bed_cd)
);
-- コメント追加
COMMENT ON TABLE "ord_schedule" IS E'治療スケジュール';
COMMENT ON COLUMN "ord_schedule"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_schedule"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_schedule"."treat_date" IS E'治療日';
COMMENT ON COLUMN "ord_schedule"."kur_cd" IS E'クールコード';
COMMENT ON COLUMN "ord_schedule"."bed_cd" IS E'ベッドコード';
COMMENT ON COLUMN "ord_schedule"."is_dummy" IS E'ダミーフラグ';
COMMENT ON COLUMN "ord_schedule"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "ord_schedule"."up_date" IS E'更新日時';
COMMENT ON COLUMN "ord_schedule"."treat_week" IS E'治療曜日';

--------------------------------------------------
-- 患者基本情報
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS pat_main;
-- テーブル作成
CREATE TABLE pat_main
(
pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
facility_cd character varying(6),  --登録施設コード
is_same character varying(1),  --同姓同名
is_implant character varying(1),  --インプラント有無
is_infect character varying(1),  --感染症有無
is_diabetes character varying(1),  --糖尿病患者扱い
is_blood_suger_exam character varying(1),  --血糖検査有無
in_out_current_state character varying(1),  --確定転入出状態
in_out_plan_state character varying(1),  --予定転入出状態
in_out_plan_date timestamp(3),  --予定転入出日時
pat_memo_info jsonb,  --患者メモ情報
addition_info jsonb,  --加算情報
charge_staff_info jsonb,  --担当スタッフ情報
pat_group_info jsonb,  --患者グループ情報
taboo_allergy_info jsonb,  --禁忌・アレルギー情報
infect_info jsonb,  --感染症情報
implant_info jsonb,  --インプラント情報
tare_info jsonb,  --風袋補正情報
off_water_info jsonb,  --除水補正情報
device_set_info jsonb,  --装置設定情報
acceptance_status_info jsonb,  --治療進捗状態
is_del character varying(1) DEFAULT '0',  --削除フラグ
up_date timestamp(3),  --更新日時
reg_date timestamp(3),  --登録日時
CONSTRAINT unq_pat_main_01 PRIMARY KEY (pat_id)
);
-- コメント追加
COMMENT ON TABLE "pat_main" IS E'患者基本情報';
COMMENT ON COLUMN "pat_main"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_main"."facility_cd" IS E'登録施設コード';
COMMENT ON COLUMN "pat_main"."is_same" IS E'同姓同名';
COMMENT ON COLUMN "pat_main"."is_implant" IS E'インプラント有無';
COMMENT ON COLUMN "pat_main"."is_infect" IS E'感染症有無';
COMMENT ON COLUMN "pat_main"."is_diabetes" IS E'糖尿病患者扱い';
COMMENT ON COLUMN "pat_main"."is_blood_suger_exam" IS E'血糖検査有無';
COMMENT ON COLUMN "pat_main"."in_out_current_state" IS E'確定転入出状態';
COMMENT ON COLUMN "pat_main"."in_out_plan_state" IS E'予定転入出状態';
COMMENT ON COLUMN "pat_main"."in_out_plan_date" IS E'予定転入出日時';
COMMENT ON COLUMN "pat_main"."pat_memo_info" IS E'患者メモ情報';
COMMENT ON COLUMN "pat_main"."addition_info" IS E'加算情報';
COMMENT ON COLUMN "pat_main"."charge_staff_info" IS E'担当スタッフ情報';
COMMENT ON COLUMN "pat_main"."pat_group_info" IS E'患者グループ情報';
COMMENT ON COLUMN "pat_main"."taboo_allergy_info" IS E'禁忌・アレルギー情報';
COMMENT ON COLUMN "pat_main"."infect_info" IS E'感染症情報';
COMMENT ON COLUMN "pat_main"."implant_info" IS E'インプラント情報';
COMMENT ON COLUMN "pat_main"."tare_info" IS E'風袋補正情報';
COMMENT ON COLUMN "pat_main"."off_water_info" IS E'除水補正情報';
COMMENT ON COLUMN "pat_main"."device_set_info" IS E'装置設定情報';
COMMENT ON COLUMN "pat_main"."acceptance_status_info" IS E'治療進捗状態';
COMMENT ON COLUMN "pat_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_main"."reg_date" IS E'登録日時';

--------------------------------------------------
-- 患者基本情報
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS pat_unique;
-- テーブル作成
CREATE TABLE pat_unique
(
pat_id bigint NOT NULL,  --システムで管理する一意な患者ID
medical_care_info jsonb DEFAULT E'{"main_course_cd":null, "dialysis_course_cd":null, "ward_cd":null, "dialysis_count":null, "purification_count":null, "other_dialysis_count":null, "facility_cd":null, "dialysis_start_date":null, "hospital_start_date":null}',  --共通診療情報
medical_hst_info jsonb,  --既往歴情報
in_out_visit_history_info jsonb,  --入外・転入出情報
physical_info jsonb,  --身体情報
is_del character varying(1) DEFAULT '0',  --削除フラグ
up_date timestamp(3),  --更新日時
reg_date timestamp(3),  --登録日時
CONSTRAINT unq_pat_unique_01 PRIMARY KEY (pat_id)
);
-- コメント追加
COMMENT ON TABLE "pat_unique" IS E'患者基本情報';
COMMENT ON COLUMN "pat_unique"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_unique"."medical_care_info" IS E'共通診療情報';
COMMENT ON COLUMN "pat_unique"."medical_hst_info" IS E'既往歴情報';
COMMENT ON COLUMN "pat_unique"."in_out_visit_history_info" IS E'入外・転入出情報';
COMMENT ON COLUMN "pat_unique"."physical_info" IS E'身体情報';
COMMENT ON COLUMN "pat_unique"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_unique"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_unique"."reg_date" IS E'登録日時';

--------------------------------------------------
-- データ項目設定
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS sys_data_item;
-- テーブル作成
CREATE TABLE sys_data_item
(
facility_cd character varying(6),  --施設コード
template_no int NOT NULL,  --テンプレート番号
item_category smallint NOT NULL,  --項目区分
item_sub_category smallint NOT NULL,  --サブ項目区分
item_type smallint NOT NULL,  --項目名タイプ
value_type smallint NOT NULL,  --値タイプ
disp_position smallint,  --表示位置
item_title character varying(40) NOT NULL,  --項目名
item_unit character varying(20),  --項目単位
item_table character varying(40),  --項目テーブル
item_key character varying(100),  --項目キー
disp_order smallint,  --表示順
is_disp character varying(1) NOT NULL DEFAULT '1',  --表示設定
CONSTRAINT unq_sys_data_item_01 PRIMARY KEY (facility_cd,template_no,item_category,item_sub_category)
);
-- コメント追加
COMMENT ON TABLE "sys_data_item" IS E'データ項目設定';
COMMENT ON COLUMN "sys_data_item"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_data_item"."template_no" IS E'テンプレート番号';
COMMENT ON COLUMN "sys_data_item"."item_category" IS E'項目区分';
COMMENT ON COLUMN "sys_data_item"."item_sub_category" IS E'サブ項目区分';
COMMENT ON COLUMN "sys_data_item"."item_type" IS E'項目名タイプ';
COMMENT ON COLUMN "sys_data_item"."value_type" IS E'値タイプ';
COMMENT ON COLUMN "sys_data_item"."disp_position" IS E'表示位置';
COMMENT ON COLUMN "sys_data_item"."item_title" IS E'項目名';
COMMENT ON COLUMN "sys_data_item"."item_unit" IS E'項目単位';
COMMENT ON COLUMN "sys_data_item"."item_table" IS E'項目テーブル';
COMMENT ON COLUMN "sys_data_item"."item_key" IS E'項目キー';
COMMENT ON COLUMN "sys_data_item"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_data_item"."is_disp" IS E'表示設定';

--------------------------------------------------
-- 装置設定
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS sys_facility;
-- テーブル作成
CREATE TABLE sys_facility
(
facility_cd character varying(6) NOT NULL,  --施設コード
device_info jsonb,  --装置設定
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_sys_facility_01 PRIMARY KEY (facility_cd)
);
-- コメント追加
COMMENT ON TABLE "sys_facility" IS E'装置設定';
COMMENT ON COLUMN "sys_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_facility"."device_info" IS E'装置設定';
COMMENT ON COLUMN "sys_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_facility"."up_date" IS E'更新日時';

