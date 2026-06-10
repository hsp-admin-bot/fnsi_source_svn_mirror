UPDATE "ntss"."sys_data_set" SET "sql" = ' with pat_infect_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    info->>''infection_cd'' as infection_cd,
    info->>''infect'' as infect,
    info->>''exam_date'' as exam_date,
    info->>''up_date'' as up_date
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.infect_info :: json) info
  where
    pat_id = @patId
	and is_del = ''0''
)

select
  pat_infect_tbl.*,
  a.infection_name
from
  pat_infect_tbl
  inner join (
    select
      *
    from
      mst_infection
    where
      is_disp = ''1''
    and
      is_del = ''0''
  ) a
    on pat_infect_tbl.infection_cd::bigint = a.infection_cd
where
  infect = ''2''
order by
  ctl_no
', "detail" = '[{"preview": "Hbc抗体", "can_calc": "0", "data_code": "infection_name", "data_name": "感染症", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "infection_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "(+)", "can_calc": "0", "data_code": "infect", "data_name": "感染症結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "(-)", "item": "(-)"}, {"code": "2", "disp": "(+)", "item": "(+)"}], "data_class": "感染症(+)", "field_name": "infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/01", "can_calc": "0", "data_code": "exam_date", "data_name": "感染症検査日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "exam_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/02", "can_calc": "0", "data_code": "up_date", "data_name": "感染症更新日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "up_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]'WHERE "sql_cd" = 23;