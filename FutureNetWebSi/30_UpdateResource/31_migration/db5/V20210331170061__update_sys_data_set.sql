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
;' WHERE "sql_cd" = 76;