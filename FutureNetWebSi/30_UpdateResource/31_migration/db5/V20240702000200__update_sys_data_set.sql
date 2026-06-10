DELETE FROM "ntss"."sys_data_set" where sql_cd in (91);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (91, 'with input_params_expand as
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
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
), result_params_expand as
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_cd
		,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''7''
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
--   ,to_timestamp(event_start_date||
--     case when event_start_time is null then ''0000''
--          else event_start_time
--     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
--   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name

  ,picked_result_params[1]->''result_value''->0->>''file_name'' as data1_file_name1
  ,picked_result_params[1]->''result_value''->0->>''file_path'' as data1_file_path1
  ,picked_result_params[1]->''result_value''->1->>''file_name'' as data1_file_name2
  ,picked_result_params[1]->''result_value''->1->>''file_path'' as data1_file_path2
  ,picked_result_params[1]->''result_value''->2->>''file_name'' as data1_file_name3
  ,picked_result_params[1]->''result_value''->2->>''file_path'' as data1_file_path3
  ,picked_result_params[1]->''result_value''->3->>''file_name'' as data1_file_name4
  ,picked_result_params[1]->''result_value''->3->>''file_path'' as data1_file_path4
  ,picked_result_params[1]->''result_value''->4->>''file_name'' as data1_file_name5
  ,picked_result_params[1]->''result_value''->4->>''file_path'' as data1_file_path5
  ,picked_result_params[1]->''result_value''->5->>''file_name'' as data1_file_name6
  ,picked_result_params[1]->''result_value''->5->>''file_path'' as data1_file_path6
  ,picked_result_params[1]->''result_value''->6->>''file_name'' as data1_file_name7
  ,picked_result_params[1]->''result_value''->6->>''file_path'' as data1_file_path7
  ,picked_result_params[1]->''result_value''->7->>''file_name'' as data1_file_name8
  ,picked_result_params[1]->''result_value''->7->>''file_path'' as data1_file_path8
  ,picked_result_params[1]->''result_value''->8->>''file_name'' as data1_file_name9
  ,picked_result_params[1]->''result_value''->8->>''file_path'' as data1_file_path9
  ,picked_result_params[1]->''result_value''->9->>''file_name'' as data1_file_name10
  ,picked_result_params[1]->''result_value''->9->>''file_path'' as data1_file_path10

  ,picked_result_params[2]->''result_value''->0->>''file_name'' as data2_file_name1
  ,picked_result_params[2]->''result_value''->0->>''file_path'' as data2_file_path1
  ,picked_result_params[2]->''result_value''->1->>''file_name'' as data2_file_name2
  ,picked_result_params[2]->''result_value''->1->>''file_path'' as data2_file_path2
  ,picked_result_params[2]->''result_value''->2->>''file_name'' as data2_file_name3
  ,picked_result_params[2]->''result_value''->2->>''file_path'' as data2_file_path3
  ,picked_result_params[2]->''result_value''->3->>''file_name'' as data2_file_name4
  ,picked_result_params[2]->''result_value''->3->>''file_path'' as data2_file_path4
  ,picked_result_params[2]->''result_value''->4->>''file_name'' as data2_file_name5
  ,picked_result_params[2]->''result_value''->4->>''file_path'' as data2_file_path5
  ,picked_result_params[2]->''result_value''->5->>''file_name'' as data2_file_name6
  ,picked_result_params[2]->''result_value''->5->>''file_path'' as data2_file_path6
  ,picked_result_params[2]->''result_value''->6->>''file_name'' as data2_file_name7
  ,picked_result_params[2]->''result_value''->6->>''file_path'' as data2_file_path7
  ,picked_result_params[2]->''result_value''->7->>''file_name'' as data2_file_name8
  ,picked_result_params[2]->''result_value''->7->>''file_path'' as data2_file_path8
  ,picked_result_params[2]->''result_value''->8->>''file_name'' as data2_file_name9
  ,picked_result_params[2]->''result_value''->8->>''file_path'' as data2_file_path9
  ,picked_result_params[2]->''result_value''->9->>''file_name'' as data2_file_name10
  ,picked_result_params[2]->''result_value''->9->>''file_path'' as data2_file_path10

  ,picked_result_params[3]->''result_value''->0->>''file_name'' as data3_file_name1
  ,picked_result_params[3]->''result_value''->0->>''file_path'' as data3_file_path1
  ,picked_result_params[3]->''result_value''->1->>''file_name'' as data3_file_name2
  ,picked_result_params[3]->''result_value''->1->>''file_path'' as data3_file_path2
  ,picked_result_params[3]->''result_value''->2->>''file_name'' as data3_file_name3
  ,picked_result_params[3]->''result_value''->2->>''file_path'' as data3_file_path3
  ,picked_result_params[3]->''result_value''->3->>''file_name'' as data3_file_name4
  ,picked_result_params[3]->''result_value''->3->>''file_path'' as data3_file_path4
  ,picked_result_params[3]->''result_value''->4->>''file_name'' as data3_file_name5
  ,picked_result_params[3]->''result_value''->4->>''file_path'' as data3_file_path5
  ,picked_result_params[3]->''result_value''->5->>''file_name'' as data3_file_name6
  ,picked_result_params[3]->''result_value''->5->>''file_path'' as data3_file_path6
  ,picked_result_params[3]->''result_value''->6->>''file_name'' as data3_file_name7
  ,picked_result_params[3]->''result_value''->6->>''file_path'' as data3_file_path7
  ,picked_result_params[3]->''result_value''->7->>''file_name'' as data3_file_name8
  ,picked_result_params[3]->''result_value''->7->>''file_path'' as data3_file_path8
  ,picked_result_params[3]->''result_value''->8->>''file_name'' as data3_file_name9
  ,picked_result_params[3]->''result_value''->8->>''file_path'' as data3_file_path9
  ,picked_result_params[3]->''result_value''->9->>''file_name'' as data3_file_name10
  ,picked_result_params[3]->''result_value''->9->>''file_path'' as data3_file_path10

  ,picked_result_params[4]->''result_value''->0->>''file_name'' as data4_file_name1
  ,picked_result_params[4]->''result_value''->0->>''file_path'' as data4_file_path1
  ,picked_result_params[4]->''result_value''->1->>''file_name'' as data4_file_name2
  ,picked_result_params[4]->''result_value''->1->>''file_path'' as data4_file_path2
  ,picked_result_params[4]->''result_value''->2->>''file_name'' as data4_file_name3
  ,picked_result_params[4]->''result_value''->2->>''file_path'' as data4_file_path3
  ,picked_result_params[4]->''result_value''->3->>''file_name'' as data4_file_name4
  ,picked_result_params[4]->''result_value''->3->>''file_path'' as data4_file_path4
  ,picked_result_params[4]->''result_value''->4->>''file_name'' as data4_file_name5
  ,picked_result_params[4]->''result_value''->4->>''file_path'' as data4_file_path5
  ,picked_result_params[4]->''result_value''->5->>''file_name'' as data4_file_name6
  ,picked_result_params[4]->''result_value''->5->>''file_path'' as data4_file_path6
  ,picked_result_params[4]->''result_value''->6->>''file_name'' as data4_file_name7
  ,picked_result_params[4]->''result_value''->6->>''file_path'' as data4_file_path7
  ,picked_result_params[4]->''result_value''->7->>''file_name'' as data4_file_name8
  ,picked_result_params[4]->''result_value''->7->>''file_path'' as data4_file_path8
  ,picked_result_params[4]->''result_value''->8->>''file_name'' as data4_file_name9
  ,picked_result_params[4]->''result_value''->8->>''file_path'' as data4_file_path9
  ,picked_result_params[4]->''result_value''->9->>''file_name'' as data4_file_name10
  ,picked_result_params[4]->''result_value''->9->>''file_path'' as data4_file_path10

  ,picked_result_params[5]->''result_value''->0->>''file_name'' as data5_file_name1
  ,picked_result_params[5]->''result_value''->0->>''file_path'' as data5_file_path1
  ,picked_result_params[5]->''result_value''->1->>''file_name'' as data5_file_name2
  ,picked_result_params[5]->''result_value''->1->>''file_path'' as data5_file_path2
  ,picked_result_params[5]->''result_value''->2->>''file_name'' as data5_file_name3
  ,picked_result_params[5]->''result_value''->2->>''file_path'' as data5_file_path3
  ,picked_result_params[5]->''result_value''->3->>''file_name'' as data5_file_name4
  ,picked_result_params[5]->''result_value''->3->>''file_path'' as data5_file_path4
  ,picked_result_params[5]->''result_value''->4->>''file_name'' as data5_file_name5
  ,picked_result_params[5]->''result_value''->4->>''file_path'' as data5_file_path5
  ,picked_result_params[5]->''result_value''->5->>''file_name'' as data5_file_name6
  ,picked_result_params[5]->''result_value''->5->>''file_path'' as data5_file_path6
  ,picked_result_params[5]->''result_value''->6->>''file_name'' as data5_file_name7
  ,picked_result_params[5]->''result_value''->6->>''file_path'' as data5_file_path7
  ,picked_result_params[5]->''result_value''->7->>''file_name'' as data5_file_name8
  ,picked_result_params[5]->''result_value''->7->>''file_path'' as data5_file_path8
  ,picked_result_params[5]->''result_value''->8->>''file_name'' as data5_file_name9
  ,picked_result_params[5]->''result_value''->8->>''file_path'' as data5_file_path9
  ,picked_result_params[5]->''result_value''->9->>''file_name'' as data5_file_name10
  ,picked_result_params[5]->''result_value''->9->>''file_path'' as data5_file_path10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name1", "data_name": "データ1 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name2", "data_name": "データ1 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name3", "data_name": "データ1 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name4", "data_name": "データ1 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name5", "data_name": "データ1 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name6", "data_name": "データ1 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name7", "data_name": "データ1 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name8", "data_name": "データ1 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name9", "data_name": "データ1 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name10", "data_name": "データ1 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name1", "data_name": "データ2 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name2", "data_name": "データ2 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name3", "data_name": "データ2 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name4", "data_name": "データ2 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name5", "data_name": "データ2 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name6", "data_name": "データ2 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name7", "data_name": "データ2 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name8", "data_name": "データ2 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name9", "data_name": "データ2 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name10", "data_name": "データ2 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name1", "data_name": "データ3 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name2", "data_name": "データ3 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name3", "data_name": "データ3 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name4", "data_name": "データ3 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name5", "data_name": "データ3 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name6", "data_name": "データ3 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name7", "data_name": "データ3 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name8", "data_name": "データ3 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name9", "data_name": "データ3 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name10", "data_name": "データ3 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name1", "data_name": "データ4 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name2", "data_name": "データ4 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name3", "data_name": "データ4 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name4", "data_name": "データ4 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name5", "data_name": "データ4 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name6", "data_name": "データ4 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name7", "data_name": "データ4 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name8", "data_name": "データ4 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name9", "data_name": "データ4 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name10", "data_name": "データ4 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name1", "data_name": "データ5 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name2", "data_name": "データ5 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name3", "data_name": "データ5 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name4", "data_name": "データ5 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name5", "data_name": "データ5 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name6", "data_name": "データ5 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name7", "data_name": "データ5 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name8", "data_name": "データ5 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name9", "data_name": "データ5 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name10", "data_name": "データ5 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 添付ファイル　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
