DELETE FROM sys_data_set WHERE sql_cd IN 
(-307079,-307077,-307073);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307079, 'select
  coalesce((
    select personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
    from mst_personal_user
    where user_id = cast(nullif('''', '''') as int)
  ), '''') as user_name', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307077, 'select
  coalesce((
    select disp_user_id
    from mst_user_authentication
    where user_id = cast(nullif(@staffCd, '''') as int)
  ), '''') as disp_user_id
', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
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
order_units_wrapper as (
select
	pcd.coop_save_no,
	LPAD(pcd.save_2 ->> ''ord_no'', 8, ''0'') || LPAD((row_number() over (order by pcd.coop_save_no) + oui_min.value::numeric )::text, 2, ''0'') as order_units_id,
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
	row_number() over (order by pcd.coop_save_no) + oui_min.value::numeric as order_units_id_suffix
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