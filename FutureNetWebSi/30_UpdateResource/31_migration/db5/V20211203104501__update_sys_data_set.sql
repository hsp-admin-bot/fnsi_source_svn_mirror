update ntss.sys_data_set set sql = 'with input_params_expand as
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
  ,pe_basicinfo_plus.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo_plus.reg_date
  ,up_staff_name
  ,pe_basicinfo_plus.up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when notice_start_date is null then ''掲示板掲載なし''
    else ''掲示板掲載あり''
  end as is_linked
  ,to_char(to_date(notice_start_date, ''YYYYMMDD''), ''YYYY/MM/DD'') || '' ～ '' || to_char(to_date(notice_end_date, ''YYYYMMDD''), ''YYYY/MM/DD'') as bbs_notice_term

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
		inner JOIN mst_pat_event_sub_category es on  pe_basicinfo_plus.sub_category_name = es.sub_category_name
		AND ((@subCategoryCd
::text is not null and @subCategoryCd
::text  <> '''') and (es.sub_category_cd = @subCategoryCd
))
;', db_class = 2, detail = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "category_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "sub_category_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(掲示板リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "is_linked", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "bbs_notice_term", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', can_repeat = '1', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '患者情報：患者イベント 掲示板リンク @patId @fromDate @toDate 使用', reg_date = '2021/08/26 13:50:14', up_date = '2021/08/26 13:50:14', pre_sql_info = null where sql_cd = 94;
update ntss.sys_data_set set sql = 'with input_params_expand as
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
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,pe_basicinfo_plus.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo_plus.reg_date
  ,up_staff_name
  ,pe_basicinfo_plus.up_date
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
		inner JOIN mst_pat_event_sub_category es on  pe_basicinfo_plus.sub_category_name = es.sub_category_name
		AND ((@subCategoryCd
::text is not null and @subCategoryCd
::text  <> '''') and (es.sub_category_cd = @subCategoryCd
))
;', db_class = 2, detail = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "category_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "sub_category_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(治療実績リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "is_linked", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treat_date", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_kur_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_bed_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treatment_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_detail", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', can_repeat = '1', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '患者情報：患者イベント 治療実績リンク　@patId @fromDate @toDate使用', reg_date = '2021/08/26 13:50:14', up_date = '2021/08/26 13:50:14', pre_sql_info = null where sql_cd = 93;
update ntss.sys_data_set set sql = 'with input_params_expand as
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
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
    ,score_total
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
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,pe_basicinfo_plus.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo_plus.reg_date
  ,up_staff_name
  ,pe_basicinfo_plus.up_date
  
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
		inner JOIN mst_pat_event_sub_category es on  pe_basicinfo_plus.sub_category_name = es.sub_category_name
		AND ((@subCategoryCd
::text is not null and @subCategoryCd
::text  <> '''') and (es.sub_category_cd = @subCategoryCd
))
;', db_class = 2, detail = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "category_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "sub_category_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500 点", "can_calc": "0", "data_code": "score_total", "data_name": "スコア合計", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "score_total", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', can_repeat = '1', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '患者情報：患者イベント スコア計算　@patId @fromDate @toDate使用', reg_date = '2021/08/26 13:50:14', up_date = '2021/08/26 13:50:14', pre_sql_info = null where sql_cd = 92;

