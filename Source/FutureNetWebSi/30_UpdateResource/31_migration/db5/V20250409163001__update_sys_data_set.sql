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
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307103;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307104;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307105;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307106;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307107;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307108;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307109;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307110;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307111;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307112;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307113;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307114;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307115;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307116;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307117;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307118;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307119;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307120;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307121;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307122;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307123;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307124;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307125;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307126;

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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
		when 1 then @dispUserId
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
    	when 0 then @userName
		when 1 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(投薬情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307111, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307119, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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

select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
		when 1 then @dispUserId
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
    	when 0 then @userName
		when 1 then @userName
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
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(注射情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307112, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307120, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
		when 1 then @dispUserId
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
    	when 0 then @userName
		when 1 then @userName
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
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(手術・麻酔情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307113, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307121, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
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
    	when 0 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(酸素情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307114, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307122, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
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
    	when 0 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(処置・治療項目情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307115, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307123, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
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
    	when 0 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(夜間・休日加算情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307116, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307124, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
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
    	when 0 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(導入期加算入力情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307117, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307125, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
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


select
	case input_code_class.value::numeric
    	when 0 then @dispUserId
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
    	when 0 then @userName
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
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(医学管理料情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307118, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307126, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307103, 'with input_code_class as (
	--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
	--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
	--3：固定医師コード1より取得
	--4：固定医師コード2より取得
	--5：固定担当看護師コード1より取得
	--6：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
), ord_staff_cd as (
	select rst_charge_user_info->>''user_id_1'' as value
	from ord_main om
	where ord_no = @ordNo
	limit 1
), pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
), treatment_staff_cd as (
	-- 最新の発生日時からスタッフを取得(FNWを踏襲)
	select staff_info->>''ctl_no'' as ctl_no,
		staff_info->>''row_no'' as row_no,
		staff_info->>''occur_date'' as occur_date,
		staff_info->>''treat_staff_cd'' as value
	from ord_main,
		lateral json_array_elements(rst_treat_staff_info::json) staff_info
	where ord_no = @ordNo
	order by occur_date,
		ctl_no desc,
		row_no desc
	limit 1
)
select case
		input_code_class.value::numeric
		when 0 then 
			case when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
				else ord_staff_cd.value::text
			end
		when 1 then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
				else treatment_staff_cd.value::text
			end
		when 2 then 
			case when treatment_staff_cd.value::text is not null then treatment_staff_cd.value::text
				else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
	cross join treatment_staff_cd
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(投薬情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307104, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
),
treatment_staff_cd as (
-- 最新の発生日時からスタッフを取得(FNWを踏襲)
select
	staff_info ->> ''ctl_no'' as ctl_no,
	staff_info ->> ''row_no'' as row_no,
	staff_info ->> ''occur_date'' as occur_date,
	staff_info ->> ''treat_staff_cd'' as value
from
	ord_main,
	lateral json_array_elements(rst_treat_staff_info::json) staff_info
where
	ord_no = @ordNo
order by occur_date, ctl_no desc, row_no desc
limit 1
)

select case
		input_code_class.value::numeric
		when 0 then 
			case when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
				else ord_staff_cd.value::text
			end
		when 1 then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
				else treatment_staff_cd.value::text
			end
		when 2 then 
			case when treatment_staff_cd.value::text is not null then treatment_staff_cd.value::text
				else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
	cross join treatment_staff_cd
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(注射情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307105, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
),
treatment_staff_cd as (
-- 最新の発生日時からスタッフを取得(FNWを踏襲)
select
	staff_info ->> ''ctl_no'' as ctl_no,
	staff_info ->> ''row_no'' as row_no,
	staff_info ->> ''occur_date'' as occur_date,
	staff_info ->> ''treat_staff_cd'' as value
from
	ord_main,
	lateral json_array_elements(rst_treat_staff_info::json) staff_info
where
	ord_no = @ordNo
order by occur_date, ctl_no desc, row_no desc
limit 1
)

select case
		input_code_class.value::numeric
		when 0 then 
			case when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
				else ord_staff_cd.value::text
			end
		when 1 then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
				else treatment_staff_cd.value::text
			end
		when 2 then 
			case when treatment_staff_cd.value::text is not null then treatment_staff_cd.value::text
				else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
	cross join treatment_staff_cd
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(手術・麻酔情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307106, 'with input_code_class as (
	-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
	-- 2：固定医師コード1より取得
	-- 3：固定医師コード2より取得
	-- 4：固定担当看護師コード1より取得
	-- 5：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_OXYGEN_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
), ord_staff_cd as (
	select rst_charge_user_info->>''user_id_1'' as value
	from ord_main om
	where ord_no = @ordNo
	limit 1
), pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
)
select case
		when input_code_class.value = ''0'' then case
			when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
			else ord_staff_cd.value::text
		end
		when input_code_class.value = ''1'' then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
			else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(酸素情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307107, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select case
		when input_code_class.value = ''0'' then case
			when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
			else ord_staff_cd.value::text
		end
		when input_code_class.value = ''1'' then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
			else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(処置・治療項目情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307108, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select case
		when input_code_class.value = ''0'' then case
			when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
			else ord_staff_cd.value::text
		end
		when input_code_class.value = ''1'' then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
			else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
limit 1
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(夜間・休日加算情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307109, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select case
		when input_code_class.value = ''0'' then case
			when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
			else ord_staff_cd.value::text
		end
		when input_code_class.value = ''1'' then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
			else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(導入期加算入力情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307110, 'with input_code_class as (
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
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select case
		when input_code_class.value = ''0'' then case
			when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
			else ord_staff_cd.value::text
		end
		when input_code_class.value = ''1'' then 
			case when ord_staff_cd.value::text is not null then ord_staff_cd.value::text
			else ''''
			end
	end as staff_cd
from ord_staff_cd
	cross join pat_staff_cd
	cross join input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(医学管理料情報)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307111, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(投薬情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307103, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307112, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(注射情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307104, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307113, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(手術・麻酔情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307105, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307114, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(酸素情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307106, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307115, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(処置・治療項目情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307107, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307116, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(夜間・休日加算情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307108, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307117, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(導入期加算入力情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307109, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307118, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(医学管理料情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307110, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307119, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(投薬情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307103, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307120, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(注射情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307104, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307121, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(手術・麻酔情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307105, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307122, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(酸素情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307106, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307123, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(処置・治療項目情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307107, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307124, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(夜間・休日加算情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307108, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307125, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(導入期加算入力情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307109, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307126, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(医学管理料情報)', current_timestamp, current_timestamp, '[{"sql_cd": -307110, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);