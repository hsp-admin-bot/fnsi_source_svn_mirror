DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106000, -1100006, -1100005, -1100003, -1100000);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106000, 'with coop_ini_info as (
--連携設定より取得
select
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value,
	info ->> ''key1'' as key1,
	info ->> ''key2'' as key2
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' in (
        ''SCM_COMMON'',
        ''SCM_XRAY_ORDER_SEND''
    )
)
,
user_list as (
--利用者マスタ取得(pre_sqlにて取得)
select
	auth_info ->> ''user_id'' as user_id,
	auth_info ->> ''disp_user_id'' as disp_user_id
from
	json_array_elements(@userList::json) auth_info
)
,
staff_cd_list as (
--患者基本情報
select
	user_list.disp_user_id as disp_user_id,
	row_number() over(order by staff_info ->> ''disp_order'') as row_no
from
	pat_main pm
cross join jsonb_array_elements(pm.charge_staff_info) as staff_info
left join user_list on
	staff_info ->> ''staff_cd'' = user_list.user_id
where
	pm.facility_cd = @facilityCd
	and pm.pat_id = @patId
	and pm.is_del = ''0''
	and staff_info ->> ''is_main'' = ''1''
)
, rad_set_info as (
-- 患者放射線検査DB
select
	info ->> ''rad_set_cd'' as rad_set_cd
from 
	pat_rad_main prm
cross join lateral json_array_elements(prm.order_rad_set_info::json) info
where
	prm.pat_id = @patId
	and prm.facility_cd = @facilityCd
	and prm.is_del = ''0''
	and prm.rad_result_cd = @ordNo
)
,
rad_item_info as (
--放射線検査セットマスタ
select
	item_info ->> ''item_cd'' as item_cd,
	item_info ->> ''item_class'' as item_class
from
	mst_rad_set mrs
cross join lateral json_array_elements(mrs.rad_item_info::json) item_info
left join rad_set_info on
	(rad_set_info.rad_set_cd)::integer = mrs.rad_set_cd
where
	mrs.facility_cd = @facilityCd
	and mrs.is_del = ''0''
)
select
	case
		ini_value.user_id_flag
		when ''1'' then (
		--担当医の出力条件
			right(coalesce(
				(select disp_user_id from staff_cd_list where row_no = 1),
				(select disp_user_id from staff_cd_list where row_no = 2),
				(select value from coop_ini_info where key1 = ''SCM_COMMON'' and key2 = ''DEFAULT_DOCTOR''),
				''''), 6)
			)
		when ''0'' then (
		select
				user_list.disp_user_id
		from
				user_list
		where
				user_list.user_id = pm.ind_user_id::text
		limit 1
		)
	end as user_id,
	ini_value.title as title,
	to_char(pm.reg_rad_date, ''YYYY-MM-DD'') as reg_rad_date,
	(select item_cd from rad_item_info where item_class = ''部位'') as part_cd,
	(select item_cd from rad_item_info where item_class = ''修飾'') as mod_cd,
	(select item_cd from rad_item_info where item_class = ''方向'') as direction_cd,
	(select item_cd from rad_item_info where item_class = ''手技'') as procedure_cd
from
	(
	select
		(select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''USER_ID_FLAG'') as user_id_flag,
		(select value from coop_ini_info where key1 = ''SCM_COMMON'' and key2 = ''DEFAULT_DOCTOR'') as doctor_id,
		(select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''XRAY_IDX_TITLE'') as title) as ini_value
cross join user_list
cross join pat_rad_main pm
cross join rad_item_info rii
where
	pm.facility_cd = @facilityCd
	and pm.pat_id = @patId
limit 1
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100006, 'WITH coop_ini_info as (
--連携設定取得(pre_sqlにて取得)
SELECT
  coop_info ->> ''key1'' as key1,
  coop_info ->> ''key2'' as key2,
  coop_info ->> ''value'' as value
FROM
  json_array_elements(@coopIniInfo::json) coop_info
)
SELECT
  lpad((ppm.hosp_pat_id)::text, (ini_value.patid_len)::integer, ''0'') as hosp_pat_id,
  ppm.in_out_class as in_out_class
FROM
  (SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''PATID_LEN'') as patid_len
  ) as ini_value
CROSS JOIN pat_personal_main ppm
WHERE
  ppm.pat_id = @patId
  AND ppm.is_del = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coopIniInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100005, 'WITH get_coop_ini AS (
SELECT
  info ->> ''key1'' as key1,
  info ->> ''key2'' as key2,
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') as value
FROM
  mst_coop_ini as ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
)
SELECT jsonb_agg(get_coop_ini)::text AS coop_ini_info
FROM get_coop_ini', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（連携設定情報を取得）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100003, 'WITH get_users AS (
SELECT 
user_id,
disp_user_id
FROM 
mst_user_authentication
WHERE facility_cd = @facilityCd
)
SELECT jsonb_agg(get_users)::text AS user_list
FROM get_users', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（利用者マスタ（mst_user_authentication）を取得）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100000, 'WITH all_values as (
  SELECT
    coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value,
    info ->> ''key1'' as key1,
    info ->> ''key2'' as key2
  FROM
    mst_coop_ini as ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND coalesce(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' in (
      ''SCM_COMMON'',
      ''SCM_XRAY_ORDER_SEND''
    )
), jounal as (
  SELECT
    to_char(reg_date, ''YYYY-MM-DD'') as occur_date,
    to_char(reg_date, ''HH24:MI:SS'') as occur_time
  FROM
    sys_coop_journal
  WHERE
    ctl_no = @ctlNo
)
SELECT
  ini_value.hospital_id as hospital_id,
  ini_value.course_cd1 as course_cd1,
  ini_value.course_cd2 as course_cd2,
  jounal.occur_date as occur_date,
  jounal.occur_time as occur_time
FROM 
  (SELECT
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') as hospital_id,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') as course_cd1,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') as course_cd2) as ini_value
  CROSS JOIN jounal', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);