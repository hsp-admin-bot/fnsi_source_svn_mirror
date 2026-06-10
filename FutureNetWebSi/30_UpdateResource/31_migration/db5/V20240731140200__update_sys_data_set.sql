DELETE FROM "ntss"."sys_data_set" where sql_cd in (84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 68, 63, 69, 71, 73, 77, 79, 81, 227);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (84, 'with input_params_expand as
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
    input_param->>''format_class'' = ''0''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,pe_basicinfo.category_cd
	,pe_basicinfo.category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,pe_basicinfo.reg_staff_name
   ,pe_basicinfo.reg_date
--   ,pe_basicinfo.up_staff_name
--   ,pe_basicinfo.up_date
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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name
  ,case when picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then picked_input_params[1]->''item_json''->>''default_value''
        else picked_result_params[1]->>''result_value''
   end as data1
  ,case when picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[2]->''item_json''->>''default_value''
        else picked_result_params[2]->>''result_value''
   end as data2
  ,case when picked_result_params[3]->>''result_value'' is null or picked_result_params[3]->>''result_value'' = '''' then picked_input_params[3]->''item_json''->>''default_value''
        else picked_result_params[3]->>''result_value''
   end as data3
  ,case when picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then picked_input_params[4]->''item_json''->>''default_value''
        else picked_result_params[4]->>''result_value''
   end as data4
  ,case when picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then picked_input_params[5]->''item_json''->>''default_value''
        else picked_result_params[5]->>''result_value''
   end as data5
  ,case when picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then picked_input_params[6]->''item_json''->>''default_value''
        else picked_result_params[6]->>''result_value''
   end as data6
  ,case when picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then picked_input_params[7]->''item_json''->>''default_value''
        else picked_result_params[7]->>''result_value''
   end as data7
  ,case when picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then picked_input_params[8]->''item_json''->>''default_value''
        else picked_result_params[8]->>''result_value''
   end as data8
  ,case when picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then picked_input_params[9]->''item_json''->>''default_value''
        else picked_result_params[9]->>''result_value''
   end as data9
  ,case when picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then picked_input_params[10]->''item_json''->>''default_value''
        else picked_result_params[10]->>''result_value''
   end as data10
  ,case when picked_result_params[11]->>''result_value'' is null or picked_result_params[11]->>''result_value'' = '''' then picked_input_params[11]->''item_json''->>''default_value''
        else picked_result_params[11]->>''result_value''
   end as data11
  ,case when picked_result_params[12]->>''result_value'' is null or picked_result_params[12]->>''result_value'' = '''' then picked_input_params[12]->''item_json''->>''default_value''
        else picked_result_params[12]->>''result_value''
   end as data12
  ,case when picked_result_params[13]->>''result_value'' is null or picked_result_params[13]->>''result_value'' = '''' then picked_input_params[13]->''item_json''->>''default_value''
        else picked_result_params[13]->>''result_value''
   end as data13
  ,case when picked_result_params[14]->>''result_value'' is null or picked_result_params[14]->>''result_value'' = '''' then picked_input_params[14]->''item_json''->>''default_value''
        else picked_result_params[14]->>''result_value''
   end as data14
  ,case when picked_result_params[15]->>''result_value'' is null or picked_result_params[15]->>''result_value'' = '''' then picked_input_params[15]->''item_json''->>''default_value''
        else picked_result_params[15]->>''result_value''
   end as data15
  ,case when picked_result_params[16]->>''result_value'' is null or picked_result_params[16]->>''result_value'' = '''' then picked_input_params[16]->''item_json''->>''default_value''
        else picked_result_params[16]->>''result_value''
   end as data16
  ,case when picked_result_params[17]->>''result_value'' is null or picked_result_params[17]->>''result_value'' = '''' then picked_input_params[17]->''item_json''->>''default_value''
        else picked_result_params[17]->>''result_value''
   end as data17
  ,case when picked_result_params[18]->>''result_value'' is null or picked_result_params[18]->>''result_value'' = '''' then picked_input_params[18]->''item_json''->>''default_value''
        else picked_result_params[18]->>''result_value''
   end as data18
  ,case when picked_result_params[19]->>''result_value'' is null or picked_result_params[19]->>''result_value'' = '''' then picked_input_params[19]->''item_json''->>''default_value''
        else picked_result_params[19]->>''result_value''
   end as data19
  ,case when picked_result_params[20]->>''result_value'' is null or picked_result_params[20]->>''result_value'' = '''' then picked_input_params[20]->''item_json''->>''default_value''
        else picked_result_params[20]->>''result_value''
   end as data20
  ,case when picked_result_params[21]->>''result_value'' is null or picked_result_params[21]->>''result_value'' = '''' then picked_input_params[21]->''item_json''->>''default_value''
        else picked_result_params[21]->>''result_value''
   end as data21
  ,case when picked_result_params[22]->>''result_value'' is null or picked_result_params[22]->>''result_value'' = '''' then picked_input_params[22]->''item_json''->>''default_value''
        else picked_result_params[22]->>''result_value''
   end as data22
  ,case when picked_result_params[23]->>''result_value'' is null or picked_result_params[23]->>''result_value'' = '''' then picked_input_params[23]->''item_json''->>''default_value''
        else picked_result_params[23]->>''result_value''
   end as data23
  ,case when picked_result_params[24]->>''result_value'' is null or picked_result_params[24]->>''result_value'' = '''' then picked_input_params[24]->''item_json''->>''default_value''
        else picked_result_params[24]->>''result_value''
   end as data24
  ,case when picked_result_params[25]->>''result_value'' is null or picked_result_params[25]->>''result_value'' = '''' then picked_input_params[25]->''item_json''->>''default_value''
        else picked_result_params[25]->>''result_value''
   end as data25
  ,case when picked_result_params[26]->>''result_value'' is null or picked_result_params[26]->>''result_value'' = '''' then picked_input_params[26]->''item_json''->>''default_value''
        else picked_result_params[26]->>''result_value''
   end as data26
  ,case when picked_result_params[27]->>''result_value'' is null or picked_result_params[27]->>''result_value'' = '''' then picked_input_params[27]->''item_json''->>''default_value''
        else picked_result_params[27]->>''result_value''
   end as data27
  ,case when picked_result_params[28]->>''result_value'' is null or picked_result_params[28]->>''result_value'' = '''' then picked_input_params[28]->''item_json''->>''default_value''
        else picked_result_params[28]->>''result_value''
   end as data28
  ,case when picked_result_params[29]->>''result_value'' is null or picked_result_params[29]->>''result_value'' = '''' then picked_input_params[29]->''item_json''->>''default_value''
        else picked_result_params[29]->>''result_value''
   end as data29
  ,case when picked_result_params[30]->>''result_value'' is null or picked_result_params[30]->>''result_value'' = '''' then picked_input_params[30]->''item_json''->>''default_value''
        else picked_result_params[30]->>''result_value''
   end as data30
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data11", "data_name": "データ11", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data11", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data12", "data_name": "データ12", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data12", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data13", "data_name": "データ13", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data13", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data14", "data_name": "データ14", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data14", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data15", "data_name": "データ15", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data15", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data16", "data_name": "データ16", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data16", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data17", "data_name": "データ17", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data17", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data18", "data_name": "データ18", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data18", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data19", "data_name": "データ19", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data19", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data20", "data_name": "データ20", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data20", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data21", "data_name": "データ21", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data21", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data22", "data_name": "データ22", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data22", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data23", "data_name": "データ23", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data23", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data24", "data_name": "データ24", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data24", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data25", "data_name": "データ25", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data25", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data26", "data_name": "データ26", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data26", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data27", "data_name": "データ27", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data27", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data28", "data_name": "データ28", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data28", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data29", "data_name": "データ29", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data29", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data30", "data_name": "データ30", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data30", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント テキスト　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (85, 'with input_params_expand as
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date
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
  ,unescape_html(regexp_replace(case when picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then picked_input_params[1]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 1 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[1]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data1
  ,unescape_html(regexp_replace(case when picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[2]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 2 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[2]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data2
  ,unescape_html(regexp_replace(case when picked_result_params[3]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[3]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 3 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[3]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data3
 ,unescape_html(regexp_replace(case when picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then picked_input_params[4]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 4 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[4]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data4
,unescape_html(regexp_replace(case when picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then picked_input_params[5]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 5 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[5]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data5
,unescape_html(regexp_replace(case when picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then picked_input_params[6]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 6 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[6]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data6
 ,unescape_html(regexp_replace(case when picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then picked_input_params[7]->''item_json''->>''default_value'' else 
(case when  (picked_input_params [ 7 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[7]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data7
 ,unescape_html(regexp_replace(case when picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then picked_input_params[8]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 8 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[8]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data8
,unescape_html(regexp_replace(case when picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then picked_input_params[9]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 9 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[9]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data9
,unescape_html(regexp_replace(case when picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then picked_input_params[10]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 10 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then substring(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'') from 1 for length(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', ''#b'', ''g'')) - 2) else picked_result_params[10]->>''result_value'' end)
end, ''<[^>]*>'', '''', ''g'')) as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント テキストエリア　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (86, 'with input_params_expand as
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''2''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
	,category_cd
  ,category_name
  ,sub_category_cd
  ,sub_category_name
--   ,reg_staff_name
   ,reg_date
--   ,up_staff_name
--   ,up_date

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

  ,(picked_input_params[1]->''item_json''->''values''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_path'' as data1_pic1_file_path
  ,(picked_input_params[1]->''item_json''->''values''->1)->>''name'' as data1_pic2_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_name'' as data1_pic2_file_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_path'' as data1_pic2_file_path
  ,(picked_input_params[1]->''item_json''->''values''->2)->>''name'' as data1_pic3_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_name'' as data1_pic3_file_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_path'' as data1_pic3_file_path
  ,(picked_input_params[1]->''item_json''->''values''->3)->>''name'' as data1_pic4_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_name'' as data1_pic4_file_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_path'' as data1_pic4_file_path
  ,(picked_input_params[1]->''item_json''->''values''->4)->>''name'' as data1_pic5_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_name'' as data1_pic5_file_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_path'' as data1_pic5_file_path
  ,(picked_input_params[1]->''item_json''->''values''->5)->>''name'' as data1_pic6_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_name'' as data1_pic6_file_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_path'' as data1_pic6_file_path
  ,(picked_input_params[1]->''item_json''->''values''->6)->>''name'' as data1_pic7_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_name'' as data1_pic7_file_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_path'' as data1_pic7_file_path
  ,(picked_input_params[1]->''item_json''->''values''->7)->>''name'' as data1_pic8_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_name'' as data1_pic8_file_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_path'' as data1_pic8_file_path
  ,(picked_input_params[1]->''item_json''->''values''->8)->>''name'' as data1_pic9_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_name'' as data1_pic9_file_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_path'' as data1_pic9_file_path

  ,(picked_input_params[2]->''item_json''->''values''->0)->>''name'' as data2_pic1_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_name'' as data2_pic1_file_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_path'' as data2_pic1_file_path
  ,(picked_input_params[2]->''item_json''->''values''->1)->>''name'' as data2_pic2_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_name'' as data2_pic2_file_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_path'' as data2_pic2_file_path
  ,(picked_input_params[2]->''item_json''->''values''->2)->>''name'' as data2_pic3_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_name'' as data2_pic3_file_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_path'' as data2_pic3_file_path
  ,(picked_input_params[2]->''item_json''->''values''->3)->>''name'' as data2_pic4_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_name'' as data2_pic4_file_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_path'' as data2_pic4_file_path
  ,(picked_input_params[2]->''item_json''->''values''->4)->>''name'' as data2_pic5_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_name'' as data2_pic5_file_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_path'' as data2_pic5_file_path
  ,(picked_input_params[2]->''item_json''->''values''->5)->>''name'' as data2_pic6_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_name'' as data2_pic6_file_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_path'' as data2_pic6_file_path
  ,(picked_input_params[2]->''item_json''->''values''->6)->>''name'' as data2_pic7_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_name'' as data2_pic7_file_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_path'' as data2_pic7_file_path
  ,(picked_input_params[2]->''item_json''->''values''->7)->>''name'' as data2_pic8_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_name'' as data2_pic8_file_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_path'' as data2_pic8_file_path
  ,(picked_input_params[2]->''item_json''->''values''->8)->>''name'' as data2_pic9_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_name'' as data2_pic9_file_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_path'' as data2_pic9_file_path

  ,(picked_input_params[3]->''item_json''->''values''->0)->>''name'' as data3_pic1_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_name'' as data3_pic1_file_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_path'' as data3_pic1_file_path
  ,(picked_input_params[3]->''item_json''->''values''->1)->>''name'' as data3_pic2_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_name'' as data3_pic2_file_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_path'' as data3_pic2_file_path
  ,(picked_input_params[3]->''item_json''->''values''->2)->>''name'' as data3_pic3_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_name'' as data3_pic3_file_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_path'' as data3_pic3_file_path
  ,(picked_input_params[3]->''item_json''->''values''->3)->>''name'' as data3_pic4_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_name'' as data3_pic4_file_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_path'' as data3_pic4_file_path
  ,(picked_input_params[3]->''item_json''->''values''->4)->>''name'' as data3_pic5_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_name'' as data3_pic5_file_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_path'' as data3_pic5_file_path
  ,(picked_input_params[3]->''item_json''->''values''->5)->>''name'' as data3_pic6_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_name'' as data3_pic6_file_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_path'' as data3_pic6_file_path
  ,(picked_input_params[3]->''item_json''->''values''->6)->>''name'' as data3_pic7_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_name'' as data3_pic7_file_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_path'' as data3_pic7_file_path
  ,(picked_input_params[3]->''item_json''->''values''->7)->>''name'' as data3_pic8_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_name'' as data3_pic8_file_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_path'' as data3_pic8_file_path
  ,(picked_input_params[3]->''item_json''->''values''->8)->>''name'' as data3_pic9_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_name'' as data3_pic9_file_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_path'' as data3_pic9_file_path

  ,(picked_input_params[4]->''item_json''->''values''->0)->>''name'' as data4_pic1_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_name'' as data4_pic1_file_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_path'' as data4_pic1_file_path
  ,(picked_input_params[4]->''item_json''->''values''->1)->>''name'' as data4_pic2_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_name'' as data4_pic2_file_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_path'' as data4_pic2_file_path
  ,(picked_input_params[4]->''item_json''->''values''->2)->>''name'' as data4_pic3_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_name'' as data4_pic3_file_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_path'' as data4_pic3_file_path
  ,(picked_input_params[4]->''item_json''->''values''->3)->>''name'' as data4_pic4_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_name'' as data4_pic4_file_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_path'' as data4_pic4_file_path
  ,(picked_input_params[4]->''item_json''->''values''->4)->>''name'' as data4_pic5_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_name'' as data4_pic5_file_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_path'' as data4_pic5_file_path
  ,(picked_input_params[4]->''item_json''->''values''->5)->>''name'' as data4_pic6_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_name'' as data4_pic6_file_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_path'' as data4_pic6_file_path
  ,(picked_input_params[4]->''item_json''->''values''->6)->>''name'' as data4_pic7_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_name'' as data4_pic7_file_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_path'' as data4_pic7_file_path
  ,(picked_input_params[4]->''item_json''->''values''->7)->>''name'' as data4_pic8_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_name'' as data4_pic8_file_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_path'' as data4_pic8_file_path
  ,(picked_input_params[4]->''item_json''->''values''->8)->>''name'' as data4_pic9_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_name'' as data4_pic9_file_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_path'' as data4_pic9_file_path

  ,(picked_input_params[5]->''item_json''->''values''->0)->>''name'' as data5_pic1_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_name'' as data5_pic1_file_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_path'' as data5_pic1_file_path
  ,(picked_input_params[5]->''item_json''->''values''->1)->>''name'' as data5_pic2_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_name'' as data5_pic2_file_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_path'' as data5_pic2_file_path
  ,(picked_input_params[5]->''item_json''->''values''->2)->>''name'' as data5_pic3_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_name'' as data5_pic3_file_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_path'' as data5_pic3_file_path
  ,(picked_input_params[5]->''item_json''->''values''->3)->>''name'' as data5_pic4_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_name'' as data5_pic4_file_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_path'' as data5_pic4_file_path
  ,(picked_input_params[5]->''item_json''->''values''->4)->>''name'' as data5_pic5_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_name'' as data5_pic5_file_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_path'' as data5_pic5_file_path
  ,(picked_input_params[5]->''item_json''->''values''->5)->>''name'' as data5_pic6_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_name'' as data5_pic6_file_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_path'' as data5_pic6_file_path
  ,(picked_input_params[5]->''item_json''->''values''->6)->>''name'' as data5_pic7_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_name'' as data5_pic7_file_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_path'' as data5_pic7_file_path
  ,(picked_input_params[5]->''item_json''->''values''->7)->>''name'' as data5_pic8_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_name'' as data5_pic8_file_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_path'' as data5_pic8_file_path
  ,(picked_input_params[5]->''item_json''->''values''->8)->>''name'' as data5_pic9_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_name'' as data5_pic9_file_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_path'' as data5_pic9_file_path

  ,(picked_input_params[6]->''item_json''->''values''->0)->>''name'' as data6_pic1_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_name'' as data6_pic1_file_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_path'' as data6_pic1_file_path
  ,(picked_input_params[6]->''item_json''->''values''->1)->>''name'' as data6_pic2_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_name'' as data6_pic2_file_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_path'' as data6_pic2_file_path
  ,(picked_input_params[6]->''item_json''->''values''->2)->>''name'' as data6_pic3_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_name'' as data6_pic3_file_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_path'' as data6_pic3_file_path
  ,(picked_input_params[6]->''item_json''->''values''->3)->>''name'' as data6_pic4_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_name'' as data6_pic4_file_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_path'' as data6_pic4_file_path
  ,(picked_input_params[6]->''item_json''->''values''->4)->>''name'' as data6_pic5_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_name'' as data6_pic5_file_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_path'' as data6_pic5_file_path
  ,(picked_input_params[6]->''item_json''->''values''->5)->>''name'' as data6_pic6_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_name'' as data6_pic6_file_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_path'' as data6_pic6_file_path
  ,(picked_input_params[6]->''item_json''->''values''->6)->>''name'' as data6_pic7_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_name'' as data6_pic7_file_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_path'' as data6_pic7_file_path
  ,(picked_input_params[6]->''item_json''->''values''->7)->>''name'' as data6_pic8_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_name'' as data6_pic8_file_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_path'' as data6_pic8_file_path
  ,(picked_input_params[6]->''item_json''->''values''->8)->>''name'' as data6_pic9_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_name'' as data6_pic9_file_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_path'' as data6_pic9_file_path

  ,(picked_input_params[7]->''item_json''->''values''->0)->>''name'' as data7_pic1_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_name'' as data7_pic1_file_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_path'' as data7_pic1_file_path
  ,(picked_input_params[7]->''item_json''->''values''->1)->>''name'' as data7_pic2_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_name'' as data7_pic2_file_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_path'' as data7_pic2_file_path
  ,(picked_input_params[7]->''item_json''->''values''->2)->>''name'' as data7_pic3_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_name'' as data7_pic3_file_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_path'' as data7_pic3_file_path
  ,(picked_input_params[7]->''item_json''->''values''->3)->>''name'' as data7_pic4_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_name'' as data7_pic4_file_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_path'' as data7_pic4_file_path
  ,(picked_input_params[7]->''item_json''->''values''->4)->>''name'' as data7_pic5_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_name'' as data7_pic5_file_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_path'' as data7_pic5_file_path
  ,(picked_input_params[7]->''item_json''->''values''->5)->>''name'' as data7_pic6_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_name'' as data7_pic6_file_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_path'' as data7_pic6_file_path
  ,(picked_input_params[7]->''item_json''->''values''->6)->>''name'' as data7_pic7_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_name'' as data7_pic7_file_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_path'' as data7_pic7_file_path
  ,(picked_input_params[7]->''item_json''->''values''->7)->>''name'' as data7_pic8_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_name'' as data7_pic8_file_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_path'' as data7_pic8_file_path
  ,(picked_input_params[7]->''item_json''->''values''->8)->>''name'' as data7_pic9_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_name'' as data7_pic9_file_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_path'' as data7_pic9_file_path

  ,(picked_input_params[8]->''item_json''->''values''->0)->>''name'' as data8_pic1_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_name'' as data8_pic1_file_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_path'' as data8_pic1_file_path
  ,(picked_input_params[8]->''item_json''->''values''->1)->>''name'' as data8_pic2_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_name'' as data8_pic2_file_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_path'' as data8_pic2_file_path
  ,(picked_input_params[8]->''item_json''->''values''->2)->>''name'' as data8_pic3_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_name'' as data8_pic3_file_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_path'' as data8_pic3_file_path
  ,(picked_input_params[8]->''item_json''->''values''->3)->>''name'' as data8_pic4_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_name'' as data8_pic4_file_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_path'' as data8_pic4_file_path
  ,(picked_input_params[8]->''item_json''->''values''->4)->>''name'' as data8_pic5_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_name'' as data8_pic5_file_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_path'' as data8_pic5_file_path
  ,(picked_input_params[8]->''item_json''->''values''->5)->>''name'' as data8_pic6_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_name'' as data8_pic6_file_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_path'' as data8_pic6_file_path
  ,(picked_input_params[8]->''item_json''->''values''->6)->>''name'' as data8_pic7_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_name'' as data8_pic7_file_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_path'' as data8_pic7_file_path
  ,(picked_input_params[8]->''item_json''->''values''->7)->>''name'' as data8_pic8_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_name'' as data8_pic8_file_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_path'' as data8_pic8_file_path
  ,(picked_input_params[8]->''item_json''->''values''->8)->>''name'' as data8_pic9_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_name'' as data8_pic9_file_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_path'' as data8_pic9_file_path

  ,(picked_input_params[9]->''item_json''->''values''->0)->>''name'' as data9_pic1_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_name'' as data9_pic1_file_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_path'' as data9_pic1_file_path
  ,(picked_input_params[9]->''item_json''->''values''->1)->>''name'' as data9_pic2_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_name'' as data9_pic2_file_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_path'' as data9_pic2_file_path
  ,(picked_input_params[9]->''item_json''->''values''->2)->>''name'' as data9_pic3_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_name'' as data9_pic3_file_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_path'' as data9_pic3_file_path
  ,(picked_input_params[9]->''item_json''->''values''->3)->>''name'' as data9_pic4_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_name'' as data9_pic4_file_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_path'' as data9_pic4_file_path
  ,(picked_input_params[9]->''item_json''->''values''->4)->>''name'' as data9_pic5_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_name'' as data9_pic5_file_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_path'' as data9_pic5_file_path
  ,(picked_input_params[9]->''item_json''->''values''->5)->>''name'' as data9_pic6_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_name'' as data9_pic6_file_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_path'' as data9_pic6_file_path
  ,(picked_input_params[9]->''item_json''->''values''->6)->>''name'' as data9_pic7_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_name'' as data9_pic7_file_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_path'' as data9_pic7_file_path
  ,(picked_input_params[9]->''item_json''->''values''->7)->>''name'' as data9_pic8_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_name'' as data9_pic8_file_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_path'' as data9_pic8_file_path
  ,(picked_input_params[9]->''item_json''->''values''->8)->>''name'' as data9_pic9_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_name'' as data9_pic9_file_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_path'' as data9_pic9_file_path

  ,(picked_input_params[10]->''item_json''->''values''->0)->>''name'' as data10_pic1_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_name'' as data10_pic1_file_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_path'' as data10_pic1_file_path
  ,(picked_input_params[10]->''item_json''->''values''->1)->>''name'' as data10_pic2_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_name'' as data10_pic2_file_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_path'' as data10_pic2_file_path
  ,(picked_input_params[10]->''item_json''->''values''->2)->>''name'' as data10_pic3_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_name'' as data10_pic3_file_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_path'' as data10_pic3_file_path
  ,(picked_input_params[10]->''item_json''->''values''->3)->>''name'' as data10_pic4_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_name'' as data10_pic4_file_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_path'' as data10_pic4_file_path
  ,(picked_input_params[10]->''item_json''->''values''->4)->>''name'' as data10_pic5_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_name'' as data10_pic5_file_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_path'' as data10_pic5_file_path
  ,(picked_input_params[10]->''item_json''->''values''->5)->>''name'' as data10_pic6_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_name'' as data10_pic6_file_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_path'' as data10_pic6_file_path
  ,(picked_input_params[10]->''item_json''->''values''->6)->>''name'' as data10_pic7_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_name'' as data10_pic7_file_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_path'' as data10_pic7_file_path
  ,(picked_input_params[10]->''item_json''->''values''->7)->>''name'' as data10_pic8_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_name'' as data10_pic8_file_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_path'' as data10_pic8_file_path
  ,(picked_input_params[10]->''item_json''->''values''->8)->>''name'' as data10_pic9_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_name'' as data10_pic9_file_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_path'' as data10_pic9_file_path
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic1_file_name", "data_name": "データ1 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "データ1 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic2_file_name", "data_name": "データ1 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic2_file_path", "data_name": "データ1 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic3_file_name", "data_name": "データ1 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic3_file_path", "data_name": "データ1 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic4_file_name", "data_name": "データ1 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic4_file_path", "data_name": "データ1 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic5_file_name", "data_name": "データ1 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic5_file_path", "data_name": "データ1 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic6_file_name", "data_name": "データ1 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic6_file_path", "data_name": "データ1 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic7_file_name", "data_name": "データ1 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic7_file_path", "data_name": "データ1 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic8_file_name", "data_name": "データ1 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic8_file_path", "data_name": "データ1 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic9_file_name", "data_name": "データ1 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic9_file_path", "data_name": "データ1 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic1_file_name", "data_name": "データ2 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic1_file_path", "data_name": "データ2 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic2_file_name", "data_name": "データ2 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic2_file_path", "data_name": "データ2 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic3_file_name", "data_name": "データ2 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic3_file_path", "data_name": "データ2 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic4_file_name", "data_name": "データ2 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic4_file_path", "data_name": "データ2 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic5_file_name", "data_name": "データ2 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic5_file_path", "data_name": "データ2 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic6_file_name", "data_name": "データ2 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic6_file_path", "data_name": "データ2 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic7_file_name", "data_name": "データ2 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic7_file_path", "data_name": "データ2 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic8_file_name", "data_name": "データ2 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic8_file_path", "data_name": "データ2 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic9_file_name", "data_name": "データ2 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic9_file_path", "data_name": "データ2 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic1_file_name", "data_name": "データ3 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic1_file_path", "data_name": "データ3 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic2_file_name", "data_name": "データ3 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic2_file_path", "data_name": "データ3 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic3_file_name", "data_name": "データ3 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic3_file_path", "data_name": "データ3 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic4_file_name", "data_name": "データ3 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic4_file_path", "data_name": "データ3 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic5_file_name", "data_name": "データ3 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic5_file_path", "data_name": "データ3 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic6_file_name", "data_name": "データ3 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic6_file_path", "data_name": "データ3 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic7_file_name", "data_name": "データ3 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic7_file_path", "data_name": "データ3 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic8_file_name", "data_name": "データ3 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic8_file_path", "data_name": "データ3 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic9_file_name", "data_name": "データ3 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic9_file_path", "data_name": "データ3 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic1_file_name", "data_name": "データ4 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic1_file_path", "data_name": "データ4 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic2_file_name", "data_name": "データ4 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic2_file_path", "data_name": "データ4 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic3_file_name", "data_name": "データ4 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic3_file_path", "data_name": "データ4 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic4_file_name", "data_name": "データ4 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic4_file_path", "data_name": "データ4 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic5_file_name", "data_name": "データ4 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic5_file_path", "data_name": "データ4 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic6_file_name", "data_name": "データ4 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic6_file_path", "data_name": "データ4 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic7_file_name", "data_name": "データ4 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic7_file_path", "data_name": "データ4 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic8_file_name", "data_name": "データ4 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic8_file_path", "data_name": "データ4 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic9_file_name", "data_name": "データ4 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic9_file_path", "data_name": "データ4 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic1_file_name", "data_name": "データ5 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "graph.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic1_file_path", "data_name": "データ5 患者イベント(画像)1Image", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic2_file_name", "data_name": "データ5 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic2_file_path", "data_name": "データ5 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic3_file_name", "data_name": "データ5 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic3_file_path", "data_name": "データ5 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic4_file_name", "data_name": "データ5 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic4_file_path", "data_name": "データ5 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic5_file_name", "data_name": "データ5 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic5_file_path", "data_name": "データ5 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic6_file_name", "data_name": "データ5 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic6_file_path", "data_name": "データ5 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic7_file_name", "data_name": "データ5 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic7_file_path", "data_name": "データ5 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic8_file_name", "data_name": "データ5 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic8_file_path", "data_name": "データ5 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic9_file_name", "data_name": "データ5 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic9_file_path", "data_name": "データ5 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic1_file_name", "data_name": "データ6 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic1_file_path", "data_name": "データ6 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic2_file_name", "data_name": "データ6 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic2_file_path", "data_name": "データ6 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic3_file_name", "data_name": "データ6 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic3_file_path", "data_name": "データ6 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic4_file_name", "data_name": "データ6 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic4_file_path", "data_name": "データ6 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic5_file_name", "data_name": "データ6 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic5_file_path", "data_name": "データ6 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic6_file_name", "data_name": "データ6 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic6_file_path", "data_name": "データ6 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic7_file_name", "data_name": "データ6 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic7_file_path", "data_name": "データ6 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic8_file_name", "data_name": "データ6 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic8_file_path", "data_name": "データ6 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic9_file_name", "data_name": "データ6 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic9_file_path", "data_name": "データ6 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic1_file_name", "data_name": "データ7 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic1_file_path", "data_name": "データ7 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic2_file_name", "data_name": "データ7 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic2_file_path", "data_name": "データ7 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic3_file_name", "data_name": "データ7 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic3_file_path", "data_name": "データ7 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic4_file_name", "data_name": "データ7 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic4_file_path", "data_name": "データ7 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic5_file_name", "data_name": "データ7 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic5_file_path", "data_name": "データ7 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic6_file_name", "data_name": "データ7 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic6_file_path", "data_name": "データ7 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic7_file_name", "data_name": "データ7 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic7_file_path", "data_name": "データ7 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic8_file_name", "data_name": "データ7 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic8_file_path", "data_name": "データ7 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic9_file_name", "data_name": "データ7 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic9_file_path", "data_name": "データ7 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic1_file_name", "data_name": "データ8 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic1_file_path", "data_name": "データ8 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic2_file_name", "data_name": "データ8 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic2_file_path", "data_name": "データ8 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic3_file_name", "data_name": "データ8 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic3_file_path", "data_name": "データ8 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic4_file_name", "data_name": "データ8 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic4_file_path", "data_name": "データ8 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic5_file_name", "data_name": "データ8 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic5_file_path", "data_name": "データ8 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic6_file_name", "data_name": "データ8 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic6_file_path", "data_name": "データ8 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic7_file_name", "data_name": "データ8 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic7_file_path", "data_name": "データ8 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic8_file_name", "data_name": "データ8 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic8_file_path", "data_name": "データ8 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic9_file_name", "data_name": "データ8 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic9_file_path", "data_name": "データ8 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic1_file_name", "data_name": "データ9 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic1_file_path", "data_name": "データ9 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic2_file_name", "data_name": "データ9 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic2_file_path", "data_name": "データ9 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic3_file_name", "data_name": "データ9 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic3_file_path", "data_name": "データ9 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic4_file_name", "data_name": "データ9 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic4_file_path", "data_name": "データ9 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic5_file_name", "data_name": "データ9 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic5_file_path", "data_name": "データ9 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic6_file_name", "data_name": "データ9 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic6_file_path", "data_name": "データ9 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic7_file_name", "data_name": "データ9 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic7_file_path", "data_name": "データ9 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic8_file_name", "data_name": "データ9 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic8_file_path", "data_name": "データ9 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic9_file_name", "data_name": "データ9 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic9_file_path", "data_name": "データ9 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic1_file_name", "data_name": "データ10 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic1_file_path", "data_name": "データ10 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic2_file_name", "data_name": "データ10 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic2_file_path", "data_name": "データ10 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic3_file_name", "data_name": "データ10 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic3_file_path", "data_name": "データ10 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic4_file_name", "data_name": "データ10 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic4_file_path", "data_name": "データ10 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic5_file_name", "data_name": "データ10 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic5_file_path", "data_name": "データ10 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic6_file_name", "data_name": "データ10 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic6_file_path", "data_name": "データ10 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic7_file_name", "data_name": "データ10 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic7_file_path", "data_name": "データ10 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic8_file_name", "data_name": "データ10 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic8_file_path", "data_name": "データ10 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic9_file_name", "data_name": "データ10 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic9_file_path", "data_name": "データ10 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 11]}', '患者情報：患者イベント 画像　@patId @fromDate @toDate使用', '2021-08-26 00:00:22', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (87, 'with input_params_expand as
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
    input_param->>''format_class'' = ''3''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
	,category_cd
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date

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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント リスト　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (88, 'with input_params_expand as
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
    input_param->>''format_class'' = ''4''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date

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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "選択内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント ラジオボタン　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (89, 'with input_params_expand as
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
    input_param->>''format_class'' = ''5''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date

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
ORDER BY event_start_date, reg_date  
;', 2, '[{"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 日付　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (90, 'with input_params_expand as
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
    input_param->>''format_class'' = ''6''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date

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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''name'', '''')
  ) as data1_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''score'', '''')
  ) as data1_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''name'', '''')
  ) as data2_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''score'', '''')
  ) as data2_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''name'', '''')
  ) as data3_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''score'', '''')
  ) as data3_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''name'', '''')
  ) as data4_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''score'', '''')
  ) as data4_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''name'', '''')
  ) as data5_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''score'', '''')
  ) as data5_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''name'', '''')
  ) as data6_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''score'', '''')
  ) as data6_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''name'', '''')
  ) as data7_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''score'', '''')
  ) as data7_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''name'', '''')
  ) as data8_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''score'', '''')
  ) as data8_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''name'', '''')
  ) as data9_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''score'', '''')
  ) as data9_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''name'', '''')
  ) as data10_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''score'', '''')
  ) as data10_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''name'', '''')
  ) as data11_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''score'', '''')
  ) as data11_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''name'', '''')
  ) as data12_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''score'', '''')
  ) as data12_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''name'', '''')
  ) as data13_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''score'', '''')
  ) as data13_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''name'', '''')
  ) as data14_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''score'', '''')
  ) as data14_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''name'', '''')
  ) as data15_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''score'', '''')
  ) as data15_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''name'', '''')
  ) as data16_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''score'', '''')
  ) as data16_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''name'', '''')
  ) as data17_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''score'', '''')
  ) as data17_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''name'', '''')
  ) as data18_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''score'', '''')
  ) as data18_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''name'', '''')
  ) as data19_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''score'', '''')
  ) as data19_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''name'', '''')
  ) as data20_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''score'', '''')
  ) as data20_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''name'', '''')
  ) as data21_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''score'', '''')
  ) as data21_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''name'', '''')
  ) as data22_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''score'', '''')
  ) as data22_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''name'', '''')
  ) as data23_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''score'', '''')
  ) as data23_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''name'', '''')
  ) as data24_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''score'', '''')
  ) as data24_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''name'', '''')
  ) as data25_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''score'', '''')
  ) as data25_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''name'', '''')
  ) as data26_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''score'', '''')
  ) as data26_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''name'', '''')
  ) as data27_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''score'', '''')
  ) as data27_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''name'', '''')
  ) as data28_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''score'', '''')
  ) as data28_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''name'', '''')
  ) as data29_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''score'', '''')
  ) as data29_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''name'', '''')
  ) as data30_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''score'', '''')
  ) as data30_score
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;',2,'[{"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]','1','{"applications": [1]}','{"classes": [1, 2, 3, 9, 10, 11]}','患者情報：患者イベント チェック　@patId @fromDate @toDate使用', '2021-08-26 13:50:14.000', CURRENT_TIMESTAMP,null);

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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
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
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name1", "data_name": "データ1 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name2", "data_name": "データ1 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name3", "data_name": "データ1 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name4", "data_name": "データ1 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name5", "data_name": "データ1 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name6", "data_name": "データ1 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name7", "data_name": "データ1 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name8", "data_name": "データ1 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name9", "data_name": "データ1 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name10", "data_name": "データ1 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name1", "data_name": "データ2 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name2", "data_name": "データ2 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name3", "data_name": "データ2 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name4", "data_name": "データ2 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name5", "data_name": "データ2 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name6", "data_name": "データ2 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name7", "data_name": "データ2 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name8", "data_name": "データ2 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name9", "data_name": "データ2 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name10", "data_name": "データ2 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name1", "data_name": "データ3 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name2", "data_name": "データ3 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name3", "data_name": "データ3 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name4", "data_name": "データ3 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name5", "data_name": "データ3 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name6", "data_name": "データ3 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name7", "data_name": "データ3 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name8", "data_name": "データ3 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name9", "data_name": "データ3 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name10", "data_name": "データ3 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name1", "data_name": "データ4 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name2", "data_name": "データ4 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name3", "data_name": "データ4 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name4", "data_name": "データ4 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name5", "data_name": "データ4 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name6", "data_name": "データ4 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name7", "data_name": "データ4 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name8", "data_name": "データ4 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name9", "data_name": "データ4 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name10", "data_name": "データ4 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name1", "data_name": "データ5 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name2", "data_name": "データ5 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name3", "data_name": "データ5 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name4", "data_name": "データ5 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name5", "data_name": "データ5 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name6", "data_name": "データ5 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name7", "data_name": "データ5 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name8", "data_name": "データ5 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name9", "data_name": "データ5 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name10", "data_name": "データ5 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 添付ファイル　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (92, 'with input_params_expand as
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
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
    ,score_total
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
    input_param->>''format_class'' = ''8''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo_plus.reg_date
--   ,up_staff_name
--   ,pe_basicinfo_plus.up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name

  ,rtrim(picked_result_params[1]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[1]->''result_value''->>''unit'', ''''), '' '') as data1
  ,rtrim(picked_result_params[2]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[2]->''result_value''->>''unit'', ''''), '' '') as data2
  ,rtrim(picked_result_params[3]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[3]->''result_value''->>''unit'', ''''), '' '') as data3
  ,rtrim(picked_result_params[4]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[4]->''result_value''->>''unit'', ''''), '' '') as data4
  ,rtrim(picked_result_params[5]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[5]->''result_value''->>''unit'', ''''), '' '') as data5

  , score_total || '''' as score_total
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "スコア説明", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500 点", "can_calc": "0", "data_code": "score_total", "data_name": "スコア合計", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "score_total", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント スコア計算　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (93, 'WITH DATA AS (

with input_params_expand as
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,pat_event.ord_no
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_cd
	,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,treat_date
    ,case
      when rst_dialysis_state <> ''0'' then rst_kur_name
      else ind_kur_name
    end as linked_kur_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_bed_name
      else ind_bed_name
    end as linked_bed_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_treatment_name
      else ind_treatment_name
    end as linked_treatment_name
  from
    pat_event
    left outer join (select * from ord_main where is_del = ''0'') as ord_main
      on pat_event.ord_no = ord_main.ord_no
  where
    pat_event.is_del = ''0''
    and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''9''
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
  pe_basicinfo_plus.ord_no as ord_no_t
  ,pe_array_agg.pat_event_cd
   ,to_timestamp(event_start_date||event_start_time, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||event_end_time, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo_plus.reg_date
--   ,up_staff_name
--   ,pe_basicinfo_plus.up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''
  end as is_linked
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' as linked_treat_date
  ,case
    when linked_kur_name is null or linked_kur_name = ''''
      then kbt.kur_name
      else linked_kur_name
    end
  ,case
    when linked_bed_name is null or linked_bed_name = ''''
      then kbt.bed_name
      else linked_bed_name
    end
  ,case
    when linked_treatment_name is null or linked_treatment_name = ''''
      then kbt.treatment_name
      else linked_treatment_name
    end
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
  left outer join (select
                       om.ord_no,
                       mk.kur_name as kur_name,
                       mb.bed_name as bed_name,
                       mt.treatment_name as treatment_name
                     from
                       ord_main as om
                       left outer join mst_kur mk on om.ind_kur_cd = mk.kur_cd
                       left outer join mst_bed mb on om.ind_bed_cd = mb.bed_cd
                       left outer join mst_treatment mt on om.ind_treatment_cd = mt.treatment_cd
                     where om.is_del = ''0'') as kbt
               on pe_basicinfo_plus.ord_no = kbt.ord_no
ORDER BY event_start_date, reg_date
  ),
time_info AS (
  WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
      pat_id in (@patId)
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')

     and
       is_del = ''0''
  ), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
  ), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
  ), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
  )
  select
  b.ord_no,
  b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
  CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS ind_end_date_time
  , b.rst_start_date
  , b.rst_end_date
  from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
  *
FROM
  DATA
  LEFT JOIN
  time_info
  on
  DATA.ord_no_t = time_info.ord_no
;', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(治療実績リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "is_linked", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treat_date", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_kur_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_bed_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treatment_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_detail", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 治療実績リンク　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (94, 'with input_params_expand as
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
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,pat_event.facility_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_cd
	,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,notice_start_date
    ,notice_end_date
  from
    pat_event
    left outer join (select * from bbs_info where is_del = ''0'' and is_disp = ''1'') as bbs_info
      on pat_event.bbs_ctl_no = bbs_info.bbs_ctl_no
  where
    pat_event.is_del = ''0''
    and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''10''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
	,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo_plus.reg_date
--   ,up_staff_name
--   ,pe_basicinfo_plus.up_date
  ,(select mk.kind_name from mst_bbs_kind as mk where mk.kind_no::TEXT = ((picked_input_params[1]->>''item_json'')::jsonb)::jsonb->>''kind_no'' and mk.facility_cd = pe_basicinfo_plus.facility_cd) as field_name
  ,case
    when notice_start_date is null then ''掲示板掲載なし''
    else ''掲示板掲載あり''
  end as is_linked
  ,to_char(to_date(notice_start_date, ''YYYYMMDD''), ''YYYY/MM/DD'') || '' ～ '' || to_char(to_date(notice_end_date, ''YYYYMMDD''), ''YYYY/MM/DD'') as bbs_notice_term
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "掲示板カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(掲示板リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "is_linked", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "bbs_notice_term", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 掲示板リンク @patId @fromDate @toDate 使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (68, 'with input_params_expand as
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
    and use_type = 2 and ord_no = @ordNo
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
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
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
    and use_type = 2 and ord_no = @ordNo
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
    input_param->>''format_class'' = ''5''
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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
;', 2, '[{"preview": "実施日付", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data1", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data2", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data3", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data4", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data5", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data6", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data7", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data8", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data9", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "DateTime", "conv_table": [], "data_class": "日付", "field_name": "data10", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 日付 @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (63, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''2''
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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

  ,(picked_result_params[1]->''result_value''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_path'' as data1_pic1_file_path
  ,(picked_result_params[1]->''result_value''->1)->>''name'' as data1_pic2_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_name'' as data1_pic2_file_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_path'' as data1_pic2_file_path
  ,(picked_result_params[1]->''result_value''->2)->>''name'' as data1_pic3_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_name'' as data1_pic3_file_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_path'' as data1_pic3_file_path
  ,(picked_result_params[1]->''result_value''->3)->>''name'' as data1_pic4_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_name'' as data1_pic4_file_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_path'' as data1_pic4_file_path
  ,(picked_result_params[1]->''result_value''->4)->>''name'' as data1_pic5_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_name'' as data1_pic5_file_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_path'' as data1_pic5_file_path
  ,(picked_result_params[1]->''result_value''->5)->>''name'' as data1_pic6_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_name'' as data1_pic6_file_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_path'' as data1_pic6_file_path
  ,(picked_result_params[1]->''result_value''->6)->>''name'' as data1_pic7_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_name'' as data1_pic7_file_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_path'' as data1_pic7_file_path
  ,(picked_result_params[1]->''result_value''->7)->>''name'' as data1_pic8_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_name'' as data1_pic8_file_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_path'' as data1_pic8_file_path
  ,(picked_result_params[1]->''result_value''->8)->>''name'' as data1_pic9_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_name'' as data1_pic9_file_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_path'' as data1_pic9_file_path

  ,(picked_result_params[2]->''result_value''->0)->>''name'' as data2_pic1_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_name'' as data2_pic1_file_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_path'' as data2_pic1_file_path
  ,(picked_result_params[2]->''result_value''->1)->>''name'' as data2_pic2_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_name'' as data2_pic2_file_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_path'' as data2_pic2_file_path
  ,(picked_result_params[2]->''result_value''->2)->>''name'' as data2_pic3_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_name'' as data2_pic3_file_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_path'' as data2_pic3_file_path
  ,(picked_result_params[2]->''result_value''->3)->>''name'' as data2_pic4_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_name'' as data2_pic4_file_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_path'' as data2_pic4_file_path
  ,(picked_result_params[2]->''result_value''->4)->>''name'' as data2_pic5_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_name'' as data2_pic5_file_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_path'' as data2_pic5_file_path
  ,(picked_result_params[2]->''result_value''->5)->>''name'' as data2_pic6_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_name'' as data2_pic6_file_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_path'' as data2_pic6_file_path
  ,(picked_result_params[2]->''result_value''->6)->>''name'' as data2_pic7_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_name'' as data2_pic7_file_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_path'' as data2_pic7_file_path
  ,(picked_result_params[2]->''result_value''->7)->>''name'' as data2_pic8_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_name'' as data2_pic8_file_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_path'' as data2_pic8_file_path
  ,(picked_result_params[2]->''result_value''->8)->>''name'' as data2_pic9_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_name'' as data2_pic9_file_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_path'' as data2_pic9_file_path

  ,(picked_result_params[3]->''result_value''->0)->>''name'' as data3_pic1_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_name'' as data3_pic1_file_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_path'' as data3_pic1_file_path
  ,(picked_result_params[3]->''result_value''->1)->>''name'' as data3_pic2_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_name'' as data3_pic2_file_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_path'' as data3_pic2_file_path
  ,(picked_result_params[3]->''result_value''->2)->>''name'' as data3_pic3_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_name'' as data3_pic3_file_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_path'' as data3_pic3_file_path
  ,(picked_result_params[3]->''result_value''->3)->>''name'' as data3_pic4_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_name'' as data3_pic4_file_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_path'' as data3_pic4_file_path
  ,(picked_result_params[3]->''result_value''->4)->>''name'' as data3_pic5_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_name'' as data3_pic5_file_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_path'' as data3_pic5_file_path
  ,(picked_result_params[3]->''result_value''->5)->>''name'' as data3_pic6_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_name'' as data3_pic6_file_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_path'' as data3_pic6_file_path
  ,(picked_result_params[3]->''result_value''->6)->>''name'' as data3_pic7_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_name'' as data3_pic7_file_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_path'' as data3_pic7_file_path
  ,(picked_result_params[3]->''result_value''->7)->>''name'' as data3_pic8_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_name'' as data3_pic8_file_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_path'' as data3_pic8_file_path
  ,(picked_result_params[3]->''result_value''->8)->>''name'' as data3_pic9_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_name'' as data3_pic9_file_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_path'' as data3_pic9_file_path

  ,(picked_result_params[4]->''result_value''->0)->>''name'' as data4_pic1_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_name'' as data4_pic1_file_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_path'' as data4_pic1_file_path
  ,(picked_result_params[4]->''result_value''->1)->>''name'' as data4_pic2_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_name'' as data4_pic2_file_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_path'' as data4_pic2_file_path
  ,(picked_result_params[4]->''result_value''->2)->>''name'' as data4_pic3_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_name'' as data4_pic3_file_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_path'' as data4_pic3_file_path
  ,(picked_result_params[4]->''result_value''->3)->>''name'' as data4_pic4_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_name'' as data4_pic4_file_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_path'' as data4_pic4_file_path
  ,(picked_result_params[4]->''result_value''->4)->>''name'' as data4_pic5_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_name'' as data4_pic5_file_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_path'' as data4_pic5_file_path
  ,(picked_result_params[4]->''result_value''->5)->>''name'' as data4_pic6_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_name'' as data4_pic6_file_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_path'' as data4_pic6_file_path
  ,(picked_result_params[4]->''result_value''->6)->>''name'' as data4_pic7_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_name'' as data4_pic7_file_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_path'' as data4_pic7_file_path
  ,(picked_result_params[4]->''result_value''->7)->>''name'' as data4_pic8_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_name'' as data4_pic8_file_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_path'' as data4_pic8_file_path
  ,(picked_result_params[4]->''result_value''->8)->>''name'' as data4_pic9_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_name'' as data4_pic9_file_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_path'' as data4_pic9_file_path

  ,(picked_result_params[5]->''result_value''->0)->>''name'' as data5_pic1_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_name'' as data5_pic1_file_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_path'' as data5_pic1_file_path
  ,(picked_result_params[5]->''result_value''->1)->>''name'' as data5_pic2_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_name'' as data5_pic2_file_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_path'' as data5_pic2_file_path
  ,(picked_result_params[5]->''result_value''->2)->>''name'' as data5_pic3_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_name'' as data5_pic3_file_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_path'' as data5_pic3_file_path
  ,(picked_result_params[5]->''result_value''->3)->>''name'' as data5_pic4_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_name'' as data5_pic4_file_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_path'' as data5_pic4_file_path
  ,(picked_result_params[5]->''result_value''->4)->>''name'' as data5_pic5_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_name'' as data5_pic5_file_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_path'' as data5_pic5_file_path
  ,(picked_result_params[5]->''result_value''->5)->>''name'' as data5_pic6_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_name'' as data5_pic6_file_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_path'' as data5_pic6_file_path
  ,(picked_result_params[5]->''result_value''->6)->>''name'' as data5_pic7_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_name'' as data5_pic7_file_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_path'' as data5_pic7_file_path
  ,(picked_result_params[5]->''result_value''->7)->>''name'' as data5_pic8_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_name'' as data5_pic8_file_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_path'' as data5_pic8_file_path
  ,(picked_result_params[5]->''result_value''->8)->>''name'' as data5_pic9_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_name'' as data5_pic9_file_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_path'' as data5_pic9_file_path

  ,(picked_result_params[6]->''result_value''->0)->>''name'' as data6_pic1_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_name'' as data6_pic1_file_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_path'' as data6_pic1_file_path
  ,(picked_result_params[6]->''result_value''->1)->>''name'' as data6_pic2_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_name'' as data6_pic2_file_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_path'' as data6_pic2_file_path
  ,(picked_result_params[6]->''result_value''->2)->>''name'' as data6_pic3_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_name'' as data6_pic3_file_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_path'' as data6_pic3_file_path
  ,(picked_result_params[6]->''result_value''->3)->>''name'' as data6_pic4_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_name'' as data6_pic4_file_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_path'' as data6_pic4_file_path
  ,(picked_result_params[6]->''result_value''->4)->>''name'' as data6_pic5_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_name'' as data6_pic5_file_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_path'' as data6_pic5_file_path
  ,(picked_result_params[6]->''result_value''->5)->>''name'' as data6_pic6_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_name'' as data6_pic6_file_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_path'' as data6_pic6_file_path
  ,(picked_result_params[6]->''result_value''->6)->>''name'' as data6_pic7_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_name'' as data6_pic7_file_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_path'' as data6_pic7_file_path
  ,(picked_result_params[6]->''result_value''->7)->>''name'' as data6_pic8_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_name'' as data6_pic8_file_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_path'' as data6_pic8_file_path
  ,(picked_result_params[6]->''result_value''->8)->>''name'' as data6_pic9_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_name'' as data6_pic9_file_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_path'' as data6_pic9_file_path

  ,(picked_result_params[7]->''result_value''->0)->>''name'' as data7_pic1_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_name'' as data7_pic1_file_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_path'' as data7_pic1_file_path
  ,(picked_result_params[7]->''result_value''->1)->>''name'' as data7_pic2_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_name'' as data7_pic2_file_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_path'' as data7_pic2_file_path
  ,(picked_result_params[7]->''result_value''->2)->>''name'' as data7_pic3_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_name'' as data7_pic3_file_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_path'' as data7_pic3_file_path
  ,(picked_result_params[7]->''result_value''->3)->>''name'' as data7_pic4_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_name'' as data7_pic4_file_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_path'' as data7_pic4_file_path
  ,(picked_result_params[7]->''result_value''->4)->>''name'' as data7_pic5_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_name'' as data7_pic5_file_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_path'' as data7_pic5_file_path
  ,(picked_result_params[7]->''result_value''->5)->>''name'' as data7_pic6_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_name'' as data7_pic6_file_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_path'' as data7_pic6_file_path
  ,(picked_result_params[7]->''result_value''->6)->>''name'' as data7_pic7_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_name'' as data7_pic7_file_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_path'' as data7_pic7_file_path
  ,(picked_result_params[7]->''result_value''->7)->>''name'' as data7_pic8_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_name'' as data7_pic8_file_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_path'' as data7_pic8_file_path
  ,(picked_result_params[7]->''result_value''->8)->>''name'' as data7_pic9_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_name'' as data7_pic9_file_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_path'' as data7_pic9_file_path

  ,(picked_result_params[8]->''result_value''->0)->>''name'' as data8_pic1_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_name'' as data8_pic1_file_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_path'' as data8_pic1_file_path
  ,(picked_result_params[8]->''result_value''->1)->>''name'' as data8_pic2_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_name'' as data8_pic2_file_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_path'' as data8_pic2_file_path
  ,(picked_result_params[8]->''result_value''->2)->>''name'' as data8_pic3_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_name'' as data8_pic3_file_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_path'' as data8_pic3_file_path
  ,(picked_result_params[8]->''result_value''->3)->>''name'' as data8_pic4_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_name'' as data8_pic4_file_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_path'' as data8_pic4_file_path
  ,(picked_result_params[8]->''result_value''->4)->>''name'' as data8_pic5_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_name'' as data8_pic5_file_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_path'' as data8_pic5_file_path
  ,(picked_result_params[8]->''result_value''->5)->>''name'' as data8_pic6_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_name'' as data8_pic6_file_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_path'' as data8_pic6_file_path
  ,(picked_result_params[8]->''result_value''->6)->>''name'' as data8_pic7_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_name'' as data8_pic7_file_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_path'' as data8_pic7_file_path
  ,(picked_result_params[8]->''result_value''->7)->>''name'' as data8_pic8_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_name'' as data8_pic8_file_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_path'' as data8_pic8_file_path
  ,(picked_result_params[8]->''result_value''->8)->>''name'' as data8_pic9_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_name'' as data8_pic9_file_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_path'' as data8_pic9_file_path

  ,(picked_result_params[9]->''result_value''->0)->>''name'' as data9_pic1_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_name'' as data9_pic1_file_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_path'' as data9_pic1_file_path
  ,(picked_result_params[9]->''result_value''->1)->>''name'' as data9_pic2_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_name'' as data9_pic2_file_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_path'' as data9_pic2_file_path
  ,(picked_result_params[9]->''result_value''->2)->>''name'' as data9_pic3_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_name'' as data9_pic3_file_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_path'' as data9_pic3_file_path
  ,(picked_result_params[9]->''result_value''->3)->>''name'' as data9_pic4_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_name'' as data9_pic4_file_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_path'' as data9_pic4_file_path
  ,(picked_result_params[9]->''result_value''->4)->>''name'' as data9_pic5_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_name'' as data9_pic5_file_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_path'' as data9_pic5_file_path
  ,(picked_result_params[9]->''result_value''->5)->>''name'' as data9_pic6_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_name'' as data9_pic6_file_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_path'' as data9_pic6_file_path
  ,(picked_result_params[9]->''result_value''->6)->>''name'' as data9_pic7_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_name'' as data9_pic7_file_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_path'' as data9_pic7_file_path
  ,(picked_result_params[9]->''result_value''->7)->>''name'' as data9_pic8_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_name'' as data9_pic8_file_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_path'' as data9_pic8_file_path
  ,(picked_result_params[9]->''result_value''->8)->>''name'' as data9_pic9_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_name'' as data9_pic9_file_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_path'' as data9_pic9_file_path

  ,(picked_result_params[10]->''result_value''->0)->>''name'' as data10_pic1_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_name'' as data10_pic1_file_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_path'' as data10_pic1_file_path
  ,(picked_result_params[10]->''result_value''->1)->>''name'' as data10_pic2_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_name'' as data10_pic2_file_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_path'' as data10_pic2_file_path
  ,(picked_result_params[10]->''result_value''->2)->>''name'' as data10_pic3_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_name'' as data10_pic3_file_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_path'' as data10_pic3_file_path
  ,(picked_result_params[10]->''result_value''->3)->>''name'' as data10_pic4_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_name'' as data10_pic4_file_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_path'' as data10_pic4_file_path
  ,(picked_result_params[10]->''result_value''->4)->>''name'' as data10_pic5_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_name'' as data10_pic5_file_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_path'' as data10_pic5_file_path
  ,(picked_result_params[10]->''result_value''->5)->>''name'' as data10_pic6_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_name'' as data10_pic6_file_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_path'' as data10_pic6_file_path
  ,(picked_result_params[10]->''result_value''->6)->>''name'' as data10_pic7_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_name'' as data10_pic7_file_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_path'' as data10_pic7_file_path
  ,(picked_result_params[10]->''result_value''->7)->>''name'' as data10_pic8_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_name'' as data10_pic8_file_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_path'' as data10_pic8_file_path
  ,(picked_result_params[10]->''result_value''->8)->>''name'' as data10_pic9_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_name'' as data10_pic9_file_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_path'' as data10_pic9_file_path

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	order  by   event_date, reg_date
;', 2, '[{"preview": "レポート関連画像", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic1_name", "data_name": "データ1 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic1_file_name", "data_name": "データ1 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic1_file_path", "data_name": "データ1 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic2_name", "data_name": "データ1 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic2_file_name", "data_name": "データ1 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic2_file_path", "data_name": "データ1 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic3_name", "data_name": "データ1 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic3_file_name", "data_name": "データ1 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic3_file_path", "data_name": "データ1 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic4_name", "data_name": "データ1 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic4_file_name", "data_name": "データ1 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic4_file_path", "data_name": "データ1 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic5_name", "data_name": "データ1 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic5_file_name", "data_name": "データ1 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic5_file_path", "data_name": "データ1 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic6_name", "data_name": "データ1 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic6_file_name", "data_name": "データ1 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic6_file_path", "data_name": "データ1 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic7_name", "data_name": "データ1 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic7_file_name", "data_name": "データ1 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic7_file_path", "data_name": "データ1 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic8_name", "data_name": "データ1 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic8_file_name", "data_name": "データ1 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic8_file_path", "data_name": "データ1 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic9_name", "data_name": "データ1 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic9_file_name", "data_name": "データ1 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic9_file_path", "data_name": "データ1 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data1_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic1_name", "data_name": "データ2 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic1_file_name", "data_name": "データ2 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic1_file_path", "data_name": "データ2 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic2_name", "data_name": "データ2 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic2_file_name", "data_name": "データ2 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic2_file_path", "data_name": "データ2 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic3_name", "data_name": "データ2 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic3_file_name", "data_name": "データ2 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic3_file_path", "data_name": "データ2 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic4_name", "data_name": "データ2 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic4_file_name", "data_name": "データ2 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic4_file_path", "data_name": "データ2 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic5_name", "data_name": "データ2 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic5_file_name", "data_name": "データ2 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic5_file_path", "data_name": "データ2 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic6_name", "data_name": "データ2 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic6_file_name", "data_name": "データ2 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic6_file_path", "data_name": "データ2 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic7_name", "data_name": "データ2 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic7_file_name", "data_name": "データ2 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic7_file_path", "data_name": "データ2 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic8_name", "data_name": "データ2 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic8_file_name", "data_name": "データ2 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic8_file_path", "data_name": "データ2 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic9_name", "data_name": "データ2 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic9_file_name", "data_name": "データ2 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic9_file_path", "data_name": "データ2 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data2_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic1_name", "data_name": "データ3 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic1_file_name", "data_name": "データ3 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic1_file_path", "data_name": "データ3 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic2_name", "data_name": "データ3 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic2_file_name", "data_name": "データ3 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic2_file_path", "data_name": "データ3 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic3_name", "data_name": "データ3 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic3_file_name", "data_name": "データ3 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic3_file_path", "data_name": "データ3 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic4_name", "data_name": "データ3 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic4_file_name", "data_name": "データ3 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic4_file_path", "data_name": "データ3 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic5_name", "data_name": "データ3 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic5_file_name", "data_name": "データ3 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic5_file_path", "data_name": "データ3 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic6_name", "data_name": "データ3 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic6_file_name", "data_name": "データ3 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic6_file_path", "data_name": "データ3 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic7_name", "data_name": "データ3 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic7_file_name", "data_name": "データ3 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic7_file_path", "data_name": "データ3 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic8_name", "data_name": "データ3 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic8_file_name", "data_name": "データ3 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic8_file_path", "data_name": "データ3 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic9_name", "data_name": "データ3 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic9_file_name", "data_name": "データ3 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic9_file_path", "data_name": "データ3 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data3_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic1_name", "data_name": "データ4 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic1_file_name", "data_name": "データ4 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic1_file_path", "data_name": "データ4 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic2_name", "data_name": "データ4 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic2_file_name", "data_name": "データ4 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic2_file_path", "data_name": "データ4 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic3_name", "data_name": "データ4 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic3_file_name", "data_name": "データ4 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic3_file_path", "data_name": "データ4 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic4_name", "data_name": "データ4 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic4_file_name", "data_name": "データ4 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic4_file_path", "data_name": "データ4 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic5_name", "data_name": "データ4 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic5_file_name", "data_name": "データ4 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic5_file_path", "data_name": "データ4 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic6_name", "data_name": "データ4 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic6_file_name", "data_name": "データ4 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic6_file_path", "data_name": "データ4 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic7_name", "data_name": "データ4 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic7_file_name", "data_name": "データ4 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic7_file_path", "data_name": "データ4 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic8_name", "data_name": "データ4 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic8_file_name", "data_name": "データ4 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic8_file_path", "data_name": "データ4 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic9_name", "data_name": "データ4 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic9_file_name", "data_name": "データ4 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic9_file_path", "data_name": "データ4 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data4_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic1_name", "data_name": "データ5 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic1_file_name", "data_name": "データ5 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic1_file_path", "data_name": "データ5 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic2_name", "data_name": "データ5 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic2_file_name", "data_name": "データ5 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic2_file_path", "data_name": "データ5 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic3_name", "data_name": "データ5 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic3_file_name", "data_name": "データ5 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic3_file_path", "data_name": "データ5 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic4_name", "data_name": "データ5 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic4_file_name", "data_name": "データ5 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic4_file_path", "data_name": "データ5 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic5_name", "data_name": "データ5 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic5_file_name", "data_name": "データ5 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic5_file_path", "data_name": "データ5 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic6_name", "data_name": "データ5 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic6_file_name", "data_name": "データ5 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic6_file_path", "data_name": "データ5 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic7_name", "data_name": "データ5 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic7_file_name", "data_name": "データ5 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic7_file_path", "data_name": "データ5 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic8_name", "data_name": "データ5 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic8_file_name", "data_name": "データ5 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic8_file_path", "data_name": "データ5 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic9_name", "data_name": "データ5 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic9_file_name", "data_name": "データ5 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic9_file_path", "data_name": "データ5 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data5_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic1_name", "data_name": "データ6 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic1_file_name", "data_name": "データ6 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic1_file_path", "data_name": "データ6 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic2_name", "data_name": "データ6 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic2_file_name", "data_name": "データ6 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic2_file_path", "data_name": "データ6 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic3_name", "data_name": "データ6 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic3_file_name", "data_name": "データ6 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic3_file_path", "data_name": "データ6 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic4_name", "data_name": "データ6 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic4_file_name", "data_name": "データ6 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic4_file_path", "data_name": "データ6 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic5_name", "data_name": "データ6 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic5_file_name", "data_name": "データ6 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic5_file_path", "data_name": "データ6 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic6_name", "data_name": "データ6 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic6_file_name", "data_name": "データ6 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic6_file_path", "data_name": "データ6 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic7_name", "data_name": "データ6 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic7_file_name", "data_name": "データ6 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic7_file_path", "data_name": "データ6 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic8_name", "data_name": "データ6 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic8_file_name", "data_name": "データ6 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic8_file_path", "data_name": "データ6 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic9_name", "data_name": "データ6 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic9_file_name", "data_name": "データ6 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic9_file_path", "data_name": "データ6 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data6_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic1_name", "data_name": "データ7 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic1_file_name", "data_name": "データ7 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic1_file_path", "data_name": "データ7 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic2_name", "data_name": "データ7 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic2_file_name", "data_name": "データ7 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic2_file_path", "data_name": "データ7 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic3_name", "data_name": "データ7 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic3_file_name", "data_name": "データ7 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic3_file_path", "data_name": "データ7 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic4_name", "data_name": "データ7 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic4_file_name", "data_name": "データ7 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic4_file_path", "data_name": "データ7 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic5_name", "data_name": "データ7 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic5_file_name", "data_name": "データ7 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic5_file_path", "data_name": "データ7 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic6_name", "data_name": "データ7 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic6_file_name", "data_name": "データ7 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic6_file_path", "data_name": "データ7 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic7_name", "data_name": "データ7 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic7_file_name", "data_name": "データ7 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic7_file_path", "data_name": "データ7 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic8_name", "data_name": "データ7 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic8_file_name", "data_name": "データ7 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic8_file_path", "data_name": "データ7 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic9_name", "data_name": "データ7 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic9_file_name", "data_name": "データ7 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic9_file_path", "data_name": "データ7 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data7_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic1_name", "data_name": "データ8 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic1_file_name", "data_name": "データ8 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic1_file_path", "data_name": "データ8 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic2_name", "data_name": "データ8 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic2_file_name", "data_name": "データ8 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic2_file_path", "data_name": "データ8 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic3_name", "data_name": "データ8 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic3_file_name", "data_name": "データ8 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic3_file_path", "data_name": "データ8 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic4_name", "data_name": "データ8 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic4_file_name", "data_name": "データ8 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic4_file_path", "data_name": "データ8 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic5_name", "data_name": "データ8 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic5_file_name", "data_name": "データ8 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic5_file_path", "data_name": "データ8 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic6_name", "data_name": "データ8 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic6_file_name", "data_name": "データ8 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic6_file_path", "data_name": "データ8 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic7_name", "data_name": "データ8 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic7_file_name", "data_name": "データ8 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic7_file_path", "data_name": "データ8 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic8_name", "data_name": "データ8 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic8_file_name", "data_name": "データ8 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic8_file_path", "data_name": "データ8 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic9_name", "data_name": "データ8 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic9_file_name", "data_name": "データ8 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic9_file_path", "data_name": "データ8 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data8_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic1_name", "data_name": "データ9 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic1_file_name", "data_name": "データ9 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic1_file_path", "data_name": "データ9 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic2_name", "data_name": "データ9 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic2_file_name", "data_name": "データ9 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic2_file_path", "data_name": "データ9 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic3_name", "data_name": "データ9 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic3_file_name", "data_name": "データ9 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic3_file_path", "data_name": "データ9 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic4_name", "data_name": "データ9 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic4_file_name", "data_name": "データ9 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic4_file_path", "data_name": "データ9 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic5_name", "data_name": "データ9 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic5_file_name", "data_name": "データ9 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic5_file_path", "data_name": "データ9 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic6_name", "data_name": "データ9 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic6_file_name", "data_name": "データ9 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic6_file_path", "data_name": "データ9 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic7_name", "data_name": "データ9 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic7_file_name", "data_name": "データ9 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic7_file_path", "data_name": "データ9 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic8_name", "data_name": "データ9 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic8_file_name", "data_name": "データ9 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic8_file_path", "data_name": "データ9 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic9_name", "data_name": "データ9 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic9_file_name", "data_name": "データ9 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic9_file_path", "data_name": "データ9 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data9_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic1_name", "data_name": "データ10 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic1_file_name", "data_name": "データ10 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic1_file_path", "data_name": "データ10 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic2_name", "data_name": "データ10 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic2_file_name", "data_name": "データ10 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic2_file_path", "data_name": "データ10 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic3_name", "data_name": "データ10 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic3_file_name", "data_name": "データ10 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic3_file_path", "data_name": "データ10 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic4_name", "data_name": "データ10 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic4_file_name", "data_name": "データ10 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic4_file_path", "data_name": "データ10 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic5_name", "data_name": "データ10 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic5_file_name", "data_name": "データ10 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic5_file_path", "data_name": "データ10 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic6_name", "data_name": "データ10 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic6_file_name", "data_name": "データ10 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic6_file_path", "data_name": "データ10 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic7_name", "data_name": "データ10 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic7_file_name", "data_name": "データ10 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic7_file_path", "data_name": "データ10 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic8_name", "data_name": "データ10 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic8_file_name", "data_name": "データ10 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic8_file_path", "data_name": "データ10 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic9_name", "data_name": "データ10 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic9_file_name", "data_name": "データ10 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic9_file_path", "data_name": "データ10 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像(患者指定)", "field_name": "data10_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  画像 @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (69, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''5''
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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
	order  by   event_date, reg_date
;', 2, '[{"preview": "実施日付", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施日付", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data1", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data2", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data3", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data4", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data5", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data6", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data7", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data8", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data9", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "DateTime", "conv_table": [], "data_class": "日付(患者指定)", "field_name": "data10", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  日付 @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (71, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''6''
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''name'', '''')
  ) as data1_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''score'', '''')
  ) as data1_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''name'', '''')
  ) as data2_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''score'', '''')
  ) as data2_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''name'', '''')
  ) as data3_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''score'', '''')
  ) as data3_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''name'', '''')
  ) as data4_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''score'', '''')
  ) as data4_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''name'', '''')
  ) as data5_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''score'', '''')
  ) as data5_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''name'', '''')
  ) as data6_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''score'', '''')
  ) as data6_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''name'', '''')
  ) as data7_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''score'', '''')
  ) as data7_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''name'', '''')
  ) as data8_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''score'', '''')
  ) as data8_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''name'', '''')
  ) as data9_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''score'', '''')
  ) as data9_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''name'', '''')
  ) as data10_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''score'', '''')
  ) as data10_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''name'', '''')
  ) as data11_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''score'', '''')
  ) as data11_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''name'', '''')
  ) as data12_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''score'', '''')
  ) as data12_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''name'', '''')
  ) as data13_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''score'', '''')
  ) as data13_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''name'', '''')
  ) as data14_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''score'', '''')
  ) as data14_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''name'', '''')
  ) as data15_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''score'', '''')
  ) as data15_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''name'', '''')
  ) as data16_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''score'', '''')
  ) as data16_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''name'', '''')
  ) as data17_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''score'', '''')
  ) as data17_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''name'', '''')
  ) as data18_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''score'', '''')
  ) as data18_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''name'', '''')
  ) as data19_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''score'', '''')
  ) as data19_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''name'', '''')
  ) as data20_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''score'', '''')
  ) as data20_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''name'', '''')
  ) as data21_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''score'', '''')
  ) as data21_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''name'', '''')
  ) as data22_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''score'', '''')
  ) as data22_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''name'', '''')
  ) as data23_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''score'', '''')
  ) as data23_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''name'', '''')
  ) as data24_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''score'', '''')
  ) as data24_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''name'', '''')
  ) as data25_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''score'', '''')
  ) as data25_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''name'', '''')
  ) as data26_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''score'', '''')
  ) as data26_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''name'', '''')
  ) as data27_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''score'', '''')
  ) as data27_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''name'', '''')
  ) as data28_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''score'', '''')
  ) as data28_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''name'', '''')
  ) as data29_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''score'', '''')
  ) as data29_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''name'', '''')
  ) as data30_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''score'', '''')
  ) as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	order  by   event_date, reg_date
;', 2, '[{"preview": "チェック内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data11_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data12_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data13_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data14_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data15_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data16_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data17_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data18_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data19_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data20_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data21_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data22_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data23_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data24_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data25_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data26_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data27_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data28_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data29_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data30_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data1_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data2_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data3_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data4_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data5_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data6_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data7_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data8_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data9_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data10_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data10_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data11_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data11_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data12_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data12_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data13_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data13_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data14_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data14_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data15_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data15_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data16_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data16_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data17_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data17_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data18_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data18_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data19_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data19_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data20_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data20_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data21_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data21_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data22_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data22_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data23_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data23_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data24_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data24_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data25_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data25_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data26_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data26_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data27_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data27_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data28_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data28_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data29_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data29_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data30_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック(患者指定)", "field_name": "data30_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  チェック @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (73, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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
	order  by   event_date, reg_date
;', 2, '[{"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name1", "data_name": "データ1 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path1", "data_name": "データ1 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name2", "data_name": "データ1 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path2", "data_name": "データ1 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name3", "data_name": "データ1 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path3", "data_name": "データ1 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name4", "data_name": "データ1 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path4", "data_name": "データ1 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name5", "data_name": "データ1 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path5", "data_name": "データ1 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name6", "data_name": "データ1 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path6", "data_name": "データ1 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name7", "data_name": "データ1 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path7", "data_name": "データ1 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name8", "data_name": "データ1 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path8", "data_name": "データ1 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name9", "data_name": "データ1 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path9", "data_name": "データ1 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name10", "data_name": "データ1 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path10", "data_name": "データ1 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data1_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name1", "data_name": "データ2 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path1", "data_name": "データ2 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name2", "data_name": "データ2 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path2", "data_name": "データ2 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name3", "data_name": "データ2 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path3", "data_name": "データ2 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name4", "data_name": "データ2 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path4", "data_name": "データ2 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name5", "data_name": "データ2 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path5", "data_name": "データ2 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name6", "data_name": "データ2 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path6", "data_name": "データ2 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name7", "data_name": "データ2 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path7", "data_name": "データ2 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name8", "data_name": "データ2 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path8", "data_name": "データ2 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name9", "data_name": "データ2 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path9", "data_name": "データ2 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name10", "data_name": "データ2 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path10", "data_name": "データ2 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data2_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name1", "data_name": "データ3 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path1", "data_name": "データ3 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name2", "data_name": "データ3 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path2", "data_name": "データ3 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name3", "data_name": "データ3 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path3", "data_name": "データ3 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name4", "data_name": "データ3 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path4", "data_name": "データ3 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name5", "data_name": "データ3 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path5", "data_name": "データ3 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name6", "data_name": "データ3 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path6", "data_name": "データ3 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name7", "data_name": "データ3 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path7", "data_name": "データ3 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name8", "data_name": "データ3 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path8", "data_name": "データ3 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name9", "data_name": "データ3 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path9", "data_name": "データ3 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name10", "data_name": "データ3 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path10", "data_name": "データ3 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data3_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name1", "data_name": "データ4 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path1", "data_name": "データ4 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name2", "data_name": "データ4 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path2", "data_name": "データ4 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name3", "data_name": "データ4 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path3", "data_name": "データ4 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name4", "data_name": "データ4 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path4", "data_name": "データ4 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name5", "data_name": "データ4 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path5", "data_name": "データ4 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name6", "data_name": "データ4 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path6", "data_name": "データ4 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name7", "data_name": "データ4 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path7", "data_name": "データ4 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name8", "data_name": "データ4 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path8", "data_name": "データ4 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name9", "data_name": "データ4 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path9", "data_name": "データ4 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name10", "data_name": "データ4 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path10", "data_name": "データ4 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data4_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name1", "data_name": "データ5 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path1", "data_name": "データ5 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name2", "data_name": "データ5 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path2", "data_name": "データ5 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name3", "data_name": "データ5 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path3", "data_name": "データ5 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name4", "data_name": "データ5 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path4", "data_name": "データ5 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name5", "data_name": "データ5 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path5", "data_name": "データ5 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name6", "data_name": "データ5 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path6", "data_name": "データ5 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name7", "data_name": "データ5 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path7", "data_name": "データ5 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name8", "data_name": "データ5 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path8", "data_name": "データ5 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name9", "data_name": "データ5 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path9", "data_name": "データ5 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name10", "data_name": "データ5 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path10", "data_name": "データ5 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル(患者指定)", "field_name": "data5_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  添付ファイル @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (77, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo_plus as
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
    ,score_total
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''8''
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
  ,to_date(event_start_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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

  ,rtrim(picked_result_params[1]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[1]->''result_value''->>''unit'', ''''), '' '') as data1
  ,rtrim(picked_result_params[2]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[2]->''result_value''->>''unit'', ''''), '' '') as data2
  ,rtrim(picked_result_params[3]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[3]->''result_value''->>''unit'', ''''), '' '') as data3
  ,rtrim(picked_result_params[4]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[4]->''result_value''->>''unit'', ''''), '' '') as data4
  ,rtrim(picked_result_params[5]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[5]->''result_value''->>''unit'', ''''), '' '') as data5

  , score_total || '''' as score_total

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
	order  by   event_date, reg_date
;', 2, '[{"preview": "スコア説明", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "data5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500 点", "can_calc": "0", "data_code": "score_total", "data_name": "スコア合計", "data_type": "string", "conv_table": [], "data_class": "スコア計算(患者指定)", "field_name": "score_total", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  スコア計算 @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (79, 'WITH DATA AS (


	with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo_plus as
(
  select
    ord_main.ord_no as ord_no_t
		,pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,treat_date
    ,case
      when rst_dialysis_state <> ''0'' then rst_kur_name
      else ind_kur_name
    end as linked_kur_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_bed_name
      else ind_bed_name
    end as linked_bed_name
    ,case
      when rst_dialysis_state <> ''0'' then rst_treatment_name
      else ind_treatment_name
    end as linked_treatment_name
  from
    pat_event
    left outer join (select * from ord_main where is_del = ''0'') as ord_main
      on pat_event.ord_no = ord_main.ord_no
  where
    pat_event.is_del = ''0''
    and use_type = 2 and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''9''
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
	ord_no_t
	,pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''
  end as is_linked
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' as linked_treat_date
  ,linked_kur_name
  ,linked_bed_name
  ,linked_treatment_name
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')
    || ''(''
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
	order  by   event_date, reg_date
	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			 ord_no = @ordNo
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ord_no
', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "治療実績リンク有無", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "is_linked", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_treat_date", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_kur_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_bed_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_treatment_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "治療実績リンク(患者指定)", "field_name": "linked_detail", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  治療実績リンク @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (81, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,to_date(bbs_info.notice_start_date, ''YYYYMMDD'') as notice_start_date
    ,to_date(bbs_info.notice_end_date, ''YYYYMMDD'') as notice_end_date
  from
    pat_event
    left outer join bbs_info
      on pat_event.bbs_ctl_no = bbs_info.bbs_ctl_no and bbs_info.is_del = ''0'' and bbs_info.is_disp = ''1''
  where
    pat_event.is_del = ''0''
    and use_type = 2 and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''10''
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
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when notice_start_date is null then ''掲示板掲載なし''
    else ''掲示板掲載あり''
  end as is_linked
  ,to_char(notice_start_date, ''YYYY/MM/DD'') || '' ～ '' || to_char(notice_end_date, ''YYYY/MM/DD'') as bbs_notice_term

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
	order  by   event_date, reg_date
;', 2, '[{"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク(患者指定)", "field_name": "field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "掲示板掲載有無", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク(患者指定)", "field_name": "is_linked", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク(患者指定)", "field_name": "bbs_notice_term", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  掲示板リンク @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (227, 'with input_params_expand as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo_plus as
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
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
  ,to_date(event_start_date, ''YYYYMMDD'') as event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
	order  by   event_start_date, reg_date
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報(患者指定)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票  共通情報(患者指定) @patId @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);

