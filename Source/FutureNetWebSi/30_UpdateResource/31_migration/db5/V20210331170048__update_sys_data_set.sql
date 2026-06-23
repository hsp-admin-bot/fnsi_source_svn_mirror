UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
;' WHERE "sql_cd" = 63;