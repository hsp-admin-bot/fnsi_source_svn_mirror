DELETE FROM ntss.sys_data_set
WHERE sql_cd = -600403;


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600403, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, def_doctor AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''DEF_DOCTOR''
)
, def_course AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''DEF_COURSE''
)
, get_doctor AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''GET_DOCTOR''
)
, get_course AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''GET_COURSE''
)
, get_bed_code_conv AS (
    SELECT 
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''BED_CODE_CONV''
)
, bed_conversion AS (
    SELECT 
        om.ord_no,
        om.treat_date,
        CASE cibc.value
            WHEN ''1'' THEN mb.in_hospital_cd_1
            WHEN ''2'' THEN mb.in_hospital_cd_2
            ELSE NULL
        END AS converted_bed_cd
    FROM ord_main om
    JOIN mst_bed mb ON om.rst_bed_cd = mb.bed_cd
    CROSS JOIN get_bed_code_conv cibc
    WHERE om.ord_no = @ordNo
)
, rst_nec_bed_course AS ( --ベッド番号・科コード対応(実績)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT converted_bed_cd FROM bed_conversion)
)
, dialysis_course_cd AS (
    SELECT
        pm.medical_care_info ->>''dialysis_course_cd'' AS dialysis_course_cd
    FROM
        pat_main pm
    LEFT JOIN mst_course mc ON
        pm.medical_care_info ->>''dialysis_course_cd'' = mc.course_cd::TEXT
        AND mc.facility_cd = @facilityCd
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
)
, get_ind_department_cd AS (
    SELECT
        CASE
            (SELECT value FROM get_course)
            WHEN ''0'' THEN COALESCE(
                NULLIF(pcd.save_2->>''instruction_department'', ''''),
                (SELECT value FROM def_course)
            )
            WHEN ''1'' THEN COALESCE(
                (SELECT mc.in_hospital_cd_1 FROM mst_course mc WHERE mc.course_cd::TEXT = (SELECT dialysis_course_cd FROM dialysis_course_cd) AND mc.facility_cd = @facilityCd),
                (SELECT value FROM def_course)
            )
            WHEN ''2'' THEN COALESCE(
                NULLIF((SELECT value FROM rst_nec_bed_course), ''''),
                (SELECT value FROM def_course)
            )
        END AS ind_depart_code
    FROM
        pat_coop_detail pcd
    WHERE
        pcd.pat_id = @patId
        AND is_del = ''0''
        AND coop_version = @coopVersion
        AND to_char(up_date, ''yyyymmdd'') <= (SELECT treat_date FROM bed_conversion)
        ORDER BY up_date DESC
        LIMIT 1
)
, staff_cd_list AS (
    SELECT
        users ->> ''user_id'' AS user_id,
        ROW_NUMBER() OVER(ORDER BY VALUES ->> ''ctl_no'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS VALUES
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        VALUES ->> ''staff_cd'' = users ->> ''user_id''
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND VALUES ->> ''is_main'' = ''1''
)
, ind_send_doctor AS (
    SELECT
        CASE
            (@messageType::TEXT)
            WHEN ''1'' THEN encode(substring(scj.dump FROM 163 FOR 10), ''escape'')
            WHEN ''2'' THEN encode(substring(scj.dump FROM 131 FOR 10), ''escape'')
        END AS ind_doctor,
        accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor,
        0 AS accept_no
    ORDER BY
        accept_no DESC
    LIMIT 1
)
, get_request_userid AS (
    SELECT
        CASE (SELECT value FROM get_doctor)
            WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), ''deff'')
            WHEN ''1'' THEN COALESCE(
                NULLIF((SELECT user_id::TEXT FROM staff_cd_list WHERE row_no = ''1''), ''''),
                NULLIF((SELECT user_id::TEXT FROM staff_cd_list WHERE row_no = ''2''), ''''),
                ''deff''
            )
            WHEN ''2'' THEN COALESCE(
                NULLIF((SELECT trim(ind_doctor::TEXT) FROM ind_send_doctor), ''''),
                ''deff''
            )
        END AS ind_doctor
    FROM
        pat_coop_detail pcd
    WHERE
        pcd.pat_id = @patId
        AND is_del = ''0''
        AND coop_version = @coopVersion
        AND to_char(up_date, ''yyyymmdd'') <= (SELECT treat_date FROM bed_conversion)
        ORDER BY up_date DESC
        LIMIT 1
)
, collationed_userid AS (
    SELECT
        CASE
            WHEN co.ind_doctor = ''deff'' THEN (
                SELECT value FROM def_doctor
            )
            WHEN (SELECT value FROM get_doctor) = ''0'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''2'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''1'' THEN mpl ->> ''disp_user_id''
        END AS request_userid
    FROM
        (SELECT ind_doctor FROM get_request_userid) AS co
    LEFT JOIN jsonb_array_elements(@userList) AS mpl ON
        co.ind_doctor != ''deff''
        AND co.ind_doctor = mpl ->> ''user_id''
        AND (SELECT value FROM get_doctor) != ''2''
)
SELECT
    collationed_userid.request_userid,
    LEFT(get_ind_department_cd.ind_depart_code::TEXT, 2) AS ind_depart_code
FROM
    collationed_userid,
    get_ind_department_cd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析レポート連携院内コード取得', '2024-12-06 19:00:31.714', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);