UPDATE sys_data_set 
SET SQL = 'with pat_in_out_visit_history_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,

    info->>''facility_cd'' as facility_cd,
    info->>''move_in_out'' as move_in_out,
    info->>''period_start'' as period_start,
    info->>''period_end'' period_end,
    info->>''in_out'' as in_out,
    info->>''reason'' as reason,
    info->>''from_facility'' as from_facility,
    info->>''from_course'' as from_course,
    info->>''from_doctor'' as from_doctor,
    info->>''to_facility'' as to_facility,
    info->>''to_course'' as to_course,
    info->>''to_doctor'' as to_doctor,
    info->>''is_reply'' as is_reply,
    info->>''comment'' as comment
  from
    pat_unique
    cross join lateral
      json_array_elements (pat_unique.in_out_visit_history_info :: json) info
  where
    pat_id = @patId and  is_del =''0''
), course_tbl as (
  select
    *
  from
    mst_course
  where
    is_disp = ''1''
  and
    is_del = ''0''
)

select
  pat_in_out_visit_history_tbl.*,
  case when from_facility_tbl.facility_name is null then pat_in_out_visit_history_tbl.from_facility
    else from_facility_tbl.facility_name
  end as from_facility_name,
  case when from_course_tbl.course_name is null then pat_in_out_visit_history_tbl.from_course
    else from_course_tbl.course_name
  end as from_course_name,
  case when to_facility_tbl.facility_name is null then pat_in_out_visit_history_tbl.from_facility
    else to_facility_tbl.facility_name
  end as to_facility_name,
  case when to_course_tbl.course_name is null then pat_in_out_visit_history_tbl.from_course
    else to_course_tbl.course_name
  end as to_course_name
from
  pat_in_out_visit_history_tbl
  left join mst_facility as from_facility_tbl
    on pat_in_out_visit_history_tbl.from_facility = from_facility_tbl.facility_cd
  left join course_tbl as from_course_tbl
    on pat_in_out_visit_history_tbl.from_course = from_course_tbl.course_cd::text
  left join mst_facility as to_facility_tbl 
    on pat_in_out_visit_history_tbl.to_facility = to_facility_tbl.facility_cd
  left join course_tbl as to_course_tbl
    on pat_in_out_visit_history_tbl.to_course = to_course_tbl.course_cd::text
order by
  disp_order, ctl_no
' 
WHERE
	sql_cd = '43'