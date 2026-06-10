-- ord_main(治療情報)　の実績情報の担当者１・２登録日時データ更新
UPDATE
  ord_main
SET
  rst_puncture_user_info = '{
    "user_id_1": 101,
    "user_last_name_1": "穿刺1",
    "user_first_name_1": "太郎",
    "user_id_2": 102,
    "user_last_name_2": "穿刺2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:00:00.000+09:00",
    "date_1": "2019-02-13T01:00:00.000+09:00",
    "date_2": "2019-02-13T02:00:00.000+09:00"
  }',
  rst_return_user_info = '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:30:00.000+09:00",
    "date_1": "2019-02-13T03:30:00.000+09:00",
    "date_2": "2019-02-13T04:30:00.000+09:00"
  }',
  rst_charge_user_info = '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎",
    "date_1": "2019-02-13T05:30:00.000+09:00",
    "date_2": "2019-02-13T06:30:00.000+09:00"
  }'
WHERE
  ord_no = 1
;
