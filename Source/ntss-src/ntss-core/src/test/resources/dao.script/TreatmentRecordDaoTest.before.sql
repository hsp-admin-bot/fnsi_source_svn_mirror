INSERT INTO ord_main
(
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  rst_dialysis_state,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_start_date,
  rst_end_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  is_del,
  up_date,
  reg_date,
  rst_treatment_cd,
  rst_treatment_name
) VALUES (
  1,
  2,
  '00003',
  '20190213',
  1,
  '009999',
  'テスト施設名',
  '3',
  11,
  'クール1',
  12,
  'ベッド1',
  '2019/02/13 12:00:00.000',
  '2019/02/13 18:00:00.000',
  1,
  2,
  13,
  '病棟名1',
  14,
  '診療科名1',
  '{
    "user_id_1": 101,
    "user_last_name_1": "穿刺1",
    "user_first_name_1": "太郎",
    "user_id_2": 102,
    "user_last_name_2": "穿刺2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:00:00.000+09:00",
    "date_1": "2019-02-13T13:01:00.000+09:00",
    "date_2": "2019-02-13T13:02:00.000+09:00"
  }',
  '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:30:00.000+09:00",
    "date_1": "2019-02-13T13:31:00.000+09:00",
    "date_2": "2019-02-13T13:32:00.000+09:00"
  }',
  '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎",
    "date_1": "2019-02-13T14:01:00.000+09:00",
    "date_2": "2019-02-13T14:02:00.000+09:00"
  }',
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000',
  100,
  'テスト治療方法１'
),(
  12,
  2,
  '00003',
  '20190214',
  2,
  '009999',
  'テスト施設名',
  '4',
  12,
  'クール2',
  14,
  'ベッド2',
  '2019/02/14 17:03:12.000',
  '2019/02/14 20:11:04.000',
  1,
  3,
  14,
  '病棟名2',
  15,
  '診療科名3',
  '{
    "user_id_1": 101,
    "user_last_name_1": "穿刺1",
    "user_first_name_1": "太郎",
    "user_id_2": 102,
    "user_last_name_2": "穿刺2",
    "user_first_name_2": "次郎",
    "date": "2019-02-14T18:00:00.000+09:00"
  }',
  '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-14T19:30:00.000+09:00"
  }',
  '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎"
  }',
  '1',
  '2019/02/14 20:30:00.000',
  '2019/02/14 20:00:00.000',
  101,
  'テスト治療方法２'
),
(
  9001,
  3,
  '90003',
  '20190201',
  1,
  '009990',
  'テスト施設名９９９０',
  '5',
  9001,
  'クール９００１',
  9002,
  'ベッド９００２',
  '2019/02/01 12:00:00.000',
  '2019/02/01 18:00:00.000',
  9004,
  9005,
  9006,
  '病棟名９００６',
  9007,
  '診療科名９００７',
  '{
    "user_id_1": 9008,
    "user_last_name_1": "穿刺9008",
    "user_first_name_1": "太郎9008",
    "user_id_2": 9009,
    "user_last_name_2": "穿刺9009",
    "user_first_name_2": "次郎9009",
    "date": "2019-02-02T13:00:00.000+09:00"
  }',
  '{
    "user_id_1": 9010,
    "user_last_name_1": "返血9010",
    "user_first_name_1": "太郎9010",
    "user_id_2": 9011,
    "user_last_name_2": "返血9011",
    "user_first_name_2": "次郎9011",
    "date": "2019-02-03T13:30:00.000+09:00"
  }',
  '{
    "user_id_1": 9012,
    "user_last_name_1": "担当9012",
    "user_first_name_1": "太郎9012",
    "user_id_2": 9013,
    "user_last_name_2": "担当9013",
    "user_first_name_2": "次郎9013"
  }',
  '0',
  '2019/02/04 14:30:00.000',
  '2019/02/04 14:00:00.000',
  102,
  'テスト治療方法３'
), (
  9002,
  4,
  '90002',
  '20190204',
  1,
  '009991',
  'テスト施設名９９９１',
  '6',
  9101,
  'クール９１０１',
  9102,
  'ベッド９１０２',
  '2019/03/01 12:00:00.000',
  '2019/03/01 18:00:00.000',
  9104,
  9105,
  9106,
  '病棟名９１０６',
  9107,
  '診療科名９１０７',
  '{
    "user_id_1": 9108,
    "user_last_name_1": "穿刺9108",
    "user_first_name_1": "太郎9108",
    "user_id_2": 9109,
    "user_last_name_2": "穿刺9109",
    "user_first_name_2": "次郎9109",
    "date": "2019-03-02T13:00:00.000+09:00"
  }',
  '{
    "user_id_1": 9110,
    "user_last_name_1": "返血9110",
    "user_first_name_1": "太郎9110",
    "user_id_2": 9111,
    "user_last_name_2": "返血9111",
    "user_first_name_2": "次郎9111",
    "date": "2019-03-03T13:30:00.000+09:00"
  }',
  '{
    "user_id_1": 9112,
    "user_last_name_1": "担当9112",
    "user_first_name_1": "太郎9112",
    "user_id_2": 9113,
    "user_last_name_2": "担当9113",
    "user_first_name_2": "次郎9113"
  }',
  '1',
  '2019/03/04 14:30:00.000',
  '2019/03/04 14:00:00.000',
  103,
  'テスト治療方法４'
);

