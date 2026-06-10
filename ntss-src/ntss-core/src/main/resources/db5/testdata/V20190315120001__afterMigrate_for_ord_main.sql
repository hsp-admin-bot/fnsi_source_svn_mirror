-- ord_main(治療情報)　のデータ追加
INSERT INTO ord_main
(
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  rst_medi_info,
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
  up_date,
  reg_date
) VALUES (
  3,
  4,
  '00004',
  '20190213',
  1,
  '009999',
  'テスト施設名',
  '[
    {
      "no": 1,
      "class_cd": 1,
      "class_name": "抗凝固剤",
      "class_type": 1,
      "medicine_type": 1,
      "cd": 1,
      "name": "テスト抗凝固剤１",
      "short_name": "",
      "unit": "抗",
      "amount": 2,
      "timing_cd": 2,
      "timing_name": "透析中",
      "procedure_cd": 3,
      "procedure_name": "静脈側回路内注射",
      "comment": "コメント",
      "ind_user_id": 101,
      "ind_user_last_name": "指示者1",
      "ind_user_first_name": "太郎",
      "upd_user_id": 102,
      "upd_user_last_name": "更新者1",
      "upd_user_first_name": "次郎",
      "input_class": 1,
      "is_editable": 1,
      "cop_order_no": 1,
      "effect_flg": 0,
      "effect_date": "",
      "effect_user_id": 103,
      "effect_user_last_name": "実施者1",
      "effect_user_first_name": "三郎"
    },
    {
      "no": 2,
      "class_cd": 2,
      "class_name": "透析液",
      "class_type": 2,
      "medicine_type": 1,
      "cd": 6,
      "name": "Ｄドライ透析剤２．５Ｓ",
      "short_name": "",
      "unit": "組",
      "amount": 3,
      "timing_cd": 2,
      "timing_name": "透析中",
      "procedure_cd": 1,
      "procedure_name": "静脈注射",
      "comment": "コメント",
      "ind_user_id": 101,
      "ind_user_last_name": "指示者1",
      "ind_user_first_name": "太郎",
      "upd_user_id": 102,
      "upd_user_last_name": "更新者1",
      "upd_user_first_name": "次郎",
      "input_class": 1,
      "is_editable": 1,
      "cop_order_no": 1,
      "effect_flg": 1,
      "effect_date": "2019-03-01T12:00:00+09:00",
      "effect_user_id": 103,
      "effect_user_last_name": "実施者1",
      "effect_user_first_name": "三郎"
    },
    {
      "no": 3,
      "class_cd": 3,
      "class_name": "補液",
      "class_type": 3,
      "medicine_type": 1,
      "cd": 3,
      "name": "テスト補液１",
      "short_name": "",
      "unit": "袋",
      "amount": 1,
      "timing_cd": 1,
      "timing_name": "透析後",
      "procedure_cd": 1,
      "procedure_name": "静脈注射",
      "comment": "コメント",
      "ind_user_id": 101,
      "ind_user_last_name": "指示者1",
      "ind_user_first_name": "太郎",
      "upd_user_id": 102,
      "upd_user_last_name": "更新者1",
      "upd_user_first_name": "次郎",
      "input_class": 1,
      "is_editable": 1,
      "cop_order_no": 1,
      "effect_flg": 0,
      "effect_date": "",
      "effect_user_id": 103,
      "effect_user_last_name": "実施者1",
      "effect_user_first_name": "三郎"
    },
    {
      "no": 4,
      "class_cd": 2,
      "class_name": "透析液",
      "class_type": 2,
      "medicine_type": 1,
      "cd": 2,
      "name": "テスト透析液１",
      "short_name": "",
      "unit": "L",
      "amount": 3,
      "timing_cd": 1,
      "timing_name": "透析後",
      "procedure_cd": 3,
      "procedure_name": "静脈側回路内注射",
      "comment": "コメント",
      "ind_user_id": 101,
      "ind_user_last_name": "指示者1",
      "ind_user_first_name": "太郎",
      "upd_user_id": 102,
      "upd_user_last_name": "更新者1",
      "upd_user_first_name": "次郎",
      "input_class": 1,
      "is_editable": 1,
      "cop_order_no": 1,
      "effect_flg": 1,
      "effect_date": "2019-03-02T08:00:00+09:00",
      "effect_user_id": 103,
      "effect_user_last_name": "実施者1",
      "effect_user_first_name": "三郎"
    }
  ]',
  1,
  '午前',
  2,
  '101号室1',
  '2019/02/13 12:00:00.000',
  '2019/02/13 18:00:00.000',
  1,
  2,
  2,
  '腎科',
  10,
  '糖尿内科',
  '{
    "user_id_1": 101,
    "user_last_name_1": "穿刺1",
    "user_first_name_1": "太郎",
    "user_id_2": 102,
    "user_last_name_2": "穿刺2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:00:00.000+0900"
  }',
  '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:30:00.000+0900"
  }',
  '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎"
  }',
  '2019-03-15 10:41:49.594',
  '2019-03-15 10:41:49.594'
);

