DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307084;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307085;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307087;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307088;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307089;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307090;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307091;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307092;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307084, 'select
  ''FUTURENET_'' ||
  ppm.hosp_pat_id ||
  ''_'' ||
  @rstStartDate ||
	''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', current_timestamp, current_timestamp, '[{"sql_cd": -307085, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307085, 'select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as rst_start_date
from
  ord_main_restore as ord
where
  ord.ord_no = @ordNo
order by del_date desc
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307087, 'WITH input_code_class AS (
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''MCOM_COMMON_INFO''
        AND info ->> ''key2'' = ''INOUT_USE_SET''
    LIMIT 1
)

SELECT
    CASE
        WHEN icc.value = ''0'' THEN NULL
        WHEN omr.rst_in_out_class = 0 THEN ''外来''
        WHEN omr.rst_in_out_class = 1 THEN ''入院''
    END AS in_patient_flag
FROM
    ord_main_restore AS omr
    JOIN input_code_class AS icc ON TRUE
WHERE
    omr.ord_no = @ordNo
order by del_date desc
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '受信区分取得用(削除オーダ)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307088, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
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
	case doctor_code_class.value::numeric
    	when 0 then @dispUserId -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
		when 1 then @dispUserId -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then  (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1) 
			else @dispUserId end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_code,
		case doctor_code_class.value::numeric
    	when 0 then @userName -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
		when 1 then @userName  -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1) 
			else @userName end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_name
from
doctor_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医取得用(削除オーダ)', current_timestamp, current_timestamp, '[{"sql_cd": -307091, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307092, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307089, 'with department_code_class as (
    --診療科コード区分 0：治療情報．実績：診療科コード（診療科マスタの連携コード1）（取得できない場合は固定診療科コード）1：固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_CODE_CLASS''
    limit 1
), department_name_class as (
    --診療科名設定区分 0:治療情報．実績：診療科コードから診療科マスタの診療科名 1:固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRES_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_NAME_CLASS''
    limit 1
), fixed_medical_code as (
    --固定診療科コード:治療情報．実績：診療科コードより診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_CODE''
    limit 1
), fixed_medical_name as (
    --固定診療科名:治療情報．実績：診療科名より診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_NAME''
    limit 1
)

select case
        when dcc.value = ''0'' then case
            when mc.in_hospital_cd_1 is not null
            or mc.in_hospital_cd_1 != '''' then mc.in_hospital_cd_1
            else fmc.value
        end
        when dcc.value = ''1'' then fmc.value
    end as course_cd,
    case
        when dnc.value = ''0'' then mc.course_name
        when dnc.value = ''1'' then fmn.value
    end as course_name
from ord_main_restore
    join department_code_class dcc on TRUE
    join department_name_class dnc on TRUE
    join fixed_medical_code fmc on TRUE
    join fixed_medical_name fmn on TRUE
    left join mst_course mc on mc.course_cd = rst_course_cd
where ord_no = @ordNo
order by del_date desc
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '診療科取得用(削除オーダ)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307090, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
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
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
limit 1
),
journal_staff_cd as (
select
	user_id as value
from
	sys_coop_journal
where
	ctl_no = @ctlNo
limit 1
)
,
ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main_restore omr
where
	ord_no = @ordNo
order by
	del_date desc
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


select
  case when doctor_code_class.value = ''0'' then 
  	case when journal_staff_cd.value::text is not null then  journal_staff_cd.value::text
  	else ord_staff_cd.value::text 
	end
  when doctor_code_class.value = ''1'' then 
  	case ord_staff_cd.value::text is not null when true then ord_staff_cd.value::text
  	else pat_staff_cd.value::text
	end
  when doctor_code_class.value = ''2'' then 
  	case when pat_staff_cd.value::text is not null then pat_staff_cd.value::text
  	else '''' 
	end
  end as staff_cd
from
  ord_staff_cd
  join pat_staff_cd on true
  join doctor_code_class on true
  join journal_staff_cd on true
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 スタッフコード取得用(削除オーダ)', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307091, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 表示用利用者ID取得用(削除オーダ)', current_timestamp, current_timestamp, '[{"sql_cd": -307090, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307092, 'SELECT
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
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 名称取得用(削除オーダ)', current_timestamp, current_timestamp, '[{"sql_cd": -307090, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);