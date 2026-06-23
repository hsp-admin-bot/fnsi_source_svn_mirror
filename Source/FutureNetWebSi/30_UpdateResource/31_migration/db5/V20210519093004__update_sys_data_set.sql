UPDATE "ntss"."sys_data_set" SET "sql" = 'with machine_tbl as (
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
    case
      when (mws.survey_data ->> ''value'' is not null or mws.survey_data ->> ''text'' is not null ) then mws.survey_data ->> ''value''::text || coalesce(mws.survey_data ->> ''unit'', '''') || coalesce(mws.survey_data ->> ''text'', '''')
      when ( mws.survey_data ->> ''time'' is not null or mws.survey_data ->> ''picker'' is not null ) then ''検査中''
      when ( mws.inspection_date <= current_timestamp ) then ''(調査未実施)''
      when mws.survey_data ->> ''plan'' = ''1'' then ''○''
      else null
    end as result

  from
    mnt_water_survey as mws

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
         on wst.survey_data ->> ''point_cd'' = wspt.survey_point_cd ::TEXT
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
order by
  point_disp_order nulls last, point_name, machine_name, cells.inspection_date_str
;' WHERE "sql_cd" = 127;