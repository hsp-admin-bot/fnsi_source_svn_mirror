UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_medical_hst_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
    info->>''is_primary_illness'' as is_primary_illness,
    info->>''is_main_disease'' as is_main_disease,
    info->>''is_notice'' as is_notice,
    to_date(info->>''disease_date'', ''YYYYMMDD'') as disease_date,
    info->>''disease_cd'' as disease_cd,
    info->>''out_come'' as out_come,
    to_date(info->>''out_come_date'', ''YYYYMMDD'') as out_come_date,
    info->>''diagnostician_cd'' as diagnostician_cd,
    info->>''memo'' as memo,
    info->>''diagnosis_facility_cd'' as diagnosis_facility_cd,
    info->>''course_cd'' as course_cd,
    info->>''is_confirmation_biopsy'' as is_confirmation_biopsy,
    info->>''is_diagnosed'' as is_diagnosed,
    info->>''is_dialysis_underlying_disease'' as is_dialysis_underlying_disease,
    info->>''course_is_free'' as course_is_free,
    info->>''diagnostician_is_free'' as diagnostician_is_free
  from
    pat_unique
    cross join lateral
      json_array_elements (pat_unique.medical_hst_info :: json) info
  where
    pat_id = @patId and is_del = ''0''
), disease_tbl as (
  select
    *
  from
    mst_disease
  where
    is_disp = ''1''
  and
    is_del = ''0''
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
  pat_medical_hst_tbl.*,
  case when pat_medical_hst_tbl.diagnostician_is_free = ''1'' then pat_medical_hst_tbl.disease_cd
    else disease_tbl.disease_name
  end as disease_name,
  case when mst_facility.facility_name is null then pat_medical_hst_tbl.diagnosis_facility_cd
    else mst_facility.facility_name
  end as facility_name,
  case when pat_medical_hst_tbl.course_is_free = ''1'' then pat_medical_hst_tbl.course_cd
    else course_tbl.course_name
  end as course_name
from
  pat_medical_hst_tbl
  left join disease_tbl
    on pat_medical_hst_tbl.disease_cd = disease_tbl.disease_cd::text
  left join mst_facility
    on pat_medical_hst_tbl.diagnosis_facility_cd = mst_facility.facility_cd
  left join course_tbl
    on pat_medical_hst_tbl.course_cd = course_tbl.course_cd::text
where
  pat_medical_hst_tbl.is_primary_illness = ''1''
order by
  disp_order, ctl_no
', "detail" = '[{"preview": "インフルエンザ", "can_calc": "0", "data_code": "course_name", "data_name": "病名", "data_type": "string", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/22", "can_calc": "0", "data_code": "disease_date", "data_name": "発症日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "disease_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治癒", "can_calc": "0", "data_code": "out_come", "data_name": "転帰", "data_type": "string", "conv_table": [{"code": "0", "disp": "治癒", "item": "治癒"}, {"code": "1", "disp": "死亡", "item": "死亡"}, {"code": "2", "disp": "中止", "item": "中止"}, {"code": "3", "disp": "治療中", "item": "治療中"}], "data_class": "病歴(昇順)", "field_name": "out_come", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/30", "can_calc": "0", "data_code": "out_come_date", "data_name": "転帰更新日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "out_come_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "is_notice", "data_name": "告知", "data_type": "string", "conv_table": [{"code": "0", "disp": "済", "item": "済"}, {"code": "1", "disp": "未", "item": "未"}], "data_class": "病歴(昇順)", "field_name": "is_notice", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "diagnostician_cd", "data_name": "診断医", "data_type": "string", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "diagnostician_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "原疾患", "can_calc": "0", "data_code": "diagnostician_cd", "data_name": "原疾患扱い", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非原疾患"}, {"code": "1", "disp": "原疾患", "item": "原疾患"}], "data_class": "病歴(昇順)", "field_name": "diagnostician_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 27;