DELETE FROM sys_data_set WHERE sql_cd IN (-1100000, -1103000);

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
      ''SCM_XRAY_ORDER_SEND'',
      ''SCM_CONV_UNIT_MEDI''
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
  ini_value.unit_medi as unit_medi,
  ini_value.xx_type_code as xx_type_code,
  jounal.occur_date as occur_date,
  jounal.occur_time as occur_time
FROM 
  (SELECT
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') as hospital_id,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') as course_cd1,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') as course_cd2,
    (SELECT value FROM all_values WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') as unit_medi,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''XX_TYPE_CODE'') as xx_type_code) as ini_value
  CROSS JOIN jounal', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103000, 'with coop_ini_info as (
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
	and info ->> ''key1'' in (''SCM_DIALYSISSEND_KARTE_NOTE'')
)
, orb_main_info as (
--治療情報から取得
select
	om.rst_weight_info ->> ''weight_before'' as weight_before,
	om.rst_weight_info ->> ''weight_after'' as weight_after,
	om.rst_weight_info ->> ''add_total'' as add_total,
	mv.va_name as va_name,
	om.rst_cond_info ->''3''->>''value'' as target_weight,
	om.rst_cond_info ->''14''->>''value'' as blood_flow,
	om.rst_cond_info ->''16''->>''value'' as alqd_flood_vol,
	om.rst_cond_info ->''20''->>''value'' as repl_amount,
	om.rst_cond_info ->''26''->>''value'' as anti_oneshot,
	om.rst_cond_info ->''27''->>''value'' as anti_speed,
	om.rst_cond_info ->''28''->>''value'' as anti_amount,
	om.rst_start_date as rst_start_date,
	om.rst_end_date as rst_end_date,
	om.rst_running_time as rst_running_time
from
	ord_main om
left join mst_va mv on om.rst_cond_info ->''2''->>''value'' = mv.va_cd::text
where
	om.ord_no = @ordNo
	and om.pat_id = @patId
	and om.is_del = ''0''
)
, mni_monitor_info as (
--装置モニタデータから取得
select
	data_type,
	monitor_data ->> ''90'' as b_max,
	monitor_data ->> ''91'' as b_min,
	monitor_data ->> ''92'' as b_ave,
	monitor_data ->> ''93'' as pulse
from
	mni_monitor mm
where
	mm.ord_no = @ordNo
	and mm.pat_id = @patId
	and mm.is_del = ''0''
)
select
	ini_value.free_word as free_word,
	omi.weight_before as weight_before,
	omi.weight_after as weight_after,
	COALESCE(vbefore.b_max, '''') || ''/'' || COALESCE(vbefore.b_min, '''') || ''/'' || COALESCE(vbefore.b_ave, '''') || ''('' || COALESCE(vbefore.pulse, '''') || '')'' as vital_before,
	COALESCE(vafter.b_max, '''') || ''/'' || COALESCE(vafter.b_min, '''') || ''/'' || COALESCE(vafter.b_ave, '''') || ''('' || COALESCE(vafter.pulse, '''') || '')'' as vital_after,
	omi.rst_start_date as rst_start_date,
	omi.rst_end_date as rst_end_date,
	omi.add_total as add_total,
	omi.rst_running_time as rst_running_time,
	omi.va_name as va_name,
	omi.target_weight as target_weight,
	omi.blood_flow as blood_flow,
	omi.alqd_flood_vol as alqd_flood_vol,
	omi.repl_amount as replenisher_amount,
	omi.anti_oneshot as anticoagulant_oneshot,
	omi.anti_speed as anticoagulant_speed,
	omi.anti_amount as anticoagulant_amount
from
	(select
		(select value from coop_ini_info where key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' and key2 = ''FREE_WORD'') as free_word
    ) as ini_value
	FULL OUTER JOIN (select b_max, b_min, b_ave, pulse from mni_monitor_info where data_type = ''5'' ) as vbefore ON TRUE
	FULL OUTER JOIN (select b_max, b_min, b_ave, pulse from mni_monitor_info where data_type = ''6'') as vafter ON TRUE
	cross join orb_main_info omi', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);