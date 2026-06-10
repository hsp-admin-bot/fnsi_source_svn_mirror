UPDATE sys_data_set 
SET SQL = 'with course_tbl as (
select
*
from
mst_course
where
is_disp = ''1''
and
is_del = ''0''
), ward_tbl as (
select
*
from
mst_ward
where
is_disp = ''1''
and
is_del = ''0''
)

select
is_same,
is_implant,
is_infect,
is_diabetes,
is_blood_suger_exam,
is_wheel_chair,
medical_care_info->>''dialysis_count'' as dialysis_count,
medical_care_info->>''purification_count'' as purification_count,
medical_care_info->>''other_dialysis_count'' as other_dialysis_count,
medical_care_info->>''dialysis_start_date'' as dialysis_start_date,
medical_care_info->>''hospital_start_date'' as hospital_start_date,
case when medical_care_info->>''dialysis_start_date'' is null then null
else to_char(age(''now'', to_date(medical_care_info->>''dialysis_start_date'', ''YYYYMMDD'')), ''FMYY年FMMMヶ月'')
end as dialysis_vintage,
mst_facility.facility_name,
course_tbl.course_name as main_course_name,
trim(course_tbl.in_hospital_cd_1) as main_in_hospital_cd_1,
ward_tbl.ward_name,
trim(ward_tbl.in_hospital_cd_1) as ward_in_hospital_cd_1
from
pat_main
left join mst_facility
on pat_main.medical_care_info->>''facility_cd'' = mst_facility.facility_cd
left join course_tbl 
on pat_main.medical_care_info->>''main_course_cd'' = course_tbl.course_cd::text
left join ward_tbl
on pat_main.medical_care_info->>''ward_cd'' = ward_tbl.ward_cd::text
where
pat_main.is_del = ''0''
and
pat_id = @patId',
detail = '[{"preview": "なし", "can_calc": "0", "data_code": "is_same", "data_name": "同姓同名判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "基本情報", "field_name": "is_same", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症患者", "can_calc": "0", "data_code": "is_infect", "data_name": "感染症患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非感染症患者"}, {"code": "1", "disp": "感染症患者", "item": "感染症患者"}], "data_class": "既往歴", "field_name": "is_infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "main_course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "main_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "main_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "main_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "ward_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "ward_in_hospital_cd_1", "data_name": "病棟名連携コード", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "ward_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "dialysis_count", "data_name": "透析回数", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_count", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11年3ケ月", "can_calc": "0", "data_code": "dialysis_vintage", "data_name": "透析歴", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_vintage", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000/02/10", "can_calc": "0", "data_code": "dialysis_start_date", "data_name": "透析導入日", "data_type": "DateTime", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装病院", "can_calc": "0", "data_code": "facility_name", "data_name": "透析導入施設", "data_type": "DateTime", "conv_table": [], "data_class": "既往歴", "field_name": "facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2005/08/18", "can_calc": "0", "data_code": "hospital_start_date", "data_name": "当院開始日", "data_type": "DateTime", "conv_table": [], "data_class": "既往歴", "field_name": "hospital_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "糖尿病患者", "can_calc": "0", "data_code": "is_diabetes", "data_name": "糖尿病患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非糖尿病患者"}, {"code": "1", "disp": "糖尿病患者", "item": "糖尿病患者"}], "data_class": "糖尿病患者判別", "field_name": "is_diabetes", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' 
WHERE
	sql_cd = '19'