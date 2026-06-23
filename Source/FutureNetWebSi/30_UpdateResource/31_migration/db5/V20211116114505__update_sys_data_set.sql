UPDATE "ntss"."sys_data_set" SET "sql" = 'select
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
left join  mst_course as  course_tbl 
on pat_main.medical_care_info->>''main_course_cd'' = course_tbl.course_cd::text   and course_tbl.is_disp = ''1'' and  course_tbl.is_del = ''0''
left join mst_ward  as ward_tbl
on pat_main.medical_care_info->>''ward_cd'' = ward_tbl.ward_cd::text and  ward_tbl.is_disp=''1'' and  ward_tbl.is_del = ''0''
where
pat_main.is_del = ''0''
and
pat_id = @patId' WHERE "sql_cd" = 19;
UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  array_to_string(array_agg(pat_group_tbl.pat_group_name), '','') as pat_group_name
from
  pat_group_detail
  inner join  pat_group as  pat_group_tbl 
	on pat_group_detail.pat_group_cd = pat_group_tbl.pat_group_cd  and pat_group_tbl.is_disp = ''1'' and    pat_group_tbl.is_del = ''0''
	and pat_group_tbl.facility_cd=pat_group_detail.facility_cd
where
  pat_id = @patId' WHERE "sql_cd" = 21;

UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_infect_tbl as (
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
), pat_facility as (
   select facility_cd    
   from
    pat_main
   where  
     pat_id = @patId limit 1
),
infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from pat_facility )
    and master_physical_name = ''mst_infection''
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
  left join   infection_order as inf   on (inf.infection_cd ::bigint = pat_infect_tbl.infection_cd::bigint)
where
  infect = ''2''
or
  infect = ''1''
order by
  infection_cd_order' WHERE "sql_cd" = 24;
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
), pat_facility as (
   select facility_cd    
   from
    pat_main
   where  
      pat_id = @patId limit 1
),
infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from pat_facility )
    and master_physical_name = ''mst_infection''
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
		 left join   infection_order as inf   on (inf.infection_cd ::bigint = pat_infect_tbl.infection_cd::bigint)
where
  infect = ''2''
	or
  infect = ''1''
or 
  infect = ''0''
order by
  infection_cd_order
' WHERE "sql_cd" = 25;
UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	to_number ( info ->> ''ctl_no'', ''99999'' ) AS ctl_no,
	to_number ( info ->> ''disp_order'', ''99999'' ) AS disp_order,
	info ->> ''is_primary_illness'' AS is_primary_illness,
	info ->> ''is_main_disease'' AS is_main_disease,
	info ->> ''is_notice'' AS is_notice,
	info ->> ''disease_date'' AS disease_date,
	info ->> ''disease_day'' AS disease_day,
	info ->> ''disease_cd'' AS disease_cd,
	info ->> ''out_come'' AS out_come,
	info ->> ''out_come_date'' AS out_come_date,
	info ->> ''diagnostician_cd'' AS diagnostician_cd,
	info ->> ''memo'' AS memo,
	info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd,
	info ->> ''course_cd'' AS course_cd,
	info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy,
	info ->> ''is_diagnosed'' AS is_diagnosed,
	info ->> ''is_diagnosed'' AS is_dialysis_main,
	info ->> ''is_dialysis_underlying_disease'' AS is_dialysis_underlying_disease,
	info ->> ''course_is_free'' AS course_is_free,
	info ->> ''diagnostician_is_free'' AS diagnostician_is_free,
	info ->> ''disease_cd'' AS disease_cd1,
CASE
	
	WHEN info ->> ''diagnostician_is_free'':: text = ''1'' THEN
	info ->> ''disease_cd'':: text ELSE disease_tbl.disease_name 
	END AS disease_name,
CASE
		
		WHEN 	info ->> ''diagnosis_facility_is_free'':: text = ''1'' THEN
		info ->> ''diagnosis_facility_cd'':: text ELSE mst_facility.facility_name 
	END AS facility_name,
CASE
		
		WHEN info ->> ''course_is_free'':: text = ''1'' THEN
			info ->> ''course_cd'':: text ELSE course_tbl.course_name 
	END AS course_name 
FROM
	pat_unique AS pat_medical_hst_tbl
	CROSS JOIN lateral json_array_elements ( pat_medical_hst_tbl.medical_hst_info :: json ) info
	LEFT JOIN mst_disease AS disease_tbl ON info ->> ''disease_cd'':: text = disease_tbl.disease_cd :: text 
	AND disease_tbl.is_disp = ''1'' 
	AND disease_tbl.is_del = ''0''
	AND pat_medical_hst_tbl.facility_cd=disease_tbl.facility_cd
	LEFT JOIN mst_facility ON info ->> ''diagnosis_facility_cd'':: text  = mst_facility.facility_cd
	LEFT JOIN mst_course AS course_tbl ON info ->> ''course_cd'':: text = course_tbl.course_cd :: text 
	AND course_tbl.is_disp = ''1'' 
	AND course_tbl.is_del = ''0'' 
	AND course_tbl.facility_cd = pat_medical_hst_tbl.facility_cd 
WHERE
	info ->> ''is_primary_illness'' :: text = ''1'' 
	and pat_medical_hst_tbl.pat_id = @patId
  and pat_medical_hst_tbl.is_del = ''0''

ORDER BY
	disp_order,
ctl_no' WHERE "sql_cd" = 26;





