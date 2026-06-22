DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307094;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307095;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307096;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307097;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307098;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307099;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307101;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307102;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307094, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(投薬情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307111, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307119, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307095, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_SHOT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(注射情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307112, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307120, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307096, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_OPERATION_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(手術・麻酔情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307113, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307121, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307097, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_OXYGEN_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
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
	end as staff_cd,
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
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(酸素情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307114, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307122, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307098, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
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
	end as staff_cd,
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
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(処置・治療項目情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307115, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307123, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307099, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_HOLI_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
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
	end as staff_cd,
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
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(夜間・休日加算情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307116, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307124, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307101, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_DIAL_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
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
	end as staff_cd,
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
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(導入期加算入力情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307117, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307125, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307102, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
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
select
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
	end as staff_cd,
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
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(医学管理料情報)','2025-04-09 22:20:13.471', current_timestamp, '[{"sql_cd": -307118, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307126, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