INSERT INTO ord_main
(
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  facility_cd,
  facility_name,
  ind_treat_start_time,
  rst_cond_info,
  rst_treatment_cd,
  rst_treatment_name,
  rst_dw,
  is_del,
  up_date,
  reg_date
) VALUES (
  21,
  3,
  '00004',
  '20190307',
  '009999',
  'テスト施設名',
  '1423',
  '{
    "1":
    {
      "value": "0400",
      "value_name_1": null
    }
  }',
  999,
  '治療方法１',
  66.3,
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
),(
  9011,
  4,
  '00005',
  '20190308',
  '010000',
  'テスト施設名１００００',
  '1512',
  '{
    "2":
    {
      "value": "0500",
      "value_name_1": null
    }
  }',
  888,
  '治療方法８８８',
  99.9,
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
),(
  9012,
  5,
  '00006',
  '20190309',
  '010001',
  'テスト施設名１０００１',
  '1621',
  '{
    "3":
    {
      "value": "0600",
      "value_name_1": null
    }
  }',
  555,
  '治療方法５５５',
  98.7,
  '1',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
);

insert into ord_main
(
  ord_no,
  pat_id,
  facility_cd,
  rst_start_date,
  rst_dw,
  rst_cond_info,
  rst_weight_info,
  rst_tare_info,
  rst_off_water_info,
  is_del,
  up_date,
  reg_date
)
values
(
  90001,
  1,
  'zzz999',
  '2019/03/01 12:00:00.000',
  59.1,
  '{ "3": { "value": 21.1 }, "4": { "value": 5.1 } }',
  '{ "weight_after": 58.1 }',
  '{ "before": { "name_1": "項目11名称" }, "after": { "name_1": "項目21名称" } }',
  '{ "name_1": "項目1名称", "weight_1": 1 }',
  '0',
  '2019/04/01 12:00:00.000',
  '2019/04/01 13:00:00.000'
),
(
  90002,
  1,
  'zzz999',
  '2019/03/02 12:00:00.000',
  59.2,
  '{ "3": { "value": 21.2 }, "4": { "value": 5.2 } }',
  '{ "weight_after": 58.2 }',
  '{ "before": { "name_1": "項目12名称" }, "after": { "name_1": "項目22名称" } }',
  '{ "name_1": "項目2名称", "weight_1": 2 }',
  '0',
  '2019/04/01 12:00:00.000',
  '2019/04/01 13:00:00.000'
),
(
  90003,
  2,
  'zzz999',
  '2019/03/03 12:00:00.000',
  59.3,
  '{ "3": { "value": 21.3 }, "4": { "value": 5.3 } }',
  '{ "weight_after": 58.3 }',
  '{ "before": { "name_1": "項目13名称" }, "after": { "name_1": "項目23名称" } }',
  '{ "name_1": "項目3名称", "weight_1": 3 }',
  '1',
  '2019/04/01 12:00:00.000',
  '2019/04/01 13:00:00.000'
),
(
  90004,
  1,
  'xxx999',
  '2019/03/04 12:00:00.000',
  59.4,
  '{ "3": { "value": 21.4 }, "4": { "value": 5.4 } }',
  '{ "weight_after": 58.4 }',
  '{ "before": { "name_1": "項目14名称" }, "after": { "name_1": "項目24名称" } }',
  '{ "name_1": "項目4名称", "weight_1": 4 }',
  '0',
  '2019/04/01 12:00:00.000',
  '2019/04/01 13:00:00.000'
),
(
  90005,
  1,
  'zzz999',
  '2019/03/05 12:00:00.000',
  59.5,
  '{ "3": { "value": 21.5 }, "4": { "value": 5.5 } }',
  '{ "weight_after": 58.5 }',
  '{ "before": { "name_1": "項目15名称" }, "after": { "name_1": "項目25名称" } }',
  '{ "name_1": "項目5名称", "weight_1": 5 }',
  '0',
  '2019/04/01 12:00:00.000',
  '2019/04/01 13:00:00.000'
);

