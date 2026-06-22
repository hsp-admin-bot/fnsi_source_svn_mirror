UPDATE
  ord_main
SET
  rst_complaint_info = '[
    {
      "ctl_no": 1,
      "row_no": 1,
      "input_class": 0,
      "occur_date": "2019-03-27T13:50:00.000+09:00",
      "comp_cd": 1,
      "complaint": "筋肉のつれ"
    },
    {
      "ctl_no": 2,
      "row_no": 2,
      "input_class": 0,
      "occur_date": "2019-03-27T13:51:00.000+09:00",
      "comp_cd": 2,
      "complaint": "血液低下"
    },
    {
      "ctl_no": 3,
      "row_no": 3,
      "input_class": 0,
      "occur_date": "2019-03-27T13:52:00.000+09:00",
      "comp_cd": 3,
      "complaint": "TMP上昇"
    },
    {
      "ctl_no": 4,
      "row_no": 4,
      "input_class": 0,
      "occur_date": "2019-03-27T14:10:00.000+09:00",
      "comp_cd": 2,
      "complaint": "血液低下"
    },
    {
      "ctl_no": 5,
      "row_no": 5,
      "input_class": 0,
      "occur_date": "2019-03-27T14:15:00.000+09:00",
      "comp_cd": 2,
      "complaint": "血液低下"
    },
    {
      "ctl_no": 6,
      "row_no": 6,
      "input_class": 0,
      "occur_date": "2019-03-27T14:20:00.000+09:00",
      "comp_cd": 4,
      "complaint": "愁訴テスト１"
    },
    {
      "ctl_no": 7,
      "row_no": 7,
      "input_class": 0,
      "occur_date": "2019-03-27T14:30:00.000+09:00",
      "comp_cd": 5,
      "complaint": "愁訴テスト２"
    }
  ]'
WHERE
  ord_no in (2, 7)
;
