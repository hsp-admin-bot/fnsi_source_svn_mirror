DELETE FROM "ntss"."sys_data_set" where sql_cd in (84);
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
    and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
ORDER BY event_start_date desc, reg_date desc
;', 2, '[{"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data11", "data_name": "データ11", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data11", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data12", "data_name": "データ12", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data12", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data13", "data_name": "データ13", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data13", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data14", "data_name": "データ14", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data14", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data15", "data_name": "データ15", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data15", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data16", "data_name": "データ16", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data16", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data17", "data_name": "データ17", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data17", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data18", "data_name": "データ18", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data18", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data19", "data_name": "データ19", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data19", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data20", "data_name": "データ20", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data20", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data21", "data_name": "データ21", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data21", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data22", "data_name": "データ22", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data22", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data23", "data_name": "データ23", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data23", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data24", "data_name": "データ24", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data24", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data25", "data_name": "データ25", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data25", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data26", "data_name": "データ26", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data26", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data27", "data_name": "データ27", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data27", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data28", "data_name": "データ28", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data28", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data29", "data_name": "データ29", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data29", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data30", "data_name": "データ30", "data_type": "string", "conv_table": [], "data_class": "テキスト", "field_name": "data30", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者イベント テキスト @patId @facilityCd @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
