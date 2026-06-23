UPDATE sys_data_set SET sql = 'with pat_in_out_visit_history_tbl as (
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
  to_date(pat_in_out_visit_history_tbl.period_start, ''YYYYMMDD'') as period_start,pat_in_out_visit_history_tbl.ctl_no,pat_in_out_visit_history_tbl.disp_order,
	pat_in_out_visit_history_tbl.facility_cd,pat_in_out_visit_history_tbl.move_in_out,pat_in_out_visit_history_tbl.period_end,
	pat_in_out_visit_history_tbl.in_out,pat_in_out_visit_history_tbl.reason,pat_in_out_visit_history_tbl.from_facility,pat_in_out_visit_history_tbl.from_course,
	pat_in_out_visit_history_tbl.from_doctor,pat_in_out_visit_history_tbl.to_facility,pat_in_out_visit_history_tbl.to_course,pat_in_out_visit_history_tbl.to_doctor,
	pat_in_out_visit_history_tbl.is_reply,pat_in_out_visit_history_tbl.comment,
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
', detail = '[{"preview": "2011/04/21", "can_calc": "0", "data_code": "period_start", "data_name": "発生日", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "period_start", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転出", "can_calc": "0", "data_code": "move_in_out", "data_name": "区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "転入", "item": "転入"}, {"code": "1", "disp": "転出", "item": "転出"}, {"code": "2", "disp": "その他", "item": "その他"}], "data_class": "転入・転出", "field_name": "move_in_out", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第二クリニック", "can_calc": "0", "data_code": "from_facility", "data_name": "転入元施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_facility", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析科", "can_calc": "0", "data_code": "from_course", "data_name": "転入元科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_course", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "from_doctor", "data_name": "転入元医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第一クリニック", "can_calc": "0", "data_code": "to_facility", "data_name": "転出先施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_facility", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第一透析科", "can_calc": "0", "data_code": "to_course", "data_name": "転出先科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_course", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "to_doctor", "data_name": "転出先医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入出理由です。", "can_calc": "0", "data_code": "reason", "data_name": "入出理由", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "reason", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転入・転出コメントです。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "comment", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]'
WHERE sql_cd = 43
