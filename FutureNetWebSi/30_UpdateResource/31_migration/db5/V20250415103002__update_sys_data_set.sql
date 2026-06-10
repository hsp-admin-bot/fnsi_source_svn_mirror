-- 不要となった固定値を削除
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307086;

-- 不要になったSQL
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307010;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307011;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307012;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307013;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307014;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307015;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307018;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307019;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307020;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307021;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307022;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307023;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307024;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307025;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307026;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307027;

-- 修正分
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307009;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307017;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307008;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307016;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307009, 'WITH ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name = @application
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name = @application
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name = @application
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name = @application
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
        TO_NUMBER(datt.setting_value::text, ''999999999999'') as setting_value -- 設定値
    from (
            select TO_NUMBER(
                    (
                        unnest(
                            string_to_array(
                                (
                                    select mst_f.value as rtt
                                    from mst_facility_setting as mst_f
                                    where mst_f.facility_setting_no = ''3007''
                                        and mst_f.facility_cd = @facilityCd
                                ),
                                '',''
                            )
                        )
                    ),
                    ''999999999999''
                ) as setting_value
        ) as datt
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
    select medicine_cd,
        medicine_name,
        class_cd,
        medi_class_order.class_name as class_name,
        unit,
        in_hospital_cd_1,
        in_hospital_cd_2,
        in_hospital_cd_3,
        in_hospital_cd_4,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
),
final_medi_info as (
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        TRIM(
            TO_CHAR(SUM(amount), ''FM99999.99''),
            ''.''
        ) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        TRIM(
            TO_CHAR(amount, ''FM99999.99''),
            ''.''
        ) as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)
select ROW_NUMBER() OVER(
        order by case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 1
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 2
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 3
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 4
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 5
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 6 then f.date_interval
            end,
            case
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 0 then f.registration_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 1 then f.class_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 2 then f.medicine_type_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 3 then f.medi_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 4 then f.timing_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 5 then f.procedure_code_order
                when (
                    select setting_value
                    from facility_medicine_order
                    where setting_order = 7
                ) = 6 then f.date_interval
            end
    ) as seq_no,
    null as cutoff,
    f.code as code,
    f.name as name,
    f.count as count,
    f.unit as unit