INSERT INTO mni_monitor
(bio_moni_ctl_no, facility_cd, machine_type_cd, machine_serial, ord_no, pat_id, data_type, monitor_data, is_del, occur_date, reg_date, up_date)
VALUES
(1, '009999', '321', '987', 13, 4, 3, '{"0": "test1", "1": "data1"}', '0', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000'),
(2, '009999', '321', '987', 13, 4, 3, '{"0": "test2", "1": "data2"}', '0', '2019/03/22 14:34:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:34:00.000'),
(3, '009999', '321', '987', 13, 4, 3, '{"0": "test3", "1": "data3"}', '0', '2019/03/22 14:35:20.000', '2019/03/22 14:30:00.000', '2019/03/22 14:35:20.000'),
(4, '009999', '321', '987', 13, 4, 4, '{"0": "test4", "1": "data4"}', '0', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000')
;

INSERT INTO mni_monitor
(bio_moni_ctl_no, facility_cd, machine_type_cd, machine_serial, ord_no, pat_id, data_type, monitor_data, is_del, occur_date, reg_date, up_date)
VALUES
(5, '009999', '321', '987', 14, 4, 2, '{"0": "test1", "1": "data1"}', '0', '2019/03/22 14:10:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000'),
(6, '009999', '321', '987', 14, 4, 3, '{"0": "test2", "1": "data2"}', '0', '2019/03/22 14:12:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:34:00.000'),
(7, '009999', '321', '987', 14, 4, 4, '{"0": "test3", "1": "data3"}', '0', '2019/03/22 14:13:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:35:20.000'),
(8, '009999', '321', '987', 14, 4, 5, '{"0": "test4", "1": "data4"}', '0', '2019/03/22 14:00:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000'),
(9, '009999', '321', '987', 14, 4, 6, '{"0": "test5", "1": "data5"}', '0', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000'),
(10, '009999', '321', '987', 14, 4, 2, '{"0": "test6", "1": "data6"}', '1', '2019/03/22 14:11:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:34:00.000')
;

INSERT INTO mni_monitor
(bio_moni_ctl_no, facility_cd, machine_type_cd, machine_serial, ord_no, pat_id, data_type, monitor_data, is_del, occur_date, reg_date, up_date)
VALUES
(11, '009999', '321', '987', 14, 4, 1, '{"0": "test1", "1": "data1"}', '0', '2019/03/22 14:33:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000'),
(12, '009999', '321', '987', 14, 4, 1, '{"0": "test2", "1": "data2"}', '0', '2019/03/22 14:35:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:34:00.000'),
(13, '009999', '321', '987', 14, 4, 1, '{"0": "test3", "1": "data3"}', '0', '2019/03/22 14:32:20.000', '2019/03/22 14:30:00.000', '2019/03/22 14:35:20.000'),
(14, '009999', '321', '987', 14, 4, 1, '{"0": "test4", "1": "data4"}', '1', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000', '2019/03/22 14:30:00.000')
;

insert into ord_main
(
  ord_no,
  pat_id,
  facility_cd,
  rst_start_date,
  rst_edition,
  rst_is_update_edition,
  rst_dialysis_state,
  is_del,
  up_date,
  reg_date
)
values
(
  100001,
  1,
  '009999',
  '2019/08/27 12:00:00.000',
  0,
  '0',
  '6',
  '0',
  '2019/08/27 12:00:00.000',
  '2019/08/27 13:00:00.000'
),
(
  100002,
  1,
  '009999',
  '2019/08/27 12:00:00.000',
  0,
  '0',
  '1',
  '0',
  '2019/08/27 12:00:00.000',
  '2019/08/27 13:00:00.000'
);

INSERT INTO ord_main
(
  ord_no,
  pat_id,
  facility_cd,
  rst_treatment_cd,
  is_del
)
VALUES
(
  200001,
  1,
  '009999',
  1,
  '0'
),
(
  200002,
  1,
  '009999',
  2,
  '1'
);

insert into mst_treatment(treatment_cd,facility_cd,fn_treatment_cd,treatment_name,device_mode,report_id,report_id_hw,report_id_bw,report_id_aw,report_id_dev,graph_time_scale,treatment_condition_setting,monitor_data_item_print,monitor_data_item_screen,is_disp,is_del,reg_date,up_date,in_hosp_a_startdate,in_hospital_cd_a1,in_hospital_cd_a2,in_hospital_cd_a3,in_hospital_cd_a4,in_hosp_b_startdate,in_hospital_cd_b1,in_hospital_cd_b2,in_hospital_cd_b3,in_hospital_cd_b4) values (1,'009999',null,'治療方法１',0,1,null,null,null,null,6,'[{"items": [{"ctl_no": "2", "is_use": "1"}, {"ctl_no": "5", "is_use": "1"}, {"ctl_no": "6", "is_use": "1"}, {"ctl_no": "7", "is_use": "1"}, {"ctl_no": "8", "is_use": "1"}, {"ctl_no": "13", "is_use": "1"}, {"ctl_no": "14", "is_use": "1"}], "category_no": 1}, {"items": [{"ctl_no": "4", "is_use": "1"}, {"ctl_no": "3", "is_use": "1"}], "category_no": 2}, {"items": [{"ctl_no": "15", "is_use": "1"}, {"ctl_no": "16", "is_use": "1"}, {"ctl_no": "17", "is_use": "1"}, {"ctl_no": "18", "is_use": "1"}], "category_no": 3}, {"items": [{"ctl_no": "19", "is_use": "0"}, {"ctl_no": "20", "is_use": "0"}, {"ctl_no": "21", "is_use": "0"}, {"ctl_no": "22", "is_use": "0"}, {"ctl_no": "23", "is_use": "0"}, {"ctl_no": "24", "is_use": "0"}], "category_no": 4}, {"items": [{"ctl_no": "25", "is_use": "1"}, {"ctl_no": "26", "is_use": "1"}, {"ctl_no": "27", "is_use": "1"}, {"ctl_no": "28", "is_use": "1"}], "category_no": 5}, {"items": [{"ctl_no": "29", "is_use": "1"}, {"ctl_no": "30", "is_use": "1"}, {"ctl_no": "32", "is_use": "1"}, {"ctl_no": "33", "is_use": "1"}, {"ctl_no": "34", "is_use": "1"}, {"ctl_no": "31", "is_use": "1"}, {"ctl_no": "35", "is_use": "1"}, {"ctl_no": "36", "is_use": "1"}, {"ctl_no": "37", "is_use": "1"}, {"ctl_no": "38", "is_use": "1"}], "category_no": 6}, {"items": [{"ctl_no": "12", "is_use": "1"}, {"ctl_no": "9", "is_use": "1"}, {"ctl_no": "10", "is_use": "1"}, {"ctl_no": "11", "is_use": "1"}], "category_no": 7}]','[{"moni_data_no": "1"}, {"moni_data_no": "2"}, {"moni_data_no": "3"}]','[{"moni_data_no": "2"}, {"moni_data_no": "3"}, {"moni_data_no": "4"}, {"moni_data_no": "5"}, {"moni_data_no": "10"}, {"moni_data_no": "緊急補液[L]"}, {"moni_data_no": "実血流量HD03[mL/min]"}]','1','0',null,'2020/03/09 19:52:51.819',null,null,null,null,null,null,null,null,null,null);
insert into mst_treatment(treatment_cd,facility_cd,fn_treatment_cd,treatment_name,device_mode,report_id,report_id_hw,report_id_bw,report_id_aw,report_id_dev,graph_time_scale,treatment_condition_setting,monitor_data_item_print,monitor_data_item_screen,is_disp,is_del,reg_date,up_date,in_hosp_a_startdate,in_hospital_cd_a1,in_hospital_cd_a2,in_hospital_cd_a3,in_hospital_cd_a4,in_hosp_b_startdate,in_hospital_cd_b1,in_hospital_cd_b2,in_hospital_cd_b3,in_hospital_cd_b4) values (2,'009999',null,'治療方法２',1,null,null,null,null,null,8,'[{"items": [{"ctl_no": "2", "is_use": "1"}, {"ctl_no": "5", "is_use": "1"}, {"ctl_no": "6", "is_use": "1"}, {"ctl_no": "7", "is_use": "1"}, {"ctl_no": "8", "is_use": "1"}, {"ctl_no": "13", "is_use": "1"}, {"ctl_no": "14", "is_use": "1"}], "category_no": 1}, {"items": [{"ctl_no": "4", "is_use": "1"}, {"ctl_no": "3", "is_use": "1"}], "category_no": 2}, {"items": [{"ctl_no": "15", "is_use": "1"}, {"ctl_no": "16", "is_use": "1"}, {"ctl_no": "17", "is_use": "1"}, {"ctl_no": "18", "is_use": "1"}], "category_no": 3}, {"items": [{"ctl_no": "19", "is_use": "0"}, {"ctl_no": "20", "is_use": "0"}, {"ctl_no": "21", "is_use": "0"}, {"ctl_no": "22", "is_use": "0"}, {"ctl_no": "23", "is_use": "0"}, {"ctl_no": "24", "is_use": "0"}], "category_no": 4}, {"items": [{"ctl_no": "25", "is_use": "1"}, {"ctl_no": "26", "is_use": "1"}, {"ctl_no": "27", "is_use": "1"}, {"ctl_no": "28", "is_use": "1"}], "category_no": 5}, {"items": [{"ctl_no": "29", "is_use": "1"}, {"ctl_no": "30", "is_use": "1"}, {"ctl_no": "32", "is_use": "1"}, {"ctl_no": "33", "is_use": "1"}, {"ctl_no": "34", "is_use": "1"}, {"ctl_no": "31", "is_use": "1"}, {"ctl_no": "35", "is_use": "1"}, {"ctl_no": "36", "is_use": "1"}, {"ctl_no": "37", "is_use": "1"}, {"ctl_no": "38", "is_use": "1"}], "category_no": 6}, {"items": [{"ctl_no": "12", "is_use": "1"}, {"ctl_no": "9", "is_use": "1"}, {"ctl_no": "10", "is_use": "1"}, {"ctl_no": "11", "is_use": "1"}], "category_no": 7}]',null,null,'0','0',null,'2020/02/27 14:11:40.659',null,null,null,null,null,null,null,null,null,null);
insert into mst_treatment(treatment_cd,facility_cd,fn_treatment_cd,treatment_name,device_mode,report_id,report_id_hw,report_id_bw,report_id_aw,report_id_dev,graph_time_scale,treatment_condition_setting,monitor_data_item_print,monitor_data_item_screen,is_disp,is_del,reg_date,up_date,in_hosp_a_startdate,in_hospital_cd_a1,in_hospital_cd_a2,in_hospital_cd_a3,in_hospital_cd_a4,in_hosp_b_startdate,in_hospital_cd_b1,in_hospital_cd_b2,in_hospital_cd_b3,in_hospital_cd_b4) values (3,'009999',null,'治療方法３',2,null,null,null,null,null,10,'[{"items": [{"ctl_no": "2", "is_use": "1"}, {"ctl_no": "5", "is_use": "1"}, {"ctl_no": "6", "is_use": "1"}, {"ctl_no": "7", "is_use": "1"}, {"ctl_no": "8", "is_use": "1"}, {"ctl_no": "13", "is_use": "1"}, {"ctl_no": "14", "is_use": "1"}], "category_no": 1}, {"items": [{"ctl_no": "4", "is_use": "1"}, {"ctl_no": "3", "is_use": "1"}], "category_no": 2}, {"items": [{"ctl_no": "15", "is_use": "1"}, {"ctl_no": "16", "is_use": "1"}, {"ctl_no": "17", "is_use": "1"}, {"ctl_no": "18", "is_use": "1"}], "category_no": 3}, {"items": [{"ctl_no": "19", "is_use": "1"}, {"ctl_no": "20", "is_use": "1"}, {"ctl_no": "21", "is_use": "1"}, {"ctl_no": "22", "is_use": "1"}, {"ctl_no": "23", "is_use": "1"}, {"ctl_no": "24", "is_use": "1"}], "category_no": 4}, {"items": [{"ctl_no": "25", "is_use": "1"}, {"ctl_no": "26", "is_use": "1"}, {"ctl_no": "27", "is_use": "1"}, {"ctl_no": "28", "is_use": "1"}], "category_no": 5}, {"items": [{"ctl_no": "29", "is_use": "1"}, {"ctl_no": "30", "is_use": "1"}, {"ctl_no": "32", "is_use": "1"}, {"ctl_no": "33", "is_use": "1"}, {"ctl_no": "34", "is_use": "1"}, {"ctl_no": "31", "is_use": "1"}, {"ctl_no": "35", "is_use": "1"}, {"ctl_no": "36", "is_use": "1"}, {"ctl_no": "37", "is_use": "1"}, {"ctl_no": "38", "is_use": "1"}], "category_no": 6}, {"items": [{"ctl_no": "12", "is_use": "1"}, {"ctl_no": "9", "is_use": "1"}, {"ctl_no": "10", "is_use": "1"}, {"ctl_no": "11", "is_use": "1"}], "category_no": 7}]',null,null,'1','0',null,'2020/02/18 12:27:38.282',null,null,null,null,null,null,null,null,null,null);