-- mst_procedure(手技マスタ)　のデータ追加
INSERT INTO mst_procedure
  (procedure_cd, facility_cd, fn_procedure_cd, pricedure_name, in_hospital_cd_1, in_hospital_cd_2, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', NULL, '静脈注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.594', '2019-03-15 10:41:49.594')
  , (2, '009999', NULL, '皮下注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.625', '2019-03-15 10:41:49.625')
  , (3, '009999', NULL, '静脈側回路内注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.642', '2019-03-15 10:41:49.642')
  , (4, '009999', NULL, '動脈側回路内注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.657', '2019-03-15 10:41:49.657')
  , (5, '009999', NULL, '点滴静脈注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.673', '2019-03-15 10:41:49.673')
  , (6, '009999', NULL, '筋肉注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.688', '2019-03-15 10:41:49.688')
  , (7, '009999', NULL, '静脈側回路内点滴注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.701', '2019-03-15 10:41:49.701')
  , (8, '009999', NULL, '動脈側回路内点滴注射', NULL, NULL, '1', '0', '2019-03-15 10:41:49.727', '2019-03-15 10:41:49.727')
  , (9, '009999', NULL, 'その他', NULL, NULL, '1', '0', '2019-03-15 10:41:49.742', '2019-03-15 10:41:49.742')
;

-- mst_medicate_timing(投与タイミングマスタ)　のデータ追加
INSERT INTO mst_medicate_timing
  (medicate_timing_cd, facility_cd, fn_medicate_timing_cd, medicate_timing_name, dialysis_progress_cd, alert_time, is_alert, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', NULL, '透析後', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.466', '2019-03-15 10:45:45.466')
  , (2, '009999', NULL, '透析中', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.495', '2019-03-15 10:45:45.495')
  , (3, '009999', NULL, '透析前', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.534', '2019-03-15 10:45:45.534')
  , (4, '009999', NULL, 'その他', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.560', '2019-03-15 10:45:45.560')
  , (5, '009999', NULL, '透析終了時', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.586', '2019-03-15 10:45:45.586')
  , (6, '009999', NULL, '透析終了30分前', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.662', '2019-03-15 10:45:45.662')
  , (7, '009999', NULL, '透析終了1時間前', NULL, 0, '0', '1', '0', '2019-03-15 10:45:45.684', '2019-03-15 10:45:45.684')
;

-- mst_selector(選択肢マスタ)　のデータ追加
INSERT INTO mst_selector
  (facility_cd, master_physical_name, order_settings, reg_date, up_date)
VALUES
  ('009999', 'mst_medicate_timing', '{"items": [{"code": 1, "name": "透析後"}, {"code": 2, "name": "透析中"}, {"code": 3, "name": "透析前"}, {"code": 4, "name": "その他"}, {"code": 5, "name": "透析終了時"}, {"code": 6, "name": "透析終了30分前"}, {"code": 7, "name": "透析終了1時間前"}]}', '2019-03-15 10:45:45.712', '2019-03-15 10:45:45.712')
  , ('009999', 'mst_procedure', '{"items": [{"code": 1, "name": "静脈注射"}, {"code": 2, "name": "皮下注射"}, {"code": 3, "name": "静脈側回路内注射"}, {"code": 4, "name": "動脈側回路内注射"}, {"code": 5, "name": "点滴静脈注射"}, {"code": 6, "name": "筋肉注射"}, {"code": 7, "name": "静脈側回路内点滴注射"}, {"code": 8, "name": "動脈側回路内点滴注射"}, {"code": 9, "name": "その他"}]}', '2019-03-15 10:41:49.757', '2019-03-15 12:06:24.317')
;
