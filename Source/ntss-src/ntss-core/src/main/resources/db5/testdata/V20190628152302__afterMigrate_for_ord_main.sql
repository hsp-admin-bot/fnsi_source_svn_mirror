UPDATE
  ord_main
SET
  rst_rounds_info = '{
    "round_type_cd": 1,
    "round_type_name": "テスト種別名1",
    "reg_date_time": "2019-06-25T09:00:10.000+09:00",
    "ind_user_id": 105,
    "ind_user_last_name": "担当1",
    "ind_user_first_name": "太郎",
    "reg_user_id": 106,
    "reg_user_last_name": "担当2",
    "reg_user_first_name": "太郎",
    "content": "テスト内容1",
    "is_ind_comment_post": "1",
    "ind_comment_no": 1,
    "posting_class": "0",
    "created_user_id": 105,
    "created_user_last_name": "担当1",
    "created_user_first_name": "太郎",
    "created_at": "2019-06-25T09:00:10.000+09:00",
    "updated_user_id": 106,
    "updated_user_last_name": "担当2",
    "updated_user_first_name": "太郎",
    "updated_at": "2019-06-25T10:01:10.000+09:00"
  }'
WHERE
  ord_no = 1
;

UPDATE
  ord_main
SET
  rst_rounds_info = '{
    "round_type_cd": 2,
    "round_type_name": "テスト種別名2",
    "reg_date_time": "2019-06-28T15:34:10.000+09:00",
    "ind_user_id": 105,
    "ind_user_last_name": "担当1",
    "ind_user_first_name": "太郎",
    "reg_user_id": 106,
    "reg_user_last_name": "担当2",
    "reg_user_first_name": "太郎",
    "content": "テスト内容2",
    "is_ind_comment_post": "0",
    "ind_comment_no": 3,
    "posting_class": "1",
    "created_user_id": 105,
    "created_user_last_name": "担当1",
    "created_user_first_name": "太郎",
    "created_at": "2019-06-28T15:34:10.000+09:00",
    "updated_user_id": 106,
    "updated_user_last_name": "担当2",
    "updated_user_first_name": "太郎",
    "updated_at": "2019-06-28T16:34:10.000+09:00"
  }'
WHERE
  ord_no = 7
;
