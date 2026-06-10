DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307073;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307077;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307078;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307079;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307080;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307081;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307082;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307083;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307073, 'with input_code_class as (
-- 検査入力者コード区分
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：患者連携情報．連携情報カラム２→依頼医名コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
,
fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
,disp_user_ids AS (
  SELECT 
    jsonb_array_elements(
      @ids
      ::jsonb
    ) AS elem
),
user_names AS (
  SELECT 
    jsonb_array_elements(
      @names
      ::jsonb
    ) AS elem
)
, 
pat_coop_detail_users as (
select
	du.elem ->> ''coop_save_no'' as coop_save_no,
	du.elem ->> ''disp_user_id'' as disp_user_id,
	un.elem ->> ''user_name'' as user_name
from
	disp_user_ids du
join 
  user_names un 
  on
	(du.elem ->> ''coop_save_no'') = (un.elem ->> ''coop_save_no'')
left join 
  pat_coop_detail pcd 
  on
	pcd.coop_save_no = (du.elem ->> ''coop_save_no'')::numeric
), 
order_units_id_min as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MIN''
limit 1
), 
order_units_id_max as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MAX''
limit 1
)
,
examination as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
	and info ->> ''key2'' = ''EXAMINATION''
limit 1
),
order_units_wrapper as (
select
	pcd.coop_save_no,
	LPAD(pcd.save_2 ->> ''ord_no'', 8, ''0'') || LPAD((row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric )::text, 2, ''0'') as order_units_id,
	examination.value as application,
	case input_code_class.value::numeric
    	when 0 then @dispUserId
		when 1 then 
			case when pcdu.disp_user_id is not null then pcdu.disp_user_id
			else (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as input_user_code,
		case input_code_class.value::numeric
    	when 0 then @userName
		when 1 then 
			case when pcdu.user_name is not null then pcdu.user_name
			else (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as input_user_name,
	(pcd.save_2 ->> ''exam_date'') || (pcd.save_2 ->> ''exam_time'') || ''00'' as input_time,
	TO_CHAR(NOW(), ''YYYYMMDDHH24MISS'') as last_update_time,
	row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric as order_units_id_suffix
from
	pat_coop_detail pcd
cross join examination
cross join input_code_class
cross join order_units_id_min oui_min
cross join order_units_id_max oui_max
left join pat_coop_detail_users pcdu on pcdu.coop_save_no::numeric = pcd.coop_save_no
where
	facility_cd = @facilityCd
	and pat_id = @patId
	and (save_2 ->> ''ord_no'')::numeric = @ordNo)
	
	
select
	coop_save_no,
	order_units_id,
	application,
	input_user_code,
	input_user_name,
	input_time,
	last_update_time,
	''01'' as detail_id,
	@ordNo as ord_no,
	@facilityCd as facility_cd,
	@key0 as key0
from order_units_wrapper
cross join order_units_id_max oui_max
cross join order_units_id_min oui_min
where
	(order_units_id_suffix::numeric) between oui_min.value::numeric and oui_max.value::numeric
order by
	coop_save_no,
	order_units_id_suffix', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '検査情報(Order_Unitsタグ)取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307077, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307079, "field_name": "user_name", "replace_var": "@userName"}, {"sql_cd": -307081, "field_name": "disp_user_ids", "replace_var": "@ids"}, {"sql_cd": -307082, "field_name": "user_names", "replace_var": "@names"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307077, 'select disp_user_id
from mst_user_authentication
where user_id = @staffCd;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307078, '-- ・患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- ※患者基本情報の主治医を取得する場合は、患者基本情報． 担当スタッフ情報→主治医が「1」のものを取得。また、主治医が複数設定されている場合は、表示順が最初の担当医を設定する。
-- （失敗時は治療情報．実績：担当者情報）
with ord_staff_cd as (
select
	case
		when rst_charge_user_info ->> ''user_id_1'' is not null then rst_charge_user_info ->> ''user_id_1''
		when rst_charge_user_info ->> ''user_id_2'' is not null then rst_charge_user_info ->> ''user_id_2''
		else null
	end as staff_cd
from
	ord_main
where
	ord_no = @ordNo
limit 1
),
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as staff_cd
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
join ord_staff_cd on
	true
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)


select
  case
    when psc.staff_cd is not null then psc.staff_cd
    else osc.staff_cd
  end as staff_cd
from
  ord_staff_cd osc
  left join pat_staff_cd psc on true', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307079, 'select
	personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name) as user_name
from
	mst_personal_user
where
	user_id = @staffCd', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307080, 'SELECT 
  json_agg(row_to_json(t))::text AS staff_cds
FROM (
  SELECT
    coop_save_no,
    save_2 ->> ''staff_cd'' AS staff_cd
  FROM
    pat_coop_detail
  WHERE
    pat_id = @patId
) t', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307081, 'select
	json_agg(row_to_json(t))::text as disp_user_ids
from
	(
	select
		elem->>''coop_save_no'' as coop_save_no,
		mua.disp_user_id as disp_user_id
	from
		jsonb_array_elements(@staffCds::jsonb) as elem
	left join mst_user_authentication mua on
		mua.user_Id = (elem->>''staff_cd'')::numeric) t', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307080, "field_name": "staff_cds", "replace_var": "@staffCds"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307082, 'select
	json_agg(row_to_json(t))::text as user_names
from
	(
select
	elem->>''coop_save_no'' as coop_save_no,
	personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name) as user_name
from
	jsonb_array_elements(@staffCds::jsonb) as elem
left join mst_personal_user mpu on mpu.user_Id = (elem->>''staff_cd'')::numeric) t;', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', current_timestamp, current_timestamp, '[{"sql_cd": -307080, "field_name": "staff_cds", "replace_var": "@staffCds"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307083, 'with use_in_hospital_cd_no as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
	and info->>''key1'' = ''MST''
	and info->>''key2'' = ''EXAM_ITEM_COST''
limit 1
)
, 
exam_code_before as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_BEFORE''
	limit 1
)
,
exam_code_after as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_AFTER''
	limit 1
)
,
exam_code_other as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_OTHER''
	limit 1
),
exam_timing as (
select
	save_2 ->> ''exam_timing'' as value
from
	pat_coop_detail pcd
where
	coop_save_no = @coopSaveNo
limit 1
)
, 
exam_data_with_exam_timing as (
select
	case
		when exam_timing.value = ''1'' then exam_code_before.value
		when exam_timing.value = ''2'' then exam_code_after.value
		else exam_code_other.value
	end as code,
	case
		when exam_timing.value = ''1'' then ''透析前''
		when exam_timing.value = ''2'' then ''透析後''
		else ''その他''
	end as name,
	''1'' as count,
	null as unit,
	null as cotoff,
	1 as seq_no
from
	exam_timing,
	exam_code_before,
	exam_code_after,
	exam_code_other
union all
select
	case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end as code,
	t->>''exam_name'' as name,
	''1'' as count,
	null as unit,
	null as cutoff,
	row_number() over(
		order by case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end 
	) + 1 as seq_no
from
	pat_coop_detail pcd,
	use_in_hospital_cd_no
join lateral jsonb_array_elements(save_2->''exam_items'') as t on
	true
where
	coop_save_no = @coopSaveNo
	and case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end is not null
)

select * from exam_data_with_exam_timing order by seq_no
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '検査項目情報(Orderタグ)取得用', current_timestamp, current_timestamp, NULL);