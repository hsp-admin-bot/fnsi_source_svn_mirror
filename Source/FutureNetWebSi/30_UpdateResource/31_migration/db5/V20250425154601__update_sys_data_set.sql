DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307084;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307085;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307087;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307089;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307084, 'select
  @modelType ||
  ''_'' ||
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
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, '[{"sql_cd": -307085, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307085, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307085, 'with ord_main_switch as(
    (
        select ord.rst_start_date,
            ord.rst_edition_date as up_date_switch
        from ord_main ord
        where ord.ord_no = @ordNo
    )
    union
    (
        select ord.rst_start_date,
            ord.del_date as up_date_switch
        from ord_main_restore as ord
            join sys_coop_journal as journal on ord.ord_no = journal.ord_no
        where ord.ord_no = @ordNo
            and journal.ctl_no = @ctlNo
            and ord.ord_no = journal.ord_no
            and journal.reg_date >= ord.del_date
        order by del_date desc
        limit 1
    )
    order by up_date_switch desc nulls last
    limit 1
)
, 
model_type as (
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''MODEL_TYPE''
)


select 
    to_char(ord.rst_start_date, ''YYYYMMDDHH24MISS'') as rst_start_date,
    ( select value from model_type ) as model_type
from ord_main_switch as ord
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307087, 'WITH ord_main_switch AS(
(
      SELECT
        ord.rst_in_out_class as rst_in_out_class,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.rst_in_out_class as rst_in_out_class,
        ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
,
input_code_class AS (
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
        WHEN (select value from input_code_class) = ''0'' THEN NULL
        WHEN ord.rst_in_out_class = 0 THEN ''外来''
        WHEN ord.rst_in_out_class = 1 THEN ''入院''
    END AS in_patient_flag
FROM
    ord_main_switch AS ord
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '受信区分取得用(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, NULL);
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
), ord_main_switch AS(
(
      SELECT
        ord.rst_course_cd as rst_course_cd,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
            ord.rst_course_cd as rst_course_cd,
            ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
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
from ord_main_switch ord
    join department_code_class dcc on TRUE
    join department_name_class dnc on TRUE
    join fixed_medical_code fmc on TRUE
    join fixed_medical_name fmn on TRUE
    left join mst_course mc on mc.course_cd = ord.rst_course_cd
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '診療科取得用(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, NULL);