UPDATE
  sys_data_set
SET
  "sql" = '
    select
      medi ->> ''class_cd'' as medi_class_cd,
      medi ->> ''class_type'' as medi_class_type,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''amount'' as medi_amount,
      medi ->> ''timing_name'' as medi_timing_name
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
    where
      ord.ord_no = @ordNo
  '
  , detail = '
    [
      {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_class_cd"
        , "data_name": "薬剤分類コード"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_class_cd"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_class_type"
        , "data_name": "分類区分"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_class_type"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_cd"
        , "data_name": "薬剤(調整薬剤)コード"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_cd"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "テスト薬剤１"
        , "can_calc": "0"
        , "data_code": "medi_name"
        , "data_name": "薬剤名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_name"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_amount"
        , "data_name": "数量"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_amount"
        , "disp_format": "0"
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "透析中"
        , "can_calc": "0"
        , "data_code": "medi_timing_name"
        , "data_name": "投与時間帯"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_timing_name"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]
  '
WHERE
  sql_cd = 4
;
