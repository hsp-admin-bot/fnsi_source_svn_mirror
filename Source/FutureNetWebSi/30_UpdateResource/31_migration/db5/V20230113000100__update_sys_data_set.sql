DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (127);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
127
,'with machine_tbl as (
  select
    *
  from
    mst_machine
  where
    facility_cd = @facilityCd
  and
    is_disp = ''1''
  and
    is_del = ''0''

), water_survey_type_tbl as (
  select
    survey_type_cd,
    survey_type_name
  from
    mst_water_survey_type
  where
    facility_cd = @facilityCd
  and
    is_disp = ''1''
  and
    is_del = ''0''

), water_survey_point_tbl as (
  select
    mwsp.survey_point_cd,
    mwsp.point_name,
    mwsp.machine_no,
		mwsp.survey_type_cd,
    mt.machine_name
  from
    mst_water_survey_point as mwsp
      left join machine_tbl as mt
        on mwsp.machine_no = mt.machine_no
  where
    mwsp.facility_cd = @facilityCd
  and
    mwsp.is_disp = ''1''
  and
    mwsp.is_del = ''0''

), water_servey_tbl as (
  select
    mws.*,
    survey_data_json ->> ''point_cd''  as point_cd,
    case
      when (survey_data_json ->> ''value'' <> '''') then survey_data_json ->> ''value''::text || coalesce(survey_data_json ->> ''unit'', '''')  || coalesce(survey_data_json ->> ''text'', '''')
      when ( survey_data_json ->> ''time'' <> '''' or survey_data_json ->> ''picker'' <> ''0'' ) then ''検査中''
      when ( mws.inspection_date <= current_timestamp ) then ''(調査未実施)''
      when survey_data_json ->> ''plan'' = ''1'' then ''○''
      else null
    end as result

  from
    mnt_water_survey as mws
    CROSS JOIN LATERAL json_array_elements(mws.survey_data ::json) survey_data_json

  where
    facility_cd = @facilityCd
  and
    inspection_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    is_disp = ''1''
  and
    is_del = ''0''

)
, inspection_date_records as (
  select
    to_char(inspection_date, ''yyyy/mm/dd'') as inspection_date 
  from
    water_servey_tbl
  group by water_servey_tbl.inspection_date
)
, cells as (
  select
    *
    ,inspection_date_records.inspection_date as inspection_date_str
  from
    water_survey_point_tbl, inspection_date_records
)
, inspection_records as (
  select
    wspt.machine_no as m_no,
    wspt.machine_name as m_name,
    wspt.point_name as p_name,
    wspt.survey_point_cd as s_p_code,

    wstt.survey_type_name as s_t_name,

    wst.*

  from
    water_survey_point_tbl as wspt
      left join water_servey_tbl as wst
         on wst.point_cd = wspt.survey_point_cd ::TEXT
      left join water_survey_type_tbl as wstt
        on wspt.survey_type_cd = wstt.survey_type_cd
)
, disp_order_tbl as (
  select
    one_json->>''code'' as code
    --,one_json->>''name'' as bed_name
    ,json_idx as disp_order
  from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = @facilityCd and master_physical_name = ''mst_machine''
)

select
  lpad(disp_order::text, 19, ''0'') as point_disp_order
  ,cells.machine_no
  ,cells.machine_name
  ,case
      when (cells.survey_type_cd is not null) then (SELECT survey_type_name FROM water_survey_type_tbl where cells.survey_type_cd = water_survey_type_tbl.survey_type_cd)
      else null
    end as survey_type_name
  ,cells.point_name
  ,cells.inspection_date_str
  ,inspection_records.result
  ,inspection_records.*
from
  cells
  left outer join inspection_records
    on cells.survey_point_cd = inspection_records.s_p_code
    and cells.inspection_date = to_char(inspection_records.inspection_date, ''yyyy/mm/dd'')
  left outer join disp_order_tbl
    on cells.machine_no::text = disp_order_tbl.code::text
where
  cells.machine_no in (@machineNo)
order by
  point_disp_order nulls last, point_name, machine_name, cells.inspection_date_str
;'
,2
,'[{"preview":"0000000000000000010","can_calc":"0","data_code":"point_disp_order","data_name":"調査箇所表示順","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_disp_order","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"DAB","can_calc":"0","data_code":"machine_name","data_name":"装置名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"machine_name","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"ET","can_calc":"0","data_code":"survey_type_name","data_name":"水質検査種別","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_type_name","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"B原液タンク(ET)","can_calc":"0","data_code":"point_name","data_name":"調査箇所名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_name","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"2020/04/10","can_calc":"0","data_code":"inspection_date_str","data_name":"検査日","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"inspection_date_str","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"200EU/mL未満","can_calc":"0","data_code":"result","data_name":"検査結果","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"result","disp_format":"","data_category":"水質管理","facility_table":"","facility_filter_type":"0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [11]}'
,'水質調査　@facilityCd @fromDate @toDateを使用'
,'2020-04-02 00:00:00'
, CURRENT_TIMESTAMP
,NULL
);
