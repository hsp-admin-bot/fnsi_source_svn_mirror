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
;' WHERE "sql_cd" = 73;