UPDATE sys_data_set
SET 
  "sql"=
'select
  *
from
  ord_main
where
  ord_no = @ordNo'
  , detail='
    [
      {
        "preview": "2011/3/12  08:21"
        , "can_calc": "0"
        , "data_code": "rst_start_date"
        , "data_name": "透析開始日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_start_date"
        , "disp_format": "hh:mm"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "2011/3/12  12:45"
        , "can_calc": "0"
        , "data_code": "rst_end_date"
        , "data_name": "透析終了日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_end_date"
        , "disp_format": "hh:mm"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]'
WHERE 
  sql_cd=2
;

UPDATE 
  sys_data_set 
SET 
  "sql"=
'select
  hosp_pat_id,
  personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name,
  in_out_class
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId'
  , detail='
    [
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
      }
      ,{
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
      }
    ]'
WHERE
  sql_cd=1
;
