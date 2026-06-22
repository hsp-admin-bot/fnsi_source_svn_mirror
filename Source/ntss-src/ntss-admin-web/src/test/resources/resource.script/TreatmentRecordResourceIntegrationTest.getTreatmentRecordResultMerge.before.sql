DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , treat_date
    , facility_cd
    , rst_input_class
    , rst_dialysis_state
    , rst_treatment_cd
    , rst_treatment_name
    , rst_kur_cd
    , rst_kur_name
    , rst_bed_cd
    , rst_bed_name
    , rst_machine_name
    , rst_cond_send_date
    , rst_accept_date
    , rst_start_date
    , rst_end_date
    , rst_return_home_date
    , rst_in_out_class
    , rst_dialysis_cnt
    , rst_purification_cnt
    , rst_ward_cd
    , rst_ward_name
    , rst_course_cd
    , rst_course_name
    , rst_dw
    , rst_puncture_user_info
    , rst_return_user_info
    , rst_charge_user_info
    , rst_blood_circulate_total
    , rst_running_time
    , rst_kt_v
    , rec_set_date
    , send_ctl_no
    , blood_purifier_name
    , pull_leave_amount
    , rst_cond_info
    , rst_medi_info
    , rst_equip_info
    , rst_ind_comment_info
    , rst_tare_info
    , rst_off_water_info
    , rst_device_set_info
    , weight_scale_no
    , rst_weight_info
    , rst_vital_info
    , rst_complaint_info
    , rst_treatment_info
    , rst_treat_staff_info
    , rst_rounds_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , 2
    , '20190626'
    , '000001'
    , 1
    , '3'
    , 1
    , 'テスト治療方法'
    , 1
    , 'テストクール名'
    , 2
    , 'テストベッド名'
    , 'テスト装置名'
    , '2019/06/26 09:00:00.000'
    , '2019/06/26 09:30:00.000'
    , '2019/06/26 10:00:00.000'
    , '2019/06/26 13:00:00.000'
    , '2019/06/26 14:00:00.000'
    , 0
    , 2
    , 2
    , 3
    , 'テスト病棟名'
    , 4
    , 'テスト診療科名'
    , 55.3
    , '{
        "user_id_1": 101,
        "user_last_name_1": "穿刺1",
        "user_first_name_1": "太郎",
        "user_id_2": 102,
        "user_last_name_2": "穿刺2",
        "user_first_name_2": "次郎",
        "date": "2019-02-13T13:00:00.000+09:00",
        "date_1": "2019-02-13T14:00:00.000+09:00",
        "date_2": "2019-02-13T15:00:00.000+09:00"
      }'
    , '{
        "user_id_1": 103,
        "user_last_name_1": "返血1",
        "user_first_name_1": "太郎",
        "user_id_2": 104,
        "user_last_name_2": "返血2",
        "user_first_name_2": "次郎",
        "date": "2019-02-13T13:30:00.000+09:00",
        "date_1": "2019-02-13T14:30:00.000+09:00",
        "date_2": "2019-02-13T15:30:00.000+09:00"
      }'
    , '{
        "user_id_1": 105,
        "user_last_name_1": "担当1",
        "user_first_name_1": "太郎",
        "user_id_2": 106,
        "user_last_name_2": "担当2",
        "user_first_name_2": "次郎",
        "date_1": "2019-02-14T14:30:00.000+09:00",
        "date_2": "2019-02-14T15:30:00.000+09:00"
      }'
    , 200.24
    , 180
    , 7.5
    , '2019/06/26 15:00:00.000'
    , 5
    , 'テスト浄化装置'
    , 8.3
    , '{
        "1": {
          "unit": null,
          "value": "0400",
          "ind_user_id": 101,
          "input_class": 1,
          "is_editable": 1,
          "upd_user_id": 201,
          "cop_order_no": null,
          "value_name_1": null,
          "value_name_2": null,
          "value_name_3": null,
          "value_name_4": null,
          "value_name_5": null,
          "value_name_6": null,
          "value_name_7": null,
          "value_name_8": null,
          "value_name_9": null,
          "medicine_type": null,
          "value_name_10": null,
          "ind_user_last_name": "yamada",
          "upd_user_last_name": "tanaka",
          "ind_user_first_name": "taro1",
          "upd_user_first_name": "hanako1"
        }
      }'
    , '[
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
        }
      ]'
    , '[
        {
          "class_cd": 3,
          "class_name": "吸着カラム",
          "class_type": 4,
          "cd": 2,
          "name": "テスト吸着カラム",
          "short_name": "",
          "needle_type": 0,
          "amount": 5,
          "unit": "本",
          "ind_user_id": 101,
          "ind_user_last_name": "指示者1",
          "ind_user_first_name": "太郎",
          "upd_user_id": 102,
          "upd_user_last_name": "更新者1",
          "upd_user_first_name": "次郎",
          "input_class": 1,
          "is_editable": 1,
          "cop_order_no": 1
        }
      ]'
    , '[
        {
          "no": 1,
          "content": "指示コメント１",
          "ind_user_id": 1,
          "input_class": 1,
          "is_editable": "1",
          "upd_user_id": 1,
          "cop_order_no": "1",
          "ind_user_last_name": "山田",
          "upd_user_last_name": "山田",
          "ind_user_first_name": "太郎",
          "upd_user_first_name": "太郎"
        }
      ]'
    , '{
        "after": {
          "name_1": "[後]スリッパ",
          "name_2": "[後]服",
          "name_3": "[後]義足",
          "name_4": "[後]その他風袋１",
          "name_5": "[後]その他風袋２",
          "weight_1": 310,
          "weight_2": 1210,
          "weight_3": 410,
          "weight_4": 410,
          "weight_5": 12910,
          "wheel_chair_cd": "1",
          "wheel_chair_name": "[後]車いす",
          "wheel_chair_weight": 3510
        },
        "before": {
          "name_1": "[前]スリッパ",
          "name_2": "[前]服",
          "name_3": "[前]義足",
          "name_4": "[前]その他風袋１",
          "name_5": "[前]その他風袋２",
          "weight_1": 300,
          "weight_2": 1200,
          "weight_3": 400,
          "weight_4": 400,
          "weight_5": 12900,
          "wheel_chair_cd": "1",
          "wheel_chair_name": "[前]車いす",
          "wheel_chair_weight": 3500
        }
      }'
    , '{
        "name_1": "除水補正１",
        "name_2": "除水補正２",
        "name_3": "除水補正３",
        "name_4": "除水補正４",
        "name_5": "除水補正５",
        "weight_1": 300,
        "weight_2": 1200,
        "weight_3": 600,
        "weight_4": 1200,
        "weight_5": 1500
      }'
    , '{
        "bp": {
          "dev": {
            "A": {
              "190": 30,
              "191": "0",
              "192": 180,
              "193": "1",
              "194": "0",
              "195": "1",
              "211": 200,
              "212": 80,
              "213": 160,
              "214": 50,
              "215": 180,
              "216": 60,
              "217": 170,
              "218": 50,
              "219": "1",
              "220": "1",
              "221": "1",
              "222": "1",
              "223": "1",
              "224": "1",
              "225": "1",
              "226": "1",
              "227": 40,
              "228": 40,
              "229": 0,
              "230": 0,
              "231": 0,
              "232": 0,
              "233": 0,
              "234": 0,
              "235": 0,
              "236": 0,
              "237": "0",
              "238": "0",
              "239": "1"
            }
          }
        }
      }'
    , 302
    , '{
        "ctr": 11,
        "urr": 17,
        "add_total": 14,
        "ctr_weight": 72,
        "kt_v_measure": 16,
        "weight_after": 59.2,
        "weight_before": 60,
        "re_loop_rate_1": { "date": "2019-03-20T09:00:00+09:00", "value": 50 },
        "re_loop_rate_2": { "date": "2019-03-20T09:10:00+09:00", "value": 55 },
        "re_loop_rate_3": { "date": "2019-03-20T09:20:00+09:00", "value": 60 },
        "re_loop_rate_4": { "date": "2019-03-20T09:30:00+09:00", "value": 65 },
        "re_loop_rate_5": { "date": "2019-03-20T09:40:00+09:00", "value": 70 },
        "add_water_total": 15,
        "ctr_measure_date": "2019-03-20T12:10:05.055+09:00",
        "weight_decreased": 18,
        "re_loop_rate_main": 11,
        "water_removal_rst": 13,
        "weight_after_date": "2019-03-20T15:30:00.000+09:00",
        "weight_before_date": "2018-04-04T00:00:00.000+09:00",
        "water_removal_target": 12,
        "weight_measure_after": 58.9,
        "weight_measure_before": 60.28
      }'
    , '[
        {
          "pulse": 60,
          "bp_ave": 125,
          "bp_max": 150,
          "bp_min": 90,
          "is_del": "0",
          "bp_class": "1",
          "occur_date": "2019-05-10T13:02:00.000+09:00",
          "temperature": 36.3,
          "bio_moni_ctl_no": 39,
          "blood_sugar_level": 120
        }
      ]'
    , '[
        {
          "ctl_no": 1,
          "comp_cd": 1,
          "complaint": "筋肉のつれ",
          "occur_date": "2019-03-27T13:50:00.000+09:00",
          "input_class": 0
        }
      ]'
    , '[
        {
          "unit": null,
          "amount": null,
          "ctl_no": 1,
          "row_no": 1,
          "treat_cd": 1,
          "occur_date": "2019-03-27T13:50:00.000+09:00",
          "treat_name": "下肢拳上",
          "input_class": 0,
          "is_editable": "1",
          "medicine_cd": null,
          "oxygen_time": null,
          "treat_class": 1,
          "cop_order_no": 1,
          "oxygen_speed": null,
          "oxygen_start": null,
          "procedure_cd": null,
          "medicine_name": null,
          "oxygen_amount": null,
          "procedure_name": null,
          "treat_medicine_cd": null,
          "treat_medicine_name": null,
          "electrocardiogram_type": null
        }
      ]'
    , '[
        {
          "ctl_no": 1,
          "row_no": 1,
          "occur_date": "2019-03-27T13:50:00.000+09:00",
          "input_class": 0,
          "is_editable": "1",
          "cop_order_no": 1,
          "treat_staff_cd": 1,
          "treat_staff_name": "スタッフ００１"
        }
      ]'
    , '[
        {
          "ctl_no": 1,
          "content": "内容1"
        }
      ]'
    , '0'
    , '2019/06/26 19:00:00.000'
    , '2019/06/26 18:00:00.000'
  )
  ,(
    2
    , 2
    , '20190701'
    , '000001'
    , 1
    , '3'
    , 1
    , 'テスト治療方法'
    , 1
    , 'テストクール名'
    , 2
    , 'テストベッド名'
    , 'テスト装置名'
    , '2019/06/26 09:00:00.000'
    , '2019/06/26 09:30:00.000'
    , '2019/06/26 10:00:00.000'
    , '2019/06/26 13:00:00.000'
    , '2019/06/26 14:00:00.000'
    , 0
    , 2
    , 2
    , 3
    , 'テスト病棟名'
    , 4
    , 'テスト診療科名'
    , 55.3
    , null
    , null
    , null
    , 200.24
    , 180
    , 7.5
    , '2019/06/26 15:00:00.000'
    , 5
    , 'テスト浄化装置'
    , 8.3
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , 302
    , null
    , null
    , null
    , null
    , null
    , null
    , '1'
    , '2019/06/26 19:00:00.000'
    , '2019/06/26 18:00:00.000'
  )
;
