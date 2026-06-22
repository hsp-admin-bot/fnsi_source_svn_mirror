DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307008;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307016;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307008, 'with order_units_num as (
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
select distinct omi.class_name as application,
    LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
    @ordNo as ord_no,
    @key0 as key0,
    @facilityCd as facility_cd,
    omc.suffix as detail_id
from ord_medi_infos as omi
    left join output_medicine_classes as omc on omc.value = omi.class_name
    left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
order by detail_id;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '投薬情報(Order_Unitsタグ)取得用', '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307016, 'with order_units_num as (
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
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        ouv.value
    from prescription_xml_injection_info as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_'' || idx.suffix
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
select distinct omi.procedure_name as application,
    LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
    ouis.value as order_units_id_suffix,
    @ordNo as ord_no,
    @key0 as key0,
    @facilityCd as facility_cd,
    ipn.suffix as detail_id
from ord_medi_infos as omi
    left join injection_procedure_names as ipn on ipn.value = omi.procedure_name
    left join order_units_id_suffix as ouis on ouis.suffix = ipn.suffix
order by detail_id;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);