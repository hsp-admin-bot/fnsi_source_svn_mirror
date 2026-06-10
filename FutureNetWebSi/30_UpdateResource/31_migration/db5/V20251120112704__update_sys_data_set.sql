DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-307069,-307073,-307137);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307069, '-- sql:307069
with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
)
,
addition_in_hospital_cd_no as(
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
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
)
,
rece_mng_min_id as(
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
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MIN_ID''
)
,
rece_mng_max_id as(
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
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MAX_ID''
), journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
),
med_admin_unit_wrapper as (
select
    RIGHT((SELECT coop_ord_no FROM journal) || LPAD(((row_number() over (order by code::varchar) - 1 + rm_min_id.value::numeric)::text), 2, ''0''), 10) AS order_units_id,
	(
        case
		(
		select
			value
		from
			addition_in_hospital_cd_no
            )
		when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
		when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
		when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
	end
    ) as code,
	left(ord_main_info.name, 256) as name,
	null as count,
	null as unit,
	null as cutoff,
	1 as seq_no,
	LPAD((row_number() over (order by cast(code as character varying)) - 1 + rm_min_id.value::numeric )::text, 2, ''0'') as order_units_id_suffix
from
	ord_main_info
left join mst_addition on
	ord_main_info.code = cast(mst_addition.addition_cd as character varying)
cross join rece_mng_min_id rm_min_id
cross join rece_mng_max_id rm_max_id
where
	mst_addition.addition_class in (''13'')
	)
	
select
	order_units_id,
	code,
    name,
    count,
	unit,
	cutoff,
	seq_no,
	order_units_id_suffix
from
	med_admin_unit_wrapper
	cross join rece_mng_min_id rm_min_id
	cross join rece_mng_max_id rm_max_id
where
	order_units_id_suffix::numeric between rm_min_id.value::numeric and rm_max_id.value::numeric;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医学管理科情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307073, '-- sql:307073
with input_code_class as (
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
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
),
order_units_wrapper as (
select
	pcd.coop_save_no,
	RIGHT((SELECT coop_ord_no FROM journal) || LPAD(((row_number() over (order by pcd.coop_save_no) - 1) + oui_min.value::numeric )::text, 2, ''0''),10) AS order_units_id,
	''検査'' as application,
	case input_code_class.value::numeric
    	when 0 then 
            case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
            else @dispUserId
            end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as input_user_code,
		case input_code_class.value::numeric
    	when 0 then 
            case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
            else @userName
            end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as input_user_name,
	(pcd.save_2 ->> ''exam_date'') || (pcd.save_2 ->> ''exam_time'') || ''00'' as input_time,
	TO_CHAR(NOW(), ''YYYYMMDDHH24MISS'') as last_update_time,
	(row_number() over (order by pcd.coop_save_no) - 1) + oui_min.value::numeric as order_units_id_suffix
from
	pat_coop_detail pcd
join input_code_class on true
join order_units_id_min oui_min on true
join order_units_id_max oui_max on true
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
from order_units_wrapper, order_units_id_max', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '検査情報(Order_Unitsタグ)取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307077, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307079, "field_name": "user_name", "replace_var": "@userName"}, {"sql_cd": -307081, "field_name": "disp_user_ids", "replace_var": "@ids"}, {"sql_cd": -307082, "field_name": "user_names", "replace_var": "@names"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307137, '-- sql:307137
with input_code_class as (
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
    	when 0 then 
            case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
            else @dispUserId
            end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as input_user_code,
		case input_code_class.value::numeric
    	when 0 then 
            case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
            else @userName
            end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
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
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id,
    @ctlNo as ctl_no
where exists (
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
        order_units_id_suffix
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 検査情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307077, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307079, "field_name": "user_name", "replace_var": "@userName"}, {"sql_cd": -307081, "field_name": "disp_user_ids", "replace_var": "@ids"}, {"sql_cd": -307082, "field_name": "user_names", "replace_var": "@names"}]'::jsonb);