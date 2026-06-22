DELETE FROM mst_treatment
WHERE facility_cd = 'F_hA12';

insert into ntss.mst_treatment (
treatment_cd,
facility_cd,
fn_treatment_cd,
treatment_name,
device_mode,
report_id,
report_id_hw,
report_id_bw,
report_id_aw,
report_id_dev,
graph_time_scale,
treatment_condition_setting,
monitor_data_item_print,
monitor_data_item_screen,
is_disp,
is_del,
reg_date,
up_date,
in_hosp_a_startdate,
in_hospital_cd_a1,
in_hospital_cd_a2,
in_hospital_cd_a3,
in_hospital_cd_a4,
in_hosp_b_startdate,
in_hospital_cd_b1,
in_hospital_cd_b2,
in_hospital_cd_b3,
in_hospital_cd_b4
)
values (
4112, -- treatment_cd
'F_hA12', -- facility_cd
NULL, -- fn_treatment_cd,
'血液透析（４ｈ以上） db', -- treatment_name
NULL, -- device_mode,
NULL, -- report_id,
NULL, -- report_id_hw,
NULL, -- report_id_bw,
NULL, -- report_id_aw,
NULL, -- report_id_dev,
'6', -- graph_time_scale,
NULL, -- treatment_condition_setting,
NULL, -- monitor_data_item_print,
NULL, -- monitor_data_item_screen,
'1', -- is_disp
'0', -- is_del
'2020/01/16 9:15:04', -- reg_date
'2020/01/16 9:15:04', -- up_date
NULL, -- in_hosp_a_startdate
'VC1001  ', -- in_hospital_cd_a1
NULL, -- in_hospital_cd_a2
NULL, -- in_hospital_cd_a3
NULL, -- in_hospital_cd_a4
NULL, -- in_hosp_b_startdate
NULL, -- in_hospital_cd_b1
NULL, -- in_hospital_cd_b2
NULL, -- in_hospital_cd_b3
NULL -- in_hospital_cd_b4
);

DELETE FROM mst_dialysis_difficulty
WHERE facility_cd = 'F_hA12';

insert into ntss.mst_dialysis_difficulty (facility_cd, fn_dialysis_difficulty_cd, dialysis_difficulty_name, in_hospital_cd_1, in_hospital_cd_2, is_disp, is_del, reg_date, up_date)
values ('F_hA12',NULL,'おかむらいいん','VAB004',NULL,'1','0','2020/01/16 9:06:09','2020/01/16 9:06:09');

DELETE FROM mst_disease
WHERE facility_cd = 'F_hA12';

insert into ntss.mst_disease (
facility_cd,
fn_disease_cd,
disease_name,
disease_short_name,
standard_disease_cd,
p_disease_biopsy_none_cd,
p_disease_biopsy_exist_cd,
die_confirmed_diagnosis_none_cd,
die_confirmed_diagnosis_exist_cd,
in_hospital_cd_1,
is_disp,
is_del,
reg_date,
up_date) values ('F_hA12',NULL,'モヤモヤ','モヤ',NULL,NULL,NULL,NULL,NULL,'0009770089','1','0','2020/01/16 8:53:33','2020/01/16 8:53:33');
insert into ntss.mst_disease (
facility_cd,
fn_disease_cd,
disease_name,
disease_short_name,
standard_disease_cd,
p_disease_biopsy_none_cd,
p_disease_biopsy_exist_cd,
die_confirmed_diagnosis_none_cd,
die_confirmed_diagnosis_exist_cd,
in_hospital_cd_1,
is_disp,
is_del,
reg_date,
up_date) values ('F_hA12',NULL,'モヤモヤ','モヤ',NULL,NULL,NULL,NULL,NULL,'0001100011','1','0','2020/01/16 8:53:33','2020/01/16 8:53:33');
insert into ntss.mst_disease (
facility_cd,
fn_disease_cd,
disease_name,
disease_short_name,
standard_disease_cd,
p_disease_biopsy_none_cd,
p_disease_biopsy_exist_cd,
die_confirmed_diagnosis_none_cd,
die_confirmed_diagnosis_exist_cd,
in_hospital_cd_1,
is_disp,
is_del,
reg_date,
up_date) values ('F_hA12',NULL,'モユモユ','モユ',NULL,NULL,NULL,NULL,NULL,'VB199999','1','0','2020/01/16 8:53:33','2020/01/16 8:53:33');

DELETE FROM mst_device_set_info_default
WHERE facility_cd = 'F_hA12';

DELETE FROM mst_facility
WHERE facility_cd = 'F_hA12';

INSERT INTO mst_facility VALUES ('F_hA12','ジャーナル-テーブル登録テストデータ',NULL,'01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO mst_device_set_info_default VALUES ('F_hA12',
'{"device": "setting"}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 500, "weight_2": 400, "weight_3": 300, "weight_4": 200, "weight_5": 100}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 90000, "weight_2": 80000, "weight_3": 70000, "weight_4": 60000, "weight_5": 50000}',
NULL,NULL);
