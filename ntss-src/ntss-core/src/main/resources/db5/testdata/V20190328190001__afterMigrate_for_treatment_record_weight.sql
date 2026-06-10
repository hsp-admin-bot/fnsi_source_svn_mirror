-- ord_main(治療記録の体重用)　のデータ追加
SELECT setval('ord_main_ord_no_seq', 5, false);

INSERT INTO ord_main
(
  pat_id,
  fn_pat_id,
  treat_date,
  facility_cd,
  facility_name,
  rst_start_date,
  rst_dw,
  rst_cond_info,
  rst_weight_info,
  rst_tare_info,
  rst_off_water_info,
  is_del,
  up_date,
  reg_date
) VALUES (
  3,
  '00004',
  '20190307',
  '009999',
  'テスト施設名',
  '2019/03/28 12:00:00.000',
  70.5,
  '{
    "3": { "value": 52.1 },
    "4": { "value": 2.3 }
  }',
  '{
    "weight_before": 60,
    "weight_measure_before": 60.28,
    "weight_before_date": "2019-03-20T12:00:00+09:00",
    "weight_after": 59.2,
    "weight_measure_after": 58.9,
    "weight_after_date": "2019-03-20T15:30:00+09:00",
    "ctr": 11,
    "ctr_measure_date": "2019-03-20T12:10:05+09:00",
    "ctr_weight": 72,
    "water_removal_target": 12,
    "water_removal_rst": 13,
    "add_total": 14,
    "add_water_total": 15,
    "kt_v_measure": 16,
    "urr": 17,
    "weight_decreased": 18,
    "re_loop_rate_main": 1,
    "re_loop_rate_1": { "date": "2019-03-20T09:00:00+09:00", "value": 50 },
    "re_loop_rate_2": { "date": "2019-03-20T09:10:00+09:00", "value": 55 },
    "re_loop_rate_3": { "date": "2019-03-20T09:20:00+09:00", "value": 60 },
    "re_loop_rate_4": { "date": "2019-03-20T09:30:00+09:00", "value": 65 },
    "re_loop_rate_5": { "date": "2019-03-20T09:40:00+09:00", "value": 70 }
  }',
  '{
    "before": {
      "name_1": "[前]スリッパ", "weight_1": 300,
      "name_2": "[前]服", "weight_2": 1200,
      "name_3": "[前]義足", "weight_3": 400,
      "name_4": "[前]その他風袋１", "weight_4": 400,
      "name_5": "[前]その他風袋２", "weight_5": 12900,
      "wheel_chair_cd": "1", "wheel_chair_name": "[前]車いす", "wheel_chair_weight": 3500
    },
    "after": {
      "name_1": "[後]スリッパ", "weight_1": 310,
      "name_2": "[後]服", "weight_2": 1210,
      "name_3": "[後]義足", "weight_3": 410,
      "name_4": "[後]その他風袋１", "weight_4": 410,
      "name_5": "[後]その他風袋２", "weight_5": 12910,
      "wheel_chair_cd": "1", "wheel_chair_name": "[後]車いす", "wheel_chair_weight": 3510
    }
  }',
  '{
    "name_1": "除水補正１", "weight_1": 300,
    "name_2": "除水補正２", "weight_2": 1200,
    "name_3": "除水補正３", "weight_3": 600,
    "name_4": "除水補正４", "weight_4": 1200,
    "name_5": "除水補正５", "weight_5": 1500
  }',
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
), (
  3,
  '00004',
  '20190307',
  '009999',
  'テスト施設名',
  '2019/03/27 14:00:00.000',
  70,
  null,
  '{
    "weight_after": 61.3
  }',
  null,
  null,
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
);
