update sys_data_set 
set sql='with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''1''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_result_params[1]->>''result_value'' as data1 
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;',
detail = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "category_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "sub_category_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10_field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' 
where sql_cd = '85'