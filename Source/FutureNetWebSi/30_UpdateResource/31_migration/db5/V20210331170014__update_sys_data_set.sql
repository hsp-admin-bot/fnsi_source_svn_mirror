UPDATE sys_data_set 
SET SQL = 'with base_staff_tbl as (
select
to_number(info->>''ctl_no'', ''99999'') as ctl_no,
to_number(info->>''disp_order'', ''99999'') as disp_order,
info->>''is_main'' as is_main,
info->>''staff_cd'' as staff_cd
from
pat_main
cross join lateral
json_array_elements (pat_main.charge_staff_info :: json) info
where
pat_id = @patId
), doctor_tbl as (
select
array_agg(doc.staff_cd) doctor_cd_array
from
(select
staff_cd
from
base_staff_tbl
where
is_main = ''1''
order by
disp_order, ctl_no
limit 2
) doc
), staff_tbl as (
select
array_agg(doc.staff_cd) staff_cd_array
from
(select
staff_cd
from
base_staff_tbl
where
is_main = ''0''
order by
disp_order, ctl_no
limit 2
) doc
)

select
doctor_cd_array[1] as doctor1_cd,
doctor_cd_array[1] as doctor1_name,
doctor_cd_array[2] as doctor2_cd,
doctor_cd_array[2] as doctor2_name,
staff_cd_array[1] as staff1_cd,
staff_cd_array[1] as staff1_name,
staff_cd_array[2] as staff2_cd,
staff_cd_array[2] as staff2_name
from
doctor_tbl, staff_tbl',
detail = '[{"preview": "123456789", "can_calc": "0", "data_code": "doctor1_cd", "data_name": "担当医1ID", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "doctor1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師1", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "doctor1_name", "data_name": "担当医1", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "doctor1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "doctor2_cd", "data_name": "担当医2ID", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "doctor2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師2", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "doctor2_name", "data_name": "担当医2", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "doctor2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff1_cd", "data_name": "担当スタッフ1ID", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "staff1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "staff1_name", "data_name": "担当スタッフ1", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "staff1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff2_cd", "data_name": "担当スタッフ2ID", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "staff2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "staff2_name", "data_name": "担当スタッフ2", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "staff2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' 
WHERE
	sql_cd = '20'