from final_medi_info f', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307017, 'WITH ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
		100 + t.idx as registration_order,
		ord_medi_info ->> ''cd'' as medicine_cd,
		round((ord_medi_info ->> ''amount'') :: numeric, 2) as amount,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
		LEFT JOIN mst_medicine on ord_medi_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''procedure_name'' = @application
		and ord_medi_info ->> ''medicine_type'' = ''1''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
	select
		200 + t.idx as registration_order,
		ord_treatment_info ->> ''treat_medicine_cd'' as medicine_cd,
		round((ord_treatment_info ->> ''amount'') :: numeric, 2) as amount,
		mst_medicine.class_cd as class_cd,
		ord_treatment_info->>''medicine_type'' as medicine_type,
		null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
		null as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) WITH ORDINALITY as t(ord_treatment_info, idx)
		LEFT JOIN mst_medicine on ord_treatment_info ->> ''treat_medicine_cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
        and ord_treatment_info ->> ''procedure_name'' = @application
		and ord_treatment_info ->> ''medicine_type'' = ''1''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
	select
		100 + t.idx as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as amount,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
		LEFT JOIN mst_medicine_mix on ord_medi_info ->> ''cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''procedure_name'' = @application
		and ord_medi_info ->> ''medicine_type'' = ''2''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
	select
		200 + t.idx as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_treatment_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as amount,
		mst_medicine.class_cd as class_cd,
		ord_treatment_info->>''medicine_type'' as medicine_type,
		null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
		null as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info :: json)  WITH ORDINALITY as t(ord_treatment_info, idx)
		LEFT JOIN mst_medicine_mix on ord_treatment_info ->> ''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
        and ord_treatment_info ->> ''procedure_name'' = @application
		and ord_treatment_info ->> ''medicine_type'' = ''2''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
 )
 , medicine_in_hospital_cd_no as (
	--薬剤マスタの参照する連携コード
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MST''
		and info ->> ''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
 )
 , medicine_add_flag as (
	--薬剤合算フラグ
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info ->> ''key2'' = ''DISTINCT_MEDICINE_FLAG''
 )
 , facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select 
		row_number () over () as setting_order, -- 適用順 
        TO_NUMBER(datt.setting_value::text, ''999999999999'') as setting_value -- 設定値
    from (
            select TO_NUMBER(
                    (
                        unnest(
                            string_to_array(
                                (
                                    select mst_f.value as rtt
                                    from mst_facility_setting as mst_f
                                    where mst_f.facility_setting_no = ''3007''
                                        and mst_f.facility_cd = @facilityCd
                                ),
                                '',''
                            )
                        )
                    ),
                    ''999999999999''
                ) as setting_value
        ) as datt
 )
 , medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
 )
 , medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
 )
 , timing_order as (
    -- 投与タイミングマスタの並び順
  select
    index_no ::int as timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
  from mst_selector
  cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
  where facility_cd = @facilityCd
    and master_physical_name = ''mst_medicate_timing''
 )
 , procedure_order as (
    -- 手技マスタの並び順
  select
    index_no ::int as procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
  from mst_selector
  cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
  where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
 )
 , mst_medi as (
    select medicine_cd,
        medicine_name,
        class_cd,
        medi_class_order.class_name as class_name,
        unit,
        in_hospital_cd_1,
        in_hospital_cd_2,
        in_hospital_cd_3,
        in_hospital_cd_4,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
 )
 , final_medi_info as (
	select
		CASE
			(
				select
					value
				from
					medicine_in_hospital_cd_no
			)
			WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
			WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
			WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
			WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
		END as code,
		left(med.medicine_name, 80) as name,
		TRIM(
			TO_CHAR(
				SUM(amount),
				''FM99999.99''
			),
			''.''
		) as count,
		MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
		MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval 
	from
		ord_medi_infos omi
		LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd :: text
		left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where
		(
			select
				value
			from
				medicine_add_flag
		) = ''1''
	group by
		code,
		name
		union all
	select
		CASE
			(
				select
					value
				from
					medicine_in_hospital_cd_no
			)
			WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
			WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
			WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
			WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
		END as code,
		left(med.medicine_name, 80) as name,
		TRIM(
			TO_CHAR(
				amount,
				''FM99999.99''
			),
			''.''
		) as count,
		med.unit,
		med.class_cd,
		omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval 
	from
		ord_medi_infos omi
		LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd :: text
		left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where
		(
			select
				value
			from
				medicine_add_flag
		) = ''0''
 )

select 
    ROW_NUMBER() OVER(
        order by 
        case  
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end
    ) as seq_no,
    null as cutoff,
    f.code as code,
    f.name as name,
    f.count as count,
    f.unit as unit
from final_medi_info f
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307008, 'WITH output_medicine_classes as (
    -- 投薬情報で出力対象の薬剤区分
    select 
	info->>''key2'' as key2,
	coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' in (''ORAL'', ''PRN'', ''EXTERNAL'', ''SELF_INJECTION'')
),
order_units_id_suffix as (
-- order_units_idのサフィックス
    select case
            info->>''key2''
            when ''ORDER_UNITS_ID_00'' then (select value from output_medicine_classes where key2 = ''ORAL'')
            when ''ORDER_UNITS_ID_01'' then (select value from output_medicine_classes where key2 = ''PRN'')
            when ''ORDER_UNITS_ID_02'' then (select value from output_medicine_classes where key2 = ''EXTERNAL'')
            when ''ORDER_UNITS_ID_03'' then (select value from output_medicine_classes where key2 = ''SELF_INJECTION'')
        end as class_name,
        coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' in (
            ''ORDER_UNITS_ID_00'',
            ''ORDER_UNITS_ID_01'',
            ''ORDER_UNITS_ID_02'',
            ''ORDER_UNITS_ID_03''
        )
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
)
select distinct omi.class_name as application,
    lpad(@ordNo::text, 8, ''0'') || lpad(ouis.value, 2, ''0'') as order_units_id,
    ouis.value as order_id_suffix,
    @ordNo as ord_no,
    @key0 as key0,
    @facilityCd as facility_cd,
    case
        when omi.class_name = ( select value from output_medicine_classes where key2 = ''ORAL'' ) then ''01''
        when omi.class_name = ( select value from output_medicine_classes where key2 = ''PRN'' ) then ''02''
        when omi.class_name = ( select value from output_medicine_classes where key2 = ''EXTERNAL'' ) then ''03''
        when omi.class_name = ( select value from output_medicine_classes where key2 = ''SELF_INJECTION'' ) then ''04''
    end as detail_id
from ord_medi_infos omi
    left join order_units_id_suffix ouis on ouis.class_name = omi.class_name
