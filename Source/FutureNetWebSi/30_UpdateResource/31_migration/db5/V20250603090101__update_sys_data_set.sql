DELETE FROM sys_data_set WHERE sql_cd IN (-1103000, -1103001, -1103002);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103000, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_DIALYSISSEND'',
            ''SCM_COMMON'',
            ''SCM_DIALYSISSEND_KARTE_NOTE''
        ) 
)
, staff_cd_list AS (
  --担当医の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id,
        ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        staff_info ->> ''staff_cd'' = users ->> ''user_id''
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND staff_info ->> ''is_main'' = ''1''
)
, journal_staff_cd AS (
  --版確定者の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        sys_coop_journal AS journal
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        journal.user_id = (users ->> ''user_id'')::numeric
    WHERE
        journal.ctl_no = @ctlNo
        AND journal.facility_cd = @facilityCd
)
, ord_main_info AS (
    SELECT
        to_char(om.rst_start_date,''YYYY-MM-DD'') AS rst_start_date,
        to_char(om.rst_start_date, ''HH24:MI:SS'') AS rst_start_time,
        om.treat_date,
        mk.kur_standard_start_time,
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
        om.rst_end_date as rst_end_date,
        om.rst_running_time as rst_running_time
    FROM
        ord_main om
    left join mst_va mv on om.rst_cond_info ->''2''->>''value'' = mv.va_cd::text
    LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd
    WHERE
        om.ord_no = @ordNo
        AND om.facility_cd = @facilityCd
        AND mk.facility_cd = @facilityCd
		AND om.is_del = ''0''
        and om.pat_id = @patId
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
, coop_detail AS (
    SELECT
        save_2 ->> ''injection_send_day'' AS req_date,
        save_2 ->> ''injection_seq_no'' AS req_seq_no,
        save_2 ->> ''injection_user_id'' AS req_user_id
    FROM
        pat_coop_detail
    WHERE
        facility_cd = @facilityCd
)
SELECT
    RIGHT(
        CASE (SELECT value::numeric FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN 0 THEN 
            (SELECT disp_user_id FROM journal_staff_cd)
        WHEN 1 THEN 
            coalesce(
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1),
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2),
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR''),
            ''''
            )
        END
    ,6) AS user_id,
    omi.rst_start_date,
    omi.rst_start_time,
    omi.treat_date,
    omi.kur_standard_start_time,
    cd.req_date,
    cd.req_seq_no,
    cd.req_user_id,
    ini_value.free_word as free_word,
	omi.weight_before as weight_before,
	omi.weight_after as weight_after,
	COALESCE(vbefore.b_max, '''') || ''/'' || COALESCE(vbefore.b_min, '''') || ''/'' || COALESCE(vbefore.b_ave, '''') || ''('' || COALESCE(vbefore.pulse, '''') || '')'' as vital_before,
	COALESCE(vafter.b_max, '''') || ''/'' || COALESCE(vafter.b_min, '''') || ''/'' || COALESCE(vafter.b_ave, '''') || ''('' || COALESCE(vafter.pulse, '''') || '')'' as vital_after,
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
FROM
    (select
		(select value from coop_ini_info where key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' and key2 = ''FREE_WORD'') as free_word
    ) as ini_value
	FULL OUTER JOIN (select b_max, b_min, b_ave, pulse from mni_monitor_info where data_type = ''5'' ) as vbefore ON TRUE
	FULL OUTER JOIN (select b_max, b_min, b_ave, pulse from mni_monitor_info where data_type = ''6'') as vafter ON TRUE
	cross join ord_main_info omi
    cross join coop_detail cd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103001, 'WITH ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
        mst_medicine.in_hospital_cd_1 as medi_cd,
		round((ord_medi_info ->> ''amount'') :: numeric, 2) as medi_amount
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
		LEFT JOIN mst_medicine on ord_medi_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
        and ord_main.facility_cd = @facilityCd
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
		and mst_medicine.is_shot = ''1''
	UNION
	ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
	select
        mst_medicine.in_hospital_cd_1 as medi_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as medi_amount
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
		LEFT JOIN mst_medicine_mix on ord_medi_info ->> ''cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
	where
		ord_no = @ordNo
        and ord_main.facility_cd = @facilityCd
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
		and ord_medi_info ->> ''medicine_type'' = ''2''
        and mst_medicine.is_shot = ''1''
        and mst_medicine.is_disp = ''1''
 )
SELECT
    ROW_NUMBER() OVER(order by medi_cd) as seq_no,
    medi_cd,
    SUM(medi_amount) as medi_amount,
    @ordNo as ord_no,
    @facilityCd as facility_cd,
    ''01'' as detail_id
FROM
    ord_medi_infos
GROUP BY
    medi_cd
 ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103002, 'WITH ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
        mst_medicine.in_hospital_cd_1 as medi_cd,
		round((ord_medi_info ->> ''amount'') :: numeric, 2) as medi_amount
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
		LEFT JOIN mst_medicine on ord_medi_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
        and ord_main.facility_cd = @facilityCd
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
		and mst_medicine.is_shot = ''1''
	UNION
	ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
	select
        mst_medicine.in_hospital_cd_1 as medi_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as medi_amount
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
		LEFT JOIN mst_medicine_mix on ord_medi_info ->> ''cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
	where
		ord_no = @ordNo
        and ord_main.facility_cd = @facilityCd
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
		and ord_medi_info ->> ''medicine_type'' = ''2''
        and mst_medicine.is_shot = ''1''
        and mst_medicine.is_disp = ''1''
 )
,select_seq as (
SELECT
    ROW_NUMBER() OVER(order by medi_cd) as seq_no,
    medi_cd,
    SUM(medi_amount) as medi_amount
FROM
    ord_medi_infos
GROUP BY
    medi_cd
)
SELECT
    *
FROM
    select_seq
WHERE
 seq_no = @seqNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);