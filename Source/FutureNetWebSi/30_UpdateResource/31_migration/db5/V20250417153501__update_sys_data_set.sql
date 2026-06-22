DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-307103,-307104,-307105,-307106,-307107,-307108,-307109,-307110
	);

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
	order by occur_date desc,
		ctl_no desc,
		row_no desc
	limit 1
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'', ''3'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(投薬情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
order by occur_date desc, ctl_no desc, row_no desc
limit 1
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'', ''3'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(注射情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
order by occur_date desc, ctl_no desc, row_no desc
limit 1
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'', ''3'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(手術・麻酔情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(酸素情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(処置・治療項目情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(夜間・休日加算情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(導入期加算入力情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);
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
), 
fix_doctor1_cd as (
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' =''FIXED_DOCTOR_CODE1''
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then (select value from fix_doctor1_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(医学管理料情報)', '2025-04-09 17:49:49.194', CURRENT_TIMESTAMP, NULL);