-- 愁訴マスタ
INSERT INTO mst_complaint
  (complaint_cd, facility_cd, complaint_name, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', '腹痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (2, '009999', '胸痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (3, '009999', '頭痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (4, '009999', '筋肉のつれ', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (5, '009999', '発汗', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (6, '009999', '血圧低下予防', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (7, '009999', '気分不快', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (8, '009999', '生欠伸', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (9, '009999', 'TMP上昇', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (10, '009999', '下肢牽引痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (11, '009999', '右肩痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (12, '009999', '左肩痛', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (13, '009999', '脱血不良', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (14, '009999', '脱血やや不良', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (15, '009999', '意識消失', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (16, '009999', '吐気', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (17, '009999', '嘔吐', '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (18, '009999', '尿意', '1', '1', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (19, '009999', '気分やや不快', '0', '1', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (20, '009999', '腰痛', '0', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
;
SELECT setval('mst_complaint_complaint_cd_seq', 20);

-- 処置マスタ
INSERT INTO mst_comp_treatment
(comp_treatment_cd, facility_cd, treatment, treat_class, treat_medicine_cd, amount, procedure_cd, take_medicine_cd, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', '除水速度低下', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (2, '009999', '生食補益', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (3, '009999', '血流量低下', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (4, '009999', 'アメジニン服用', '1', 113, 2, 1, NULL, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (5, '009999', '10%NaCl iv', '1', 114, 3, 3, NULL, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (6, '009999', '返血（透析中止）', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (7, '009999', '除水停止', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (8, '009999', 'Qf低下', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (9, '009999', 'メイロン7%20ml iv', '1', 115, 1, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (11, '009999', 'ﾏｯｻｰｼﾞ', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (10, '009999', '温罨法', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (12, '009999', 'ﾌﾟﾘﾝﾍﾟﾗﾝ注iv', '1', 116, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (13, '009999', '8.5%ｶﾙﾁｺｰﾙ iv', '1', 117, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (14, '009999', 'トイレ離脱', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (15, '009999', '尿意あり', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (16, '009999', '下肢掌上', '2', null, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (17, '009999', 'セット薬剤', '0', 1, null, null, null, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (18, '009999', '血流量低下', '2', null, null, null, null, '0', '1', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (19, '009999', '頭部掌上', '2', null, null, null, null, '1', '1', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
, (20, '009999', '様子観察', '2', null, null, null, null, '0', '1', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
;
SELECT setval('mst_comp_treatment_comp_treatment_cd_seq', 20);

-- mst_medicine に必要なデータを追加
INSERT INTO mst_medicine
(medicine_cd, facility_cd, fn_medicine_cd, standard_medicine_cd, is_trial, medicine_name, medicine_short_name, unit, unit_second, class_cd, is_shot, use_start_date, use_end_date, is_medicated, unit_converted_amount, unit_converted_amount_second, anticoagulant_original_quantity, after_anticoagulant_quantity, in_hospital_cd_1, in_hospital_cd_2, in_hospital_cd_3, is_disp, is_del, reg_date, up_date)
VALUES
  (113, '009999', NULL, NULL, NULL, 'アメジニン錠10mg', NULL, '錠', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '0', '2019-02-20 21:39:57.385', '2019-02-20 21:39:57.385')
, (114, '009999', NULL, NULL, NULL, '10%塩化ナトリウム注射液20ml', NULL, 'A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '0', '2019-02-20 21:39:57.385', '2019-02-20 21:39:57.385')
, (115, '009999', NULL, NULL, NULL, 'メイロン7%20ml', NULL, 'A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '0', '2019-02-20 21:39:57.385', '2019-02-20 21:39:57.385')
, (116, '009999', NULL, NULL, NULL, 'プリメラン10mg2ml', NULL, 'A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '0', '2019-02-20 21:39:57.385', '2019-02-20 21:39:57.385')
, (117, '009999', NULL, NULL, NULL, 'カンチコール8.5%5ml', NULL, 'A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '0', '2019-02-20 21:39:57.385', '2019-02-20 21:39:57.385')
;

--- mst_medicine_set
INSERT INTO mst_medicine_set
(medicine_set_cd, facility_cd, medicine_set_name, medicine_set_short_name, set_info, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', 'セット薬剤名１', NULL, NULL, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
;

-- sys_master_defineに定義を追加
INSERT INTO sys_master_define
  (master_physical_name, master_name, disp_class, "mode", allow_sort, allow_add_record, disp_order, column_info, combo_data, reg_date, up_date, reference_combo_def, edit_level)
VALUES
  ('mst_complaint', '愁訴処置マスタ', '2', '2', '1', '1', 110, null, null, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000', null, '1')
;

-- mst_selectorに追加
INSERT INTO mst_selector
  (facility_cd, master_physical_name, order_settings, reg_date, up_date)
VALUES
  ('009999', 'mst_complaint', '{"items": [{"code": 1, "name": "name1"}, {"code": 3, "name": "name3"}, {"code": 2, "name": "name2"}, {"code": 5, "name": "name5"}, {"code": 6, "name": "name6"}, {"code": 4, "name": "name4"}, {"code": 7, "name": "name7"}, {"code": 8, "name": "name8"}, {"code": 9, "name": "name9"}, {"code": 10, "name": "name10"}, {"code": 11, "name": "name11"}, {"code": 12, "name": "name12"}, {"code": 13, "name": "name13"}, {"code": 14, "name": "name14"}, {"code": 15, "name": "name15"}, {"code": 16, "name": "name16"}, {"code": 17, "name": "name17"}]}', null, null)
, ('009999', 'mst_comp_treatment', '{"items": [{"code": 1, "name": "name1"}, {"code": 3, "name": "name3"}, {"code": 2, "name": "name2"}, {"code": 5, "name": "name5"}, {"code": 6, "name": "name6"}, {"code": 4, "name": "name4"}, {"code": 7, "name": "name7"}, {"code": 8, "name": "name8"}, {"code": 9, "name": "name9"}, {"code": 10, "name": "name10"}, {"code": 11, "name": "name11"}, {"code": 12, "name": "name12"}, {"code": 13, "name": "name13"}, {"code": 14, "name": "name14"}, {"code": 15, "name": "name15"}, {"code": 16, "name": "name16"}, {"code": 17, "name": "name17"}]}', null, null)
;
