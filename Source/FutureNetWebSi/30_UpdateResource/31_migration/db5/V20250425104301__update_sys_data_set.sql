DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307089;

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
        when dnc.value = ''0'' then 
            case when mc.course_name is not null then mc.course_name
            else fmn.value end
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
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '診療科取得用(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, NULL);