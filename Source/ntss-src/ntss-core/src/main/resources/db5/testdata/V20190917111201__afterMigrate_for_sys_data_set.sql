UPDATE
  sys_data_set
SET
  "sql" = '
    select
      hosp_pat_id
      , personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
      , in_out_class
      , pat_sex
    from
      pat_personal_main
    where
      is_del = ''0''
    and
      pat_id = @patId
  '
  , detail = '[
    {
      "preview": "123456789012"
      , "can_calc": "0"
      , "data_code": "pat_id"
      , "data_name": "患者ID"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "hosp_pat_id"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }
    , {
      "preview": "日機装　太郎"
      , "can_calc": "0"
      , "data_code": "pat_name"
      , "data_name": "氏名"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "pat_name"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }, {
      "preview": "0"
      , "can_calc": "0"
      , "data_code": "in_out_class"
      , "data_name": "入外区分"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "in_out_class"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }, {
      "preview": "男性"
      , "can_calc": "0"
      , "data_code": "pat_sex"
      , "data_name": "性別"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "pat_sex"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }
  ]'
WHERE
  sql_cd = 1
;

INSERT INTO
  sys_data_set
  (
    sql_cd
    , "sql"
    , db_class
    , detail
    , can_repeat
    , use_application
    , report_class
    , memo
    , reg_date
    , up_date
  )
VALUES
  (
    7
    , '
      select
        *
      from
        ord_main
      where
        pat_id = @patId
      order by rst_start_date desc
    '
    , 2
    , '[
      {
        "preview": "2011/3/12 08:21"
        , "can_calc": "0"
        , "data_code": "rst_start_date"
        , "data_name": "透析開始日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_start_date"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_treatment_cd"
        , "data_name": "治療方法コード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_treatment_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テスト治療方法"
        , "can_calc": "0"
        , "data_code": "rst_treatment_name"
        , "data_name": "治療方法名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_treatment_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_kur_cd"
        , "data_name": "クールコード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_kur_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テストクール"
        , "can_calc": "0"
        , "data_code": "rst_kur_name"
        , "data_name": "クール名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_kur_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_bed_cd"
        , "data_name": "ベッドコード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_bed_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テストベッド"
        , "can_calc": "0"
        , "data_code": "rst_bed_name"
        , "data_name": "ベッド名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_bed_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "55.00"
        , "can_calc": "1"
        , "data_code": "rst_dw"
        , "data_name": "DW"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_dw"
        , "disp_format": "0.00"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]'
    , '1'
    , NULL
    , NULL
    , NULL
    , '2019-09-17 11:32:00.000'
    , '2019-09-17 11:32:00.000'
  )
;
