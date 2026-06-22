DELETE FROM mst_treatment
WHERE facility_cd = 'F_hN10';

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
71011, -- treatment_cd
'F_hN10', -- facility_cd
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

DELETE FROM mst_device_set_info_default
WHERE facility_cd = 'F_hN10';

DELETE FROM mst_facility
WHERE facility_cd = 'F_hN10';

INSERT INTO mst_facility VALUES ('F_hN10','ジャーナル-テーブル登録テストデータ',NULL,'01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO mst_device_set_info_default VALUES ('F_hN10',
'{"device": "setting"}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 500, "weight_2": 400, "weight_3": 300, "weight_4": 200, "weight_5": 100}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 90000, "weight_2": 80000, "weight_3": 70000, "weight_4": 60000, "weight_5": 50000}',
NULL,NULL);

DELETE FROM mst_coop_facility
WHERE facility_cd = 'F_hN10';

INSERT INTO mst_coop_facility(facility_cd, is_disp, is_del, common_setting)
VALUES('F_hN10', '1', '0', '{"ins_mode":"FUJITSU_PROFILE"}');

DELETE FROM mst_taboo_allergy
WHERE facility_cd = 'F_hN10';

INSERT INTO mst_taboo_allergy(taboo_allergy_cd, facility_cd, fn_taboo_allergy_cd, content, detail_info,
in_hospital_cd_1, in_hospital_cd_2, is_disp, is_del, reg_date, up_date)
VALUES(
20001, 'F_hN10', 1180, '桃', NULL, '11111111', NULL, 1, 0, '2020-05-25', '2020-05-25'
);

INSERT INTO mst_taboo_allergy(taboo_allergy_cd, facility_cd, fn_taboo_allergy_cd, content, detail_info,
in_hospital_cd_1, in_hospital_cd_2, is_disp, is_del, reg_date, up_date)
VALUES(
20002, 'F_hN10', 1181, 'ピーナッツ', NULL, '66666666', NULL, 1, 0, '2020-05-25', '2020-05-25'
);

INSERT INTO mst_taboo_allergy(taboo_allergy_cd, facility_cd, fn_taboo_allergy_cd, content, detail_info,
in_hospital_cd_1, in_hospital_cd_2, is_disp, is_del, reg_date, up_date)
VALUES(
20003, 'F_hN10', 1182, 'そば', NULL, '55555555', NULL, 1, 0, '2020-05-25', '2020-05-25'
);