order by ouis.value', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '投薬情報(Order_Unitsタグ)取得用', '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307016, 'WITH injection_procedure_names as (
-- 注射情報として出力する手技名称
    select
    info->>''key2'' as key2,
    coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' in (''IV_INJECTION'', ''IM_INJECTION'', ''ID_INJECTION'', ''SC_INJECTION'', ''IV_DRIP'', ''CUSTOM_MADE_MEDICATION'')
)
,
order_units_id_suffix as (
    -- 注射情報のOrder_Units_Idのサフィックス
    select case
            info->>''key2''
            when ''ORDER_UNITS_ID_20'' then (select value from injection_procedure_names where key2 = ''IV_INJECTION'')
            when ''ORDER_UNITS_ID_21'' then (select value from injection_procedure_names where key2 = ''IM_INJECTION'')
            when ''ORDER_UNITS_ID_22'' then (select value from injection_procedure_names where key2 = ''ID_INJECTION'')
            when ''ORDER_UNITS_ID_23'' then (select value from injection_procedure_names where key2 = ''SC_INJECTION'')
            when ''ORDER_UNITS_ID_24'' then (select value from injection_procedure_names where key2 = ''IV_DRIP'')
            when ''ORDER_UNITS_ID_25'' then (select value from injection_procedure_names where key2 = ''CUSTOM_MADE_MEDICATION'')
        end as procedure_name,
        coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' in (
            ''ORDER_UNITS_ID_20'',
            ''ORDER_UNITS_ID_21'',
            ''ORDER_UNITS_ID_22'',
            ''ORDER_UNITS_ID_23'',
            ''ORDER_UNITS_ID_24'',
            ''ORDER_UNITS_ID_25''
        )
),ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (select value from injection_procedure_names)
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        ord_treatment_info->>''procedure_name'' as procedure_name,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (select value from injection_procedure_names)
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (select value from injection_procedure_names)
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN round(
                (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info->>''amount'')::NUMERIC, 2)
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        ord_treatment_info->>''procedure_name'' as procedure_name,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (select value from injection_procedure_names)
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
)

select distinct
    omi.procedure_name as application,
    lpad(@ordNo::text, 8, ''0'') || lpad(ouis.value, 2, ''0'') as order_units_id,
    ouis.value as order_units_id_suffix,
    @ordNo as ord_no,
    @key0 as key0,
    @facilityCd as facility_cd,
    case omi.procedure_name 
        when (select value from injection_procedure_names where key2 = ''IV_INJECTION'') then ''01'' 
        when (select value from injection_procedure_names where key2 = ''IM_INJECTION'') then ''02''
        when (select value from injection_procedure_names where key2 = ''ID_INJECTION'') then ''03''
        when (select value from injection_procedure_names where key2 = ''SC_INJECTION'') then ''04''
        when (select value from injection_procedure_names where key2 = ''IV_DRIP'') then ''05''
        when (select value from injection_procedure_names where key2 = ''CUSTOM_MADE_MEDICATION'') then ''06''
end as detail_id
from ord_medi_infos omi
left join order_units_id_suffix ouis on ouis.procedure_name = omi.procedure_name
order by order_units_id_suffix
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307086, 'WITH all_values AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN (
            ''PRES_XML_BASIC_INFO'',
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_MEDICINE_INFO'',
            ''PRESCRIPTION_XML_INJECTION_INFO'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_SURGERY_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO'',
            ''PRESCRIPTION_XML_RECE_MNG_INFO''
        )
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''DEVICE_IDENTIFIER'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''MEDICINE'') AS category_name_medicine,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''INJECTION'') AS category_name_injection,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''TREATMENT'') AS category_name_treatment,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''HOLIDAY'') AS category_name_holiday,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''DIALYSIS'') AS category_name_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''CONSULTATION'') AS category_name_consultation,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''SURGERY'') AS category_name_surgery,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''EXAMINATION'') AS category_name_examination,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''TREATMENT'') AS prescription_details_treatment,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''OXYGEN'') AS prescription_details_oxygen,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''HOLIDAY'') AS prescription_details_holiday,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''DIALYSIS'') AS prescription_details_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CONSULTATION'') AS prescription_details_consultation,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''SURGERY'') AS prescription_details_surgery,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_treatment,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_SURGERY_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_surgery,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_oxygen,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_holi,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_dial
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2025-04-14 09:28:09.234', current_timestamp, NULL);