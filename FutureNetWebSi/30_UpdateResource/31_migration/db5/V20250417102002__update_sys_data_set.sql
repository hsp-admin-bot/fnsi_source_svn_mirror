DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307127;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307009;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307017;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307068;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307074;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307009, 'with default_medicine_group as (
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
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
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
            or ord_medi_info->>''procedure_name'' not in ( select value from injection_procedure_names )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in( select value from class_names )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
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
            when ''0'' then round((ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric, 2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
            when ''0'' then round((ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric, 2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
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
            or ord_medi_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric,2) as amount,
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
            or ord_treatment_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round((ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric,2)
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
            or ord_medi_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round((ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric,2)
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
            or ord_treatment_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
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
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
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
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
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
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
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
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
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
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        amount as count,
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
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)


select row_number() over(
        order by case
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
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
VALUES(-307017, 'WITH  default_medicine_group as (
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
        round((ord_medi_info->>''amount'')::numeric,2) as amount,
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
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
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
            when ''0'' then round((ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
            when ''0'' then round((ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric, 2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
		LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
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
		LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
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
		LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round((ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC, 2)
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
		LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round((ord_treatment_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC, 2)
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
	union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
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
		SUM(amount) as count,
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
		amount as count,
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
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
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
VALUES(-307068, 'with default_medicine_group as (
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
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
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
            or ord_medi_info->>''procedure_name'' not in ( select value from injection_procedure_names )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in( select value from class_names )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
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
            when ''0'' then round((ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric, 2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
            when ''0'' then round((ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric, 2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
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
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
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
            or ord_medi_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric,2) as amount,
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
            or ord_treatment_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round((ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric,2)
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
            or ord_medi_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round((ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,2)
            when ''1'' then round((medi_mix_info->>''amount'')::numeric,2)
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
            or ord_treatment_info->>''procedure_name'' not in (select value from injection_procedure_names)
        )
        and mst_medicine_class.class_name = @application
    union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
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
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
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
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
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
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
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
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
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
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        amount as count,
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
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)


select row_number() over(
        order by case
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
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
VALUES(-307074, 'WITH application_name as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''TREATMENT''
),
default_medicine_group as (
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
treatment_in_hospital_cd_alpha AS (
	-- 使用する治療方法の連携コードアルファベット
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS alpha_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_ALPHA''
),
treatment_in_hospital_cd_no AS (
	-- 使用する治療方法の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_NO''
),
addition_in_hospital_cd_no AS (
	-- 使用する加算/管理科項目の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
),
pat_dial_diff_data AS (
	-- 患者の透析困難情報
	SELECT obj->>''is_main'' AS is_main,
		obj->>''dial_diff_cd'' AS dial_diff_cd
	FROM (
			SELECT jsonb_array_elements(replace(@dialDiffCds, '''''''', ''"'')::jsonb) AS obj
		) t
),
mst_selector_dial_diff_data as (
	-- マスタ並び順から取得した透析困難
	select row_number() over () as sort_no,
		item->>''code'' as code,
		item->>''name'' as name,
		item->>''isDel'' as is_del,
		item->>''isDisp'' as is_disp
	from (
			select jsonb_array_elements(order_settings->''items'') as item
			from mst_selector
			where facility_cd = @facilityCd
				and master_physical_name = ''mst_dialysis_difficulty''
		) t
),
dial_diff_in_hospital_cd_no as (
	-- 使用する透析困難の連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYSIS_DIFFICULTY_HOSPITAL_CD_NO''
),
dialysis_output_setting as (
	-- 透析困難コメント・透析時間の出力設定
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		)::INTEGER as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
),
addition_info as(
	-- オーダから取得した加算・管理科情報
	select ord_addition_info->>''cd'' as code
	from ord_main
		cross join lateral json_array_elements(ord_main.addition_info::json) ord_addition_info
	where ord_main.ord_no = @ordNo
),
addition_key_value as(
	-- 加算項目キー
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as VALUE
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
		and info->>''key2'' = ''RECE_MNG_GENERAL_KEY''
),
add_treat_item_num as (
	-- 追加する治療項目数を取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''ADD_TREAT_ITEM_NUM''
),
key_nums as (
	-- 追加する治療項目数の数値"{0:D2}"を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value::integer
				from ADD_TREAT_ITEM_NUM
			)
		) as t(n)
),
target_keys as (
	-- 追加する治療項目のコードと名称を連携設定から取得するためのkeyを生成
	select ''ADD_TREAT_ITEM_CODE_'' || padded_num as code_key,
		''ADD_TREAT_ITEM_NAME_'' || padded_num as name_key
	from key_nums
),
flat_kv as (
	--	ADD_TREAT_ITEM_CODEとADD_TREAT_ITEM_NAMEのkey/valueの組み合わせを出力
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
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
),
code_values as (
	-- flat_kvからADD_TREAT_ITEM_CODEの値のみ抽出
	select key_nums.padded_num,
		kv.value as code
	from key_nums
		join target_keys on target_keys.code_key = ''ADD_TREAT_ITEM_CODE_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.code_key
),
name_values as (
	-- flat_kvからADD_TREAT_ITEM_NAMEの値のみ抽出
	select key_nums.padded_num,
		kv.value as name
	from key_nums
		join target_keys on target_keys.name_key = ''ADD_TREAT_ITEM_NAME_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.name_key
),
dialyzer_unit as (
	-- ダイアライザの単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as unit
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_UNIT''
),
dialyzer_in_hospital_cd_no as (
	--　使用するダイアライザの連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYZER_IN_HOSPITAL_CD_NO''
),
primary_membrane_info as (
	--１次膜の取得
	select rst_cond_info->''7''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
secondary_membrane_info as (
	--2次膜の取得
	select rst_cond_info->''8''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
equipment_in_hospital_cd_no as (
	--医療材料マスタの参照する連携コード
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''EQUIPMENT_IN_HOSPITAL_CD_NO''
),
column_count as (
	-- 吸着カラムの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''COLUMN_COUNT''
	limit 1
), column_info as (
	--吸着カラムの取得
	select null as idx,
		rst_cond_info->''6''->>''value'' as equipment_cd,
		cc.value as count
	from ord_main
		cross join column_count cc
	where ord_no = @ordNo
	and rst_cond_info->''6''->>''value'' != ''null''
),
equipment_info as (
	--穿刺針(SN)、穿刺針(SN以外)を除外した医療材料の取得
	select t.idx,
		t.equip_info->>''cd'' as equipment_cd,
		t.equip_info->>''amount'' as count
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_equip_info::json) with ordinality as t(equip_info, idx)
	where ord_no = @ordNo
		and is_del = ''0''
		and equip_info->>''class_type'' not in (''2'', ''3'')
),
medi_hospital_cd as (
	-- 使用する薬剤の連携コード番号
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
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
dialysate_info as (
	-- 透析液を取得
	select ord_main.rst_cond_info,
		mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		mst_treatment.device_mode
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''15''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''15''->>''medicine_type'' = ''1''
),
infusion_info as (
	-- 補液情報の抽出
	select mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		ord_main.rst_cond_info->''22''->>''value'' as raw_count_value
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''19''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''19''->>''medicine_type'' = ''1'' 
		and mst_treatment.device_mode not in (4, 7, 8, 10) -- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算するため出力しない
),
anticoagulant_info as (
	-- 抗凝固剤を抽出
	select ord_main.rst_cond_info->''25''->>''value'' as medicine_cd,
		ord_main.rst_cond_info->''25''->>''medicine_type'' as medicine_type,
		ord_main.rst_cond_info->''26''->>''value'' as one_shot,
		ord_main.rst_cond_info->''28''->>''value'' as total_dose
	from ord_main
	where ord_main.ord_no = @ordNo
),
direct_anticoagulant as (
	-- 通常薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		case
			when (ai.one_shot::numeric + ai.total_dose::numeric) % 1 = 0 then (ai.one_shot::numeric + ai.total_dose::numeric)::text
			else trim(
				trailing ''0''
				from (ai.one_shot::numeric + ai.total_dose::numeric)::text
			)
		end as count,
		med.unit as unit,
		mmc.class_type as class_type
	from anticoagulant_info ai
		left join mst_medicine med on ai.medicine_cd = med.medicine_cd::TEXT
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''1''
),
mixed_anticoagulant as (
	-- 調製薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0''
			or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then case
				when (mi.value->>''amount'')::numeric % 1 = 0 then (mi.value->>''amount'')::numeric::text
				else trim(
					trailing ''0''
					from ((mi.value->>''amount'')::numeric::text)
				)::text
			end
			when mi.value->>''solvent'' = ''0'' then case
				when (
					(ai.one_shot)::numeric + (ai.total_dose)::numeric
				) * (mi.value->>''amount'')::numeric % 1 = 0 then (
					(
						(ai.one_shot)::numeric + (ai.total_dose)::numeric
					) * (mi.value->>''amount'')::numeric
				)::text
				else trim(
					trailing ''0''
					from (
							(
								(ai.one_shot)::numeric + (ai.total_dose)::numeric
							) * (mi.value->>''amount'')::numeric
						)::text
				)
			end
			else null
		end as count,
		med.unit as unit,
		mmc.class_type as class_type
	from mst_medicine_mix mmm
		inner join anticoagulant_info ai on ai.medicine_cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''2''
),
medicine_add_flag as (
	-- 薬剤合算フラグ
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
		and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
	limit 1
), ord_medi_info as (
	-- 投与薬剤情報
	select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		ord_medi_info->>''cd'' as cd,
		ord_medi_info->>''name'' as name,
		ord_medi_info->>''amount'' as amount,
		ord_medi_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''medicine_type'' as medicine_type,
		ord_medi_info->>''timing_cd'' as timing_cd,
		ord_medi_info->>''procedure_cd'' as procedure_cd,
		ord_medi_info->>''date_interval'' as date_interval
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info::json) ord_medi_info
		inner join mst_medicine on (ord_medi_info->>''cd'')::numeric = mst_medicine.medicine_cd
	where ord_no = @ordNo
		and ord_medi_info->>''effect_flg'' = ''1''
	order by registration_order
),
ord_treat_info as (
	-- 愁訴処置情報
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		inner join mst_medicine on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine.medicine_cd
	where ord_no = @ordNo
	order by registration_order
),
facility_medicine_order as (
	-- 施設設定マスタ(No.107)
	select row_number () over () as setting_order -- 適用順 
,
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
	select index_no::int as timing_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
	select index_no::int as procedure_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
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
ord_treat_medi_info as (
	-- 投与薬剤情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		case
			when (omi.amount::numeric) % 1 = 0 then omi.amount
			else trim(
				trailing ''0''
				from (omi.amount)::text
			)
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from ord_medi_info omi
		left join mst_medicine med on omi.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''1''
	union all
	-- 投与薬剤情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0''
			or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then case
				when (mi.value->>''amount'')::numeric % 1 = 0 then (mi.value->>''amount'')::numeric::text
				else trim(
					trailing ''0''
					from ((mi.value->>''amount'')::numeric::text)
				)::text
			end
			when mi.value->>''solvent'' = ''0'' then case
				when (omi.amount)::numeric * (mi.value->>''amount'')::numeric % 1 = 0 then (
					(omi.amount)::numeric * (mi.value->>''amount'')::numeric
				)::text
				else trim(
					trailing ''0''
					from (
							(omi.amount)::numeric * (mi.value->>''amount'')::numeric
						)::text
				)
			end
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from mst_medicine_mix mmm
		inner join ord_medi_info omi on omi.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''2''
	union all
	-- 愁訴処置情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		case
			when (oti.amount::numeric) % 1 = 0 then oti.amount
			else trim(
				trailing ''0''
				from (oti.amount)::text
			)
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from ord_treat_info oti
		left join mst_medicine med on oti.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''1''
	union all
	-- 愁訴処置情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0''
			or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then case
				when (mi.value->>''amount'')::numeric % 1 = 0 then (mi.value->>''amount'')::numeric::text
				else trim(
					trailing ''0''
					from ((mi.value->>''amount'')::numeric::text)
				)::text
			end
			when mi.value->>''solvent'' = ''0'' then case
				when (oti.amount)::numeric * (mi.value->>''amount'')::numeric % 1 = 0 then (
					(oti.amount)::numeric * (mi.value->>''amount'')::numeric
				)::text
				else trim(
					trailing ''0''
					from (
							(oti.amount)::numeric * (mi.value->>''amount'')::numeric
						)::text
				)
			end
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from mst_medicine_mix mmm
		inner join ord_treat_info oti on oti.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''2''
),
unreferenced_medicines_with_order as (
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	select case
				(
					select value
					from medi_hospital_cd
				)
				when ''1'' then left(med.in_hospital_cd_1, 20)
				when ''2'' then left(med.in_hospital_cd_2, 20)
				when ''3'' then left(med.in_hospital_cd_3, 20)
			end as code,
			left(med.medicine_name, 80) as name,
			um.amount::text as count,
			med.unit as unit,
			mst_medi.class_cd as class_cd,
			mst_medi.class_name as class_name,
			um.registration_order::text as registration_order,
			mst_medi.medi_code_order as medi_code_order,
			mst_medi.medi_class_code_order as class_code_order,
			um.medicine_type as medicine_type_order,
			t.timing_code_order::text as timing_code_order,
			p.procedure_code_order::text as procedure_code_order,
			um.date_interval as date_interval
		from
			unreferenced_medicines um
			left join mst_medicine med on med.medicine_cd = um.medicine_cd::numeric
			left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
			left join timing_order t on t.timing_code = um.timing_cd::numeric
			left join procedure_order p on p.procedure_code = um.procedure_cd::numeric
		where
			(
			select
				value
			from
				default_medicine_group
		        ) = (select value from application_name)
),
final_treatment_info as (
	-- 処置として出力する対象の薬剤
	select o.code,
		o.name,
		SUM(o.count::numeric)::text as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select ord.code,
				ord.name,
				ord.count,
				ord.unit,
				ord.class_cd,
				ord.class_name,
				ord.registration_order,
				ord.medi_code_order,
				ord.class_code_order,
				ord.medicine_type_order,
				ord.timing_code_order,
				ord.procedure_code_order,
				ord.date_interval
			from ord_treat_medi_info ord
			where (
					select value
					from medicine_add_flag
				) = ''1'' -- medicine_add_flagが1の場合にのみ薬剤の合算を行う
			) as o
	where o.class_name in (
			select treatment_name
			from treatment_names
		)
	group by o.code,
		o.name
	union all
	select o.code,
		o.name,
		o.count,
		o.unit,
		o.class_cd,
		o.registration_order,
		o.medi_code_order,
		o.class_code_order,
		o.medicine_type_order,
		o.timing_code_order,
		o.procedure_code_order,
		o.date_interval
	from ord_treat_medi_info o
	where (
			select value
			from medicine_add_flag
		) = ''0''
		and o.class_name in (
			select treatment_name
			from treatment_names
		)
	union all
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	-- DEFAULT_MEDICINE_GROUP=''処置''の時のみ出力		
	select o.code,
		o.name,
		SUM(o.count::numeric)::text as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select um.code,
				um.name,
				um.count,
				um.unit,
				um.class_cd,
				um.class_name,
				um.registration_order,
				um.medi_code_order,
				um.class_code_order,
				um.medicine_type_order,
				um.timing_code_order,
				um.procedure_code_order,
				um.date_interval
			from unreferenced_medicines_with_order um
			where (
					select value
					from medicine_add_flag
				) = ''1'' 
			) as o
		group by o.code,o.name
	union all
	select um.code,
		um.name,
		um.count,
		um.unit,
		um.class_cd,
		um.registration_order,
		um.medi_code_order,
		um.class_code_order,
		um.medicine_type_order,
		um.timing_code_order,
		um.procedure_code_order,
		um.date_interval
	from unreferenced_medicines_with_order um
	where (
			select value
			from medicine_add_flag
		) = ''0''
	),
facility_equipment_order as (
	select row_number () over () as setting_order,
		TO_NUMBER(datt.a1::text, ''999999999999'') as setting_value
	from (
			select TO_NUMBER(
					(
						unnest(
							string_to_array(
								(
									select mst_f.value as rtt
									from mst_facility_setting as mst_f
									where mst_f.facility_setting_no = ''3006''
										and mst_f.facility_cd = @facilityCd
								),
								'',''
							)
						)
					),
					''999999999999''
				) as a1
		) as datt
),
equip_order as (
	select index_no::int as meq_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment''
),
equip_class_order as (
	select index_no::int as meq_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_class_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment_class''
),
mst_equip as (
	select equipment_cd,
		equipment_name,
		class_cd,
		unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		equip_order.meq_code_order,
		equip_class_order.meq_class_code_order
	from mst_equipment meq
		left join equip_order on meq.equipment_cd = equip_order.meq_code
		left join equip_class_order on meq.class_cd = equip_class_order.meq_class_code
	where facility_cd = @facilityCd
),
ord_equip_info as (
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		column_info.count::text as count,
		mst_equip.unit,
		column_info.idx as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from column_info
		left join mst_equip on column_info.equipment_cd = mst_equip.equipment_cd::text
	union all
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		equipment_info.count::text as count,
		mst_equip.unit,
		equipment_info.idx::text as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from equipment_info
		left join mst_equip on equipment_info.equipment_cd = mst_equip.equipment_cd::text
),
treatment_unit as (
	-- 治療項目単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_UNIT''
	limit 1
), disability_allowance as (
	-- 障害者加算
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DISABILITY_ALLOWANCE''
	limit 1
), diffcomment_count as (
	-- 透析困難コメントの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_COUNT''
	limit 1
), dialyzer_count as (
	-- ダイアライザの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_COUNT''
	limit 1
), val_filter_count as (
	-- １次膜、２次膜の数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''VAL_FILTER_COUNT''
	limit 1
), treat_all as (
	--治療項目情報
	select 1 as item_sort_no,
		case
			when iha.alpha_value = ''A''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_a1
			when iha.alpha_value = ''A''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_a2
			when iha.alpha_value = ''A''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_a3
			when iha.alpha_value = ''A''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_a4
			when iha.alpha_value = ''B''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_b1
			when iha.alpha_value = ''B''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_b2
			when iha.alpha_value = ''B''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_b3
			when iha.alpha_value = ''B''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_b4
			else mtt.in_hospital_cd_a1
		end as code,
		ord.rst_treatment_name as name,
		ord.rst_cond_info->''1''->>''value'' as count,
		tu.value as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join treatment_unit tu
		left outer join mst_treatment as mtt on mtt.treatment_cd = ord.rst_treatment_cd
		left join treatment_in_hospital_cd_alpha iha on true
		left join treatment_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
	union all
	-- 障害者加算
	select 2 as item_sort_no,
		case
			when ihn.no_value = ''1'' then madd.in_hospital_cd_1
			when ihn.no_value = ''2'' then madd.in_hospital_cd_2
			when ihn.no_value = ''3'' then madd.in_hospital_cd_3
			else null
		end as code,
		da.value as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join lateral json_array_elements(ord.addition_info::json) oadd
		cross join disability_allowance da
		left outer join mst_addition as madd on madd.addition_cd = to_number(oadd->>''cd'', ''9999999999'')
		left join addition_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
		and madd.addition_class = ''2''
	union all
	-- 透析困難コメント
	select 3 as item_sort_no,
		left(
			case
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 1 then mst_dialysis_difficulty.in_hospital_cd_1::VARCHAR
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 2 then mst_dialysis_difficulty.in_hospital_cd_2::VARCHAR
				else null
			end,
			20
		) as code,
		left(
			mst_dialysis_difficulty.dialysis_difficulty_name,
			256
		) as name,
		dc.value as count,
		null as unit,
		null as cutoff,
		lpad(
			(
				case
					when eddt.is_main = ''1'' then ''0''
					else ''1''
				end
			) || lpad(fddt.sort_no::text, 3, ''0''),
			4,
			''0''
		) as sort_key -- 並び順キー：is_main優先 → sort_no
	from mst_dialysis_difficulty
		cross join diffcomment_count dc
		inner join pat_dial_diff_data eddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (eddt.dial_diff_cd)::INTEGER
		inner join mst_selector_dial_diff_data fddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (fddt.code)::INTEGER
	where (
			select no_value
			from dialysis_output_setting
		)::numeric = 0 -- dialysis_output_setting が 「0」の場合のみ出力を行う。
	union all
	-- 透析液水質確保加算
	select 4 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
	where addition_info.code = mst_addition.addition_cd::text
		and mst_addition.addition_class = ''1''
	union all
	-- 下肢抹消動脈疾患指導管理加算
	select 5 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
		inner join addition_key_value on mst_addition.in_hospital_cd_2 in (
			addition_key_value.value::text
		)
	union all
	-- その他加算
	select 6 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from mst_addition
	where mst_addition.facility_cd = @facilityCd
		and mst_addition.addition_cd::TEXT in (
			select code
			from addition_info
		)
		and (
			not exists (
				select 1
				from addition_key_value akv
				where mst_addition.in_hospital_cd_2 = akv.value
			)
			or mst_addition.in_hospital_cd_2 is null
		)
	union all
	-- 加算する治療項目
	select 7 as item_sort_no,
		code_values.code as code,
		name_values.name as name,
		null as count,
		null as unit,
		null as cutoff,
		code_values.padded_num::text as sort_key
	from code_values
		join name_values on code_values.padded_num = name_values.padded_num
	union all
	-- 抗凝固剤 
	select 8 as item_sort_no,
		anticoagulant.code as code,
		anticoagulant.name as name,
		anticoagulant.count as count,
		anticoagulant.unit as unit,
		null as cutoff,
		lpad(anticoagulant.code, 20, ''0'') as sort_key
	from (
			select *
			from direct_anticoagulant
			union all
			select *
			from mixed_anticoagulant
		) anticoagulant
	where class_type = 1
	union all
	-- 透析液
	select 9 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		case
			-- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算
			when device_mode in (4, 7, 8, 10) then case
				when rst_cond_info->''17''->>''value'' is null
				or rst_cond_info->''22''->>''value'' is null then null
				when (
					(rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
				) % 1 = 0 then (
					(rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
				)::text
				else TRIM(
					trailing ''0''
					from (
							(rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
						)::text
				)::text
			end
			else case
				when ROUND(
					(rst_cond_info->''17''->>''value'')::numeric,
					2
				) % 1 = 0 then (rst_cond_info->''17''->>''value'')::text
				else TRIM(
					trailing ''0''
					from (rst_cond_info->''17''->>''value'')
				)::text
			end
		end as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from dialysate_info
	union all
	-- 補液
	select 10 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		case
			when ROUND(raw_count_value::numeric, 2) % 1 = 0 then raw_count_value::text
			else TRIM(
				trailing ''0''
				from raw_count_value
			)::text
		end as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from infusion_info
	union all
	-- 処置
	select 11 as item_sort_no,
		f.code as code,
		f.name as name,
		f.count as count,
		f.unit as unit,
		null as cotoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end
		)::text as sort_key
	from final_treatment_info f
	union all
	-- 消耗品
	select 12 as item_sort_no,
		oei.code as code,
		oei.name as name,
		oei.count::text as count,
		oei.unit as unit,
		null as cutoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 2 then oei.meq_code_order
				end
		)::text as sort_key
	from ord_equip_info oei
	union all
	-- ダイアライザ
	select 13 as item_sort_no,
		case
			when ihn.value = ''1'' then md.in_hospital_cd_1
			when ihn.value = ''2'' then md.in_hospital_cd_2
			when ihn.value = ''3'' then md.in_hospital_cd_3
			when ihn.value = ''4'' then md.in_hospital_cd_4
			else md.in_hospital_cd_1
		end as code,
		md.model_number as name,
		dc.value as count,
		du.unit as unit,
		null as cutoff,
		null as sort_key
	from (
			select rst_cond_info->''5'' as cond_info_5
			from ord_main
			where ord_no = @ordNo
		) t
		inner join mst_dialyzer md on md.dialyzer_cd = (t.cond_info_5->>''value'')::integer
		cross join dialyzer_unit du
		cross join dialyzer_count dc
		left join dialyzer_in_hospital_cd_no ihn on true
	union all
	-- １次膜、２次膜
	select 14 as item_sort_no,
		ord_info.code as code,
		ord_info.name as name,
		vfc.value as count,
		ord_info.unit as unit,
		null as cutoff,
		ord_info.sort_key as sort_key
	from (
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''1'' as sort_key
			from primary_membrane_info,
				mst_equipment
			where primary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
			union all
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''2'' as sort_key
			from secondary_membrane_info,
				mst_equipment
			where secondary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
		) ord_info
		cross join val_filter_count vfc
)

select treat_all.item_sort_no,
	treat_all.code as code,
	treat_all.name as name,
	treat_all.count as count,
	treat_all.unit as unit,
	treat_all.cutoff as cutoff,
	row_number() over (
		order by item_sort_no,
			sort_key
	) as seq_no
from treat_all 
order by seq_no;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom処方薬剤連携(処置・治療項目情報)', '2025-04-09 20:03:58.863', current_timestamp, '[{"sql_cd": -307033, "field_name": "dial_diff_cds", "replace_var": "@dialDiffCds"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307127, 'WITH default_medicine_group as (
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
	select treatment_name as value from treatment_names
	union
	select value from surgery_medicine_class_name
	union
	select value from medicine_classes
),
oxygen_procedure_value as(
    --酸素手技コードと酸素手技名称
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN_PROCEDURE''
),
oxygen_amount as (
    --酸素数量
    select SUM(
            (ord_rst_treatment_info->>''oxygen_amount'')::numeric
        ) as count
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_rst_treatment_info
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
),
oxygen_item_value as(
    --酸素薬剤コードと薬剤名
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN''
),
ord_medi_infos as (
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
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
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
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
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
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
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
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
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
        SUM(amount) as count,
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
        amount as count,
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
),
oxygen_all as (
    --酸素手技
    select 1 as item_sort_no,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_NAME''
        ) as name,
        null as count,
        null as unit,
        null as cutoff,
        null as sort_key
    union all
    --酸素
    select 2 as item_sort_no,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_NAME''
        ) as name,
        oxygen_amount.count as count,
        (
            select value
            from oxygen_item_value
            where key2 = ''UNIT''
        ) as unit,
        null as cutoff,
        null as sort_key
    from oxygen_amount
    union all
    --薬剤分類が未確認の薬剤
    select 3 as item_sort_no,
        f.code as code,
        f.name as name,
        f.count as count,
        f.unit as unit,
        null as cutoff,
        ROW_NUMBER() OVER(
            order by case
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::text
                end
        )::text as sort_key
    from final_medi_info f
    where (select value from default_medicine_group) = ''酸素''
)
select oxygen_all.code as code,
    oxygen_all.name as name,
    oxygen_all.count as count,
    oxygen_all.unit as unit,
    oxygen_all.cutoff as cutoff,
    row_number() over (
        order by item_sort_no,
            sort_key
    ) as seq_no
from oxygen_all
order by seq_no', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2025-04-14 09:19:01.203', current_timestamp, NULL);