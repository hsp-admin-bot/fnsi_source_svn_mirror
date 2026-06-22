INSERT INTO mst_round_type
  (round_type_cd, facility_cd, round_type_name, "content", is_content_omission, comment_post_default, posting_class_default, is_disp, is_del)
VALUES
  (1, '009999', '特変なし', '', '1', '0', '0', '1', '0')
, (2, '009999', '記録作成（転記OFF・当日のみ）', '内容３４５６７８９０１２３４５６７８９０', '0', '0', '1', '1', '0')
, (3, '009999', '記録作成省略（転記OFF・当日のみ）', 'piyopiyo', '1', '0', '1', '1', '0')
, (4, '009999', '削除済', 'abcdefg', '0', '0', '1', '0', '0')
, (5, '009999', '記録作成（転記ON・継続）', '記入内容', '0', '1', '0', '1', '0')
, (6, '009999', '記録作成（転記OFF・継続）', '記入内容', '0', '0', '0', '1', '0')
;

SELECT setval('mst_round_type_round_type_cd_seq', 6);

INSERT INTO
  mst_selector
  (
    facility_cd
    , master_physical_name
    , order_settings
  )
VALUES
  (
    '009999'
    , 'mst_round_type'
    , '{"items": [
          {"code": 1, "name": "特変なし"},
          {"code": 3, "name": "記録作成省略（転記OFF・当日のみ）"},
          {"code": 2, "name": "記録作成（転記OFF・当日のみ）"},
          {"code": 5, "name": "記録作成（転記ON・継続）"},
          {"code": 6, "name": "記録作成（転記OFF・継続）"}
       ]}'
  )
;
