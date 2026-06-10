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
;' WHERE "sql_cd" = 70;