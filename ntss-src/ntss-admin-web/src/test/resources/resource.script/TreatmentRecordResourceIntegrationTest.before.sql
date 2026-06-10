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
  rst_treatment_name,
  rst_purification_cnt
)
VALUES (
  1,
  2,
  '00003',
  '20190213',
  1,
  '009999',
  'テスト施設名',
  '0',
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
    "date_1": "2019-02-13T14:00:00.000+09:00",
    "date_2": "2019-02-13T15:00:00.000+09:00"
  }',
  '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:30:00.000+09:00",
    "date_1": "2019-02-13T14:30:00.000+09:00",
    "date_2": "2019-02-13T15:30:00.000+09:00"
  }',
  '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎",
    "date_1": "2019-02-14T14:30:00.000+09:00",
    "date_2": "2019-02-14T15:30:00.000+09:00"
  }',
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:30:00.000',
  100,
  'テスト治療方法１',
  1
),
(
  10,
  2,
  '00003',
  '20190213',
  1,
  '009999',
  'テスト施設名',
  '1',
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
    "date_1": "2019-02-13T14:31:00.000+09:00",
    "date_2": "2019-02-13T14:32:00.000+09:00"
  }',
  '0',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000',
  101,
  'テスト治療方法２',
  2
),
(
  12,
  2,
  '00003',
  '20190214',
  2,
  '009999',
  'テスト施設名',
  '2',
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
  102,
  'テスト治療方法３',
  3
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
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
);

INSERT INTO ord_main
(
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  facility_cd,
  facility_name,
  rst_cond_info,
  rst_start_date,
  rst_dw,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  up_date,
  reg_date
) VALUES (
  31,
  4,
  '00005',
  '20190307',
  '009999',
  'テスト施設名',
  null,
  '2019/02/13 12:00:00.000',
  66.3,
  null,
  null,
  '{
    "weight_after": 55.4
  }',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
),
(
  32,
  4,
  '00005',
  '20190307',
  '009999',
  'テスト施設名',
  '{
    "3":
    {
      "value": 56.3
    },
    "4":
    {
      "value": 5
    }
  }',
  '2019/03/13 12:00:00.000',
  66.5,
  '{
    "before":
    {
      "name_1": "スリッパ",
      "weight_1": 100
    },
    "after":
    {
      "name_1": "服",
      "weight_1": 500
    }
  }',
  '{
    "name_1": "除水補正1",
    "weight_1": 120
  }',
  '{
    "weight_before": 56.9,
    "weight_after": 58.4
  }',
  '2019/03/13 15:30:00.000',
  '2019/03/13 15:00:00.000'
);
INSERT INTO mni_monitor
(bio_moni_ctl_no, ord_no, data_type, monitor_data, occur_date) VALUES
  (1,  10, 3, '{"89": 70}', '2019/03/22 12:00:00.000'),
  (2,  10, 3, '{"89": 75}', '2019/03/22 13:00:00.000'),
  (3,  10, 3, '{"89": 80}', '2019/03/22 13:30:00.000'),
  (4,  10, 3, '{"89": 85}', '2019/03/22 14:00:00.000'),
  (5,  10, 3, '{"89": 90}', '2019/03/22 15:00:00.000'),
  (6,  10, 3, '{"89": 95}', '2019/03/22 16:00:00.000'),
  (11, 10, 1, '{"8": 90}',  '2019/03/22 11:30:00.000'),
  (12, 10, 1, '{"8": 100}', '2019/03/22 12:00:00.000'),
  (13, 10, 1, '{"8": 110}', '2019/03/22 14:00:00.000'),
  (14, 10, 1, '{"8": 120}', '2019/03/22 14:30:00.000'),
  (15, 10, 1, '{"8": 130}', '2019/03/22 17:00:00.000')
;

-- getLatestOrdNo用
INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , rst_start_date
    , rst_dialysis_state
    , is_del
    , up_date
  )
VALUES
  (
    111
    , 101
    , '000001'
    , '2019-03-25 13:00:00'
    , '1'
    , '0'
    , '2019-03-26 13:10:00'
  )
  ,(
    112
    , 101
    , '000001'
    , '2019-03-26 13:00:00'
    , '0'
    , '0'
    , '2019-03-27 13:10:00'
  )
  ,(
    113
    , 101
    , '000001'
    , '2019-03-26 13:00:00'
    , '2'
    , '0'
    , '2019-03-27 13:20:00'
  )
;

-- getTreatmentRecordSummary用
INSERT INTO
  ord_main
  (
    ord_no
    , facility_cd
    , treat_date
    , treat_week
    , rst_dialysis_state
    , rst_bed_cd
    , rst_bed_name
    , rst_kur_cd
    , rst_kur_name
    , rst_treatment_cd
    , rst_treatment_name
    , is_del
  )
VALUES
  (
    201
    , '009999'
    , '20190412'
    , 5
    , '6'
    , 1
    , 'ベッド１'
    , 2
    , 'クール１'
    , 3
    , '治療方法１'
    , '0'
  )
  ,(
    202
    , '009999'
    , '20190412'
    , 5
    , '0'
    , 1
    , 'ベッド１'
    , 2
    , 'クール１'
    , 3
    , '治療方法１'
    , '1'
  )
;

-- getTreatmentRecordVitalMonitor用
INSERT INTO mni_monitor
(bio_moni_ctl_no, ord_no, data_type, monitor_data, occur_date, is_del, upd_staff_id) VALUES
  (21,  11, 0, '{"89": 70}', '2019/03/22 12:00:00.000', '0', 1),
  (22,  11, 1, '{"89": 75}', '2019/03/22 13:00:00.000', '0', 2),
  (23,  11, 2, '{"89": 80}', '2019/03/22 13:30:00.000', '0', 3),
  (24,  11, 3, '{"89": 85}', '2019/03/22 14:00:00.000', '0', 4),
  (25,  11, 4, '{"89": 90}', '2019/03/22 15:00:00.000', '0', 5),
  (26,  11, 5, '{"89": 95}', '2019/03/22 16:00:00.000', '0', 6),
  (27,  11, 6, '{"89": 100}', '2019/03/22 17:00:00.000', '0', null),
  (28,  11, 2, '{"89": 105}', '2019/03/22 18:00:00.000', '1', 7)
;


-- updateTreatmentRecordVitalForMniMonitor用
-- オーダ番号は10000番台を使用
INSERT INTO ord_main
(
  ord_no,
  pat_id,
  facility_cd,
  rst_machine_no,
  up_date,
  reg_date
) VALUES (
  10000,
  3,
  'nkknkk',
  1,
  '2019/11/21 14:30:00.000',
  '2019/11/21 14:00:00.000'
);

INSERT INTO mst_machine
(
  facility_cd,
  machine_type_cd,
  machine_serial,
  machine_no,
  is_ftp,
  is_va
) VALUES (
  'nkknkk',
  '001',
  '00000002',
  1,
  '0',
  '0'
);

-- updateTreatmentRecordVitalForMniMonitorのinsertのテスト用にシーケンス番号の開始を1000に変更
SELECT
  setval('ntss.mni_monitor_bio_moni_ctl_no_seq', 1000, false);
