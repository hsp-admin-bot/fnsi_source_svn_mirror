DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-307008,  -307016, -307069, -307071, -307086);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307008, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
 order_units_num as (
    -- 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
order_unit_values as (
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
output_medicine_classes as (
    select idx.suffix,
        ouv.value
    from order_unit_values as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_'' || idx.suffix
),
order_units_id_suffix as (
    select idx.suffix,
        ouv.value
    from order_unit_values as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_ID_'' || idx.suffix
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
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
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
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
)
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select *
from 
(
	-- 投与薬剤に出力対象の未分類薬剤が存在した場合に取得
	select 
		omc.value as application,
        RIGHT((SELECT coop_ord_no FROM journal) || LPAD(COALESCE(NULLIF(BTRIM(ouis.value), ''''), ''0''), 2, ''0''),10) AS order_units_id,
		@ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		omc.suffix as detail_id
	from output_medicine_classes as omc
	left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
	where exists (
		select * from unreferenced_medicines
	)
		and omc.value = (select value from default_medicine_group)
	union 
	-- 投与薬剤に出力対象の薬剤が存在した場合に取得	
	select distinct 
		omi.class_name as application,
        RIGHT((SELECT coop_ord_no FROM journal) || LPAD(COALESCE(NULLIF(BTRIM(ouis.value), ''''), ''0''), 2, ''0''),10) AS order_units_id,
	    @ordNo as ord_no,
	    @key0 as key0,
	    @facilityCd as facility_cd,
	    omc.suffix as detail_id
	from ord_medi_infos as omi
	    left join output_medicine_classes as omc on omc.value = omi.class_name
	    left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
    ) t
order by detail_id;

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '投薬情報(Order_Unitsタグ)取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307016, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
), order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
prescription_xml_injection_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
order_units_id_suffix as (
    -- 注射情報のOrder_Units_Idのサフィックス
    select idx.suffix,
        ouv.value
    from prescription_xml_injection_info as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_ID_'' || idx.suffix
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
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
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
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        ord_treatment_info->>''procedure_name'' as procedure_name,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
)
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select *
from 
(
	-- 投与薬剤に出力対象の未分類薬剤が存在した場合に取得
	select 
		omc.value as application,
        RIGHT((SELECT coop_ord_no FROM journal) || LPAD(COALESCE(NULLIF(BTRIM(ouis.value), ''''), ''0''), 2, ''0''),10) AS order_units_id,
        @ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		omc.suffix as detail_id
	from injection_procedure_names as omc
	left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
	where exists (
		select * from unreferenced_medicines
	)
	and omc.value = (select value from default_medicine_group)
	union 
	-- 投与薬剤に出力対象の薬剤が存在した場合に取得	
	select distinct omi.procedure_name as application,
        RIGHT((SELECT coop_ord_no FROM journal) || LPAD(COALESCE(NULLIF(BTRIM(ouis.value), ''''), ''0''), 2, ''0''),10) AS order_units_id,
	    @ordNo as ord_no,
	    @key0 as key0,
	    @facilityCd as facility_cd,
	    ipn.suffix as detail_id
	from ord_medi_infos as omi
	    left join injection_procedure_names as ipn on ipn.value = omi.procedure_name
	    left join order_units_id_suffix as ouis on ouis.suffix = ipn.suffix
    ) t
order by detail_id;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307069, 'with ord_main_info as(
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
    LPAD((SELECT coop_ord_no FROM journal) || LPAD(((row_number() over (order by code::varchar) - 1 + rm_min_id.value::numeric)::text), 2, ''0''), 10, ''0'') AS order_units_id,
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
VALUES(-307071, 'WITH surgery_name as (
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
        and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
        and info ->> ''key2'' = ''SURGERY''
),order_units_id_suffix as (
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
        and info ->> ''key1'' = ''PRESCRIPTION_XML_SURGERY_INFO''
        and info ->> ''key2'' = ''ORDER_UNITS_ID''
)
,ord_medi_infos as (
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
		and ord_medi_info ->> ''medicine_type'' = ''1''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
		and (
			ord_medi_info ->> ''procedure_name'' is null
			OR ord_medi_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and ord_treatment_info ->> ''medicine_type'' = ''1''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
		and (
			ord_treatment_info ->> ''procedure_name'' is null
			OR ord_treatment_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and ord_medi_info ->> ''medicine_type'' = ''2''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
		and (
			ord_medi_info ->> ''procedure_name'' is null
			OR ord_medi_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and ord_treatment_info ->> ''medicine_type'' = ''2''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
		and (
			ord_treatment_info ->> ''procedure_name'' is null
			OR ord_treatment_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and mst_medicine_class.class_name = (select value from surgery_name)
 )
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
 select distinct
        RIGHT((SELECT coop_ord_no FROM journal) || LPAD(COALESCE(NULLIF(BTRIM(ouis.value), ''''), ''0''), 2, ''0''),10) AS order_units_id,
 		sn.value as application,
		@ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		''01'' as detail_id
 from ord_medi_infos omi
 cross join surgery_name sn
 cross join order_units_id_suffix ouis', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
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
            ''PRESCRIPTION_XML_BASIC_INFO'',
            ''PRESCRIPTION_INFO'',
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO''
        )
)
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_INFO'' AND key2 = ''MODEL_TYPE'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
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

    -- coop_ord_no 右8桁 + all_values 右2桁（治療）
    (
        LPAD(
            COALESCE(
                (SELECT RIGHT(coop_ord_no::text, 8) FROM journal LIMIT 1),
                ''0''
            ),
            8, ''0''
        )
        ||
        RIGHT(
            LPAD(
                COALESCE(
                    (SELECT NULLIF(REGEXP_REPLACE(value, ''\D'', '''', ''g''), '''')
                       FROM all_values
                      WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO''
                        AND key2 = ''ORDER_UNITS_ID''
                      LIMIT 1),
                    ''0''
                ),
                2, ''0''
            ),
            2
        )
    ) AS order_units_id_treatment,

    -- coop_ord_no 右8桁 + all_values 右2桁（酸素）
    (
        LPAD(
            COALESCE(
                (SELECT RIGHT(coop_ord_no::text, 8) FROM journal LIMIT 1),
                ''0''
            ),
            8, ''0''
        )
        ||
        RIGHT(
            LPAD(
                COALESCE(
                    (SELECT NULLIF(REGEXP_REPLACE(value, ''\D'', '''', ''g''), '''')
                       FROM all_values
                      WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO''
                        AND key2 = ''ORDER_UNITS_ID''
                      LIMIT 1),
                    ''0''
                ),
                2, ''0''
            ),
            2
        )
    ) AS order_units_id_oxygen,

    -- coop_ord_no 右8桁 + all_values 右2桁（休診）
    (
        LPAD(
            COALESCE(
                (SELECT RIGHT(coop_ord_no::text, 8) FROM journal LIMIT 1),
                ''0''
            ),
            8, ''0''
        )
        ||
        RIGHT(
            LPAD(
                COALESCE(
                    (SELECT NULLIF(REGEXP_REPLACE(value, ''\D'', '''', ''g''), '''')
                       FROM all_values
                      WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO''
                        AND key2 = ''ORDER_UNITS_ID''
                      LIMIT 1),
                    ''0''
                ),
                2, ''0''
            ),
            2
        )
    ) AS order_units_id_rece_holi,

    -- coop_ord_no 右8桁 + all_values 右2桁（透析）
    (
        LPAD(
            COALESCE(
                (SELECT RIGHT(coop_ord_no::text, 8) FROM journal LIMIT 1),
                ''0''
            ),
            8, ''0''
        )
        ||
        RIGHT(
            LPAD(
                COALESCE(
                    (SELECT NULLIF(REGEXP_REPLACE(value, ''\D'', '''', ''g''), '''')
                       FROM all_values
                      WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO''
                        AND key2 = ''ORDER_UNITS_ID''
                      LIMIT 1),
                    ''0''
                ),
                2, ''0''
            ),
            2
        )
    ) AS order_units_id_rece_dial;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);