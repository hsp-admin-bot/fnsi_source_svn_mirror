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
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
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
    and pat_event.pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
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
  ,to_char(to_date(notice_start_date, ''YYYYMMDD''), ''YYYY/MM/DD'') || '' ～ '' || to_char(to_date(notice_end_date, ''YYYYMMDD''), ''YYYY/MM/DD'') as bbs_notice_term

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
;',
detail = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "category_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "sub_category_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "field_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(掲示板リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "is_linked", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "bbs_notice_term", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' 
where sql_cd = '94'