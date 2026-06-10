DELETE FROM sys_data_set WHERE sql_cd IN (-600403, -102, -201, -202, -600118, -600600, -600601, 9106, 9107, -600111, -600110, -600117, -600700, 9119, 9205, -600506,-600513,-600514,-600515, -600119, 9105);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-600403, 'WITH coop_ini_info AS (
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
, get_EXAMINCODE_POSITION AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''USER_COOP_CD_NO''
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
)
, collationed_userid AS (
    SELECT
        CASE
            WHEN co.ind_doctor = ''deff'' THEN (
                SELECT value FROM def_doctor
            )
            WHEN (SELECT value FROM get_doctor) = ''0'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''2'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''1'' THEN 
            	CASE (SELECT value FROM get_EXAMINCODE_POSITION)
                WHEN ''1'' THEN mpl ->> ''in_hospital_cd_1''
                WHEN ''2'' THEN mpl ->> ''in_hospital_cd_2''
            END
        END AS request_userid
    FROM
        (SELECT ind_doctor FROM get_request_userid) AS co
    LEFT JOIN jsonb_array_elements(@mstPersonalList) AS mpl ON
        co.ind_doctor != ''deff''
        AND co.ind_doctor = mpl ->> ''user_id''
        AND (SELECT value FROM get_doctor) != ''2''
)
, bed_conversion AS (
    SELECT 
        om.ord_no,
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
)
SELECT
    collationed_userid.request_userid,
    LEFT(get_ind_department_cd.ind_depart_code::TEXT, 2) AS ind_depart_code
FROM
    collationed_userid,
    get_ind_department_cd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析レポート連携院内コード取得', '2024-12-06 19:00:31.714', '2024-12-06 19:00:31.714', '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -600404, "field_name": "user_list", "replace_var": "@mstPersonalList"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-102, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, get_course AS ( --指示科取得先設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_COURSE''
)
, def_course AS ( --デフォルト指示科
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_COURSE''
)
, get_XMLGEN_obj_type AS ( --データ種別
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_OBJ_TYP''
)
, get_XMLGEN_cd as ( -- システム識別子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_SYSTEM_CODE''
)
, get_XMLGEN_hosp_cd as ( -- 施設コード
    SELECT btrim(value) as value
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_HOSP_CODE''
)
,bed_code_conv as (
    SELECT *
    FROM coop_ini_info 
    WHERE key2 = ''BED_CODE_CONV''
)
, get_bed_mst as ( -- ベッドマスタ
    SELECT
    bed_cd as bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT ind_bed_cd FROM ord_main WHERE ord_no = @ordNo)
)
, ind_nec_bed_course AS ( --ベッド番号・科コード対応(指示)
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
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM get_bed_mst)::text
)
, rst_nec_bed_cd AS (
    SELECT
    bed_cd AS bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT rst_bed_cd FROM ord_main WHERE ord_no = @ordNo)
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
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_nec_bed_cd)
)
, rst_del_nec_bed_cd AS (
    (
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
            , ord.del_date AS up_date
        FROM ord_main_restore AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON ord.rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY ord.del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
            , ord.rst_edition_date AS up_date
        FROM ord_main AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
    )
    ORDER BY up_date DESC
    LIMIT 1
)
, rst_del_nec_bed_course AS ( --ベッド番号・科コード対応(実績_削除時)
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
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_del_nec_bed_cd)::text
)
, get_doctor AS ( --指示医取得設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_DOCTOR''
)
, def_doctor AS ( --デフォルト指示医
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_DOCTOR''
)
, dialysis_course_cd AS ( --透析実施科
    SELECT
        mc.in_hospital_cd_1 AS dialysis_course_cd
    FROM pat_main pm
    LEFT JOIN mst_course mc
    ON pm.medical_care_info ->> ''dialysis_course_cd'' = mc.course_cd::text
    AND mc.facility_cd = @facilityCd
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
)
, staff_cd_list AS ( --担当医1,2
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
        , users ->> ''user_id'' AS user_id
        , row_number() OVER(ORDER BY values ->> ''disp_order'') AS row_no
    FROM pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS values
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON values ->> ''staff_cd'' = users ->> ''user_id''
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
    AND values ->> ''is_main'' = ''1''
)
,up_ind_user_id AS ( --最終更新指示者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_ind_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
,up_user_id AS ( --最終更新者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
, ind_send_doctor_v1 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 163 for 10), ''escape'') AS ind_doctor
        , accept_no
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
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, ind_send_doctor_v2 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 131 for 10), ''escape'') AS ind_doctor
        , accept_no
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
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, def_update_terminal AS ( --デフォルト更新端末
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_UPDATE_TERMINAL''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, own_expense_medicine_code_list AS (
    SELECT unnest(string_to_array(value, '','')) AS split_cd
    FROM coop_ini_info
    WHERE key2 = ''OWN_EXPENSE_MEDICINE_CODE''
)
, get_XMLGEN_title_cd AS ( -- タイトル識別コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_CODE''
)
, get_XMLGEN_title_name AS ( -- タイトル識別名称
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_NAME''
)
, get_XMLGEN_fs_disp AS ( -- フローシート表示文字列
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_FS_DISP''
)
, get_XMLGEN_content_number AS ( -- 識別番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_NUMBER''
)
, get_XMLGEN_content_type AS ( -- コンテンツタイプ
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_TYPE''
)
, get_XMLGEN_extent_name AS ( -- 拡張子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_EXTENT_NAME''
)
, get_XMLGEN_device_name AS ( -- デバイス名
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_DEVICE_NAME''
)
, get_XMLGEN_ip_address AS ( -- IPアドレス
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_IP_ADDRESS''
)
, medicine_order as (
    SELECT
    t.value ->> ''code'' AS cd
    , t.idx AS idx
    FROM mst_selector ms
    CROSS JOIN jsonb_array_elements(ms.order_settings -> ''items'') WITH ORDINALITY AS t(value,idx)
    WHERE ms.facility_cd =@facilityCd
    AND ms.master_physical_name = ''mst_medicine''
)
, own_expense_medicine_code AS (
    SELECT
    CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1
        WHEN ''2'' THEN mmd.in_hospital_cd_2
        WHEN ''3'' THEN mmd.in_hospital_cd_3
        WHEN ''4'' THEN mmd.in_hospital_cd_4
        END AS own_med_cd
    , mco.idx AS idx
    from own_expense_medicine_code_list oemc
    inner JOIN mst_medicine mmd
    ON (CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1 = oemc.split_cd
        WHEN ''2'' THEN mmd.in_hospital_cd_2 = oemc.split_cd
        WHEN ''3'' THEN mmd.in_hospital_cd_3 = oemc.split_cd
        WHEN ''4'' THEN mmd.in_hospital_cd_4 = oemc.split_cd
        END)
    LEFT JOIN medicine_order mco
    ON mmd.medicine_cd::text = mco.cd
    UNION
    SELECT '''' AS own_med_cd, 0 AS idx
)
, orderreqsend_start_end_flg AS ( --開始日終了日設定フラグ 
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ORDERREQSEND_START_END_FLG''
)
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    pcd.save_2->>''updater'' as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    pcd.save_2->>''update_terminal'' as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V1_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(
            NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS ind_doctor_generation_no,
    --rst_dial_V1_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS rst_doctor_generation_no,
    '''' AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM
    pat_coop_detail pcd
WHERE
    pcd.pat_id = @patId
    AND is_del = ''0''
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    AND ''1'' = @messageType
UNION
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    (SELECT disp_user_id FROM up_user_id) as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    (SELECT value FROM def_update_terminal) as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V2_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN NULL
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    ''0'' AS ind_doctor_generation_no,
    --rst_dial_V2_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    ''0'' AS rst_doctor_generation_no,
    CASE WHEN (SELECT count(*) FROM own_expense_medicine_code) = 1
    THEN ''   ''
    ELSE (SELECT own_med_cd FROM own_expense_medicine_code WHERE idx <> 0 ORDER BY idx LIMIT 1)
    END AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM pat_coop_detail pcd
WHERE pcd.pat_id = @patId
    AND is_del = ''0''
    AND coop_version = @coopVersion
    AND ''2'' = @messageType
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者補完情報20個', '2024-12-09 16:44:42.537', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);


INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-201, 'WITH trend_interval_value AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND info->>''key2'' = ''TREND_INTERVAL''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
)
,coop_ini_extracted AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value,
        info->>''value'' AS value,
        info->>''default_v'' AS default_v,
        CASE
            WHEN info->>''key2'' = ''BP_MAX_VAITAL_CD'' THEN ''90''
            WHEN info->>''key2'' = ''BP_MIN_VAITAL_CD'' THEN ''91''
            WHEN info->>''key2'' = ''PULSE_VAITAL_CD'' THEN ''93''
            WHEN info->>''key2'' = ''TEMPERATURE_VAITAL_CD'' THEN ''94''
            WHEN info->>''key2'' = ''ELAPSED_TIME_VAITAL_CD'' THEN ''1''
            WHEN info->>''key2'' = ''TREAT_MODE_VAITAL_CD'' THEN ''31''
            WHEN info->>''key2'' = ''BLOOD_FLOW_VAITAL_CD'' THEN ''8''
            WHEN info->>''key2'' = ''OFFWATER_SPEED_VAITAL_CD'' THEN ''33''
            WHEN info->>''key2'' = ''OFFWATER_ADD_VAITAL_CD'' THEN ''5''
            WHEN info->>''key2'' = ''OFFWATER_TERGET_VAITAL_CD'' THEN ''32''
            WHEN info->>''key2'' = ''VENOUS_PRESSURE_VAITAL_CD'' THEN ''11''
            WHEN info->>''key2'' = ''DIALYSATE_PRESSURE_VAITAL_CD'' THEN ''12''
            WHEN info->>''key2'' = ''TMP_VAITAL_CD'' THEN ''13''
            WHEN info->>''key2'' = ''IP_TOTAL_AMOUNT_VAITAL_CD'' THEN ''9''
            WHEN info->>''key2'' = ''IP_SPEED_VAITAL_CD'' THEN ''37''
            WHEN info->>''key2'' = ''DIALYSATE_TEMPERATURE_VAITAL_CD'' THEN ''21''
            WHEN info->>''key2'' = ''NA_CONCENTRATION_VAITAL_CD'' THEN ''20''
            WHEN info->>''key2'' = ''DIALYSATE_FLOW_VAITAL_CD'' THEN ''22''
            WHEN info->>''key2'' = ''REPLENISH_SPEED_VAITAL_CD'' THEN ''73''
            WHEN info->>''key2'' = ''REPLENISH_VALUE_VAITAL_CD'' THEN ''72''
            WHEN info->>''key2'' = ''REPLENISH_TEMPERATURE_VAITAL_CD'' THEN ''74''
            WHEN info->>''key2'' = ''DELTA_BV_VAITAL_CD'' THEN ''17''
            WHEN info->>''key2'' = ''DELTA_BV_CHANGE_RATE_CD'' THEN ''80''
            WHEN info->>''key2'' = ''WEIGHT_BEFORE_VAITAL_CD'' THEN ''WEIGHT_BEFORE_VAITAL_CD''
            WHEN info->>''key2'' = ''WEIGHT_AFTER_VAITAL_CD'' THEN ''WEIGHT_AFTER_VAITAL_CD''
            ELSE NULL
        END AS target_key
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
        AND COALESCE(NULLIF(info->>''value'', ''''), NULL) IS NOT NULL
)
,query_1_processed AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        CASE
            WHEN to_number(vit_ini.target_key, ''999'') IN (94)
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.0'')
            ELSE
                monitor_data->>vit_ini.target_key
        END AS vital_data,
        to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
        vital_all.occur_date AS occur_time_with_sec
    FROM (
        SELECT
            occur_date,
            monitor_data
        FROM
            mni_monitor
        WHERE
            1 = 1
            AND ord_no = @ordNo
            AND data_type IN (0, 2, 4, 5, 6)
            AND is_del = ''0''
    ) AS vital_all
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            1 = 1
            AND target_key IS NOT NULL
    ) AS vit_ini
    WHERE
        1 = 1
        AND vit_ini.target_key IS NOT NULL
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
)
,query_1_ranked AS (
    SELECT
        detail_id,
        vital_cd,
        vital_data,
        occur_date,
        occur_time_with_sec,
        ROW_NUMBER() OVER (
            PARTITION BY vital_cd, occur_date
            ORDER BY occur_time_with_sec DESC
        ) AS rank_within_time
    FROM
        query_1_processed
)
,query_1_filled AS (
    SELECT
        detail_id,
        vital_cd,
        occur_date,
        FIRST_VALUE(vital_data) OVER (
			PARTITION BY vital_cd, occur_time_with_sec 
            ORDER BY occur_time_with_sec DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS vital_data
    FROM query_1_ranked
    WHERE rank_within_time = 1
    ORDER BY occur_date ASC , vital_cd ASC
)
, query_1_final AS (
SELECT
    occur_date,
    detail_id,
    vital_cd,
    vital_data
FROM
    query_1_filled
ORDER BY
    occur_date,
    vital_cd
)
, query_2 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS bw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_before'' AS NUMERIC), ''FM999999999.00'') AS bw_w,
        to_char((ord.rst_weight_info->>''weight_before_date'')::timestamp, ''YYYYMMDDHH24MI'') AS bw_date
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''WEIGHT_BEFORE_VAITAL_CD''
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_before_date'', ''NODATE'') <> ''NODATE''
)
,query_3 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS aw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_after'' AS NUMERIC), ''FM999999999.00'') AS aw_w,
        to_char((ord.rst_weight_info->>''weight_after_date'')::timestamp, ''YYYYMMDDHH24MI'') AS aw_date
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''WEIGHT_AFTER_VAITAL_CD''
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_after_date'', ''NODATE'') <> ''NODATE''
)
, query_4 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        CASE
		    WHEN to_number(vit_ini.target_key, ''999'') IN (5, 32, 33, 73) THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.00'')
		    WHEN to_number(vit_ini.target_key, ''999'') IN (9, 17, 37, 60, 72, 74, 80) THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.0'')
		    WHEN vit_ini.target_key = ''31'' THEN 
		        CASE
		            WHEN monitor_data->>vit_ini.target_key = ''0'' THEN ''HD''
		            WHEN monitor_data->>vit_ini.target_key = ''1'' THEN ''ECUM''
		            WHEN monitor_data->>vit_ini.target_key = ''2'' THEN ''ｵﾌﾗｲﾝHDF''
		            WHEN monitor_data->>vit_ini.target_key = ''3'' THEN ''ｵﾌﾗｲﾝHF''
		            WHEN monitor_data->>vit_ini.target_key = ''6'' THEN ''AFBF''
		            WHEN monitor_data->>vit_ini.target_key = ''7'' THEN ''ｵﾝﾗｲﾝHDF''
		            WHEN monitor_data->>vit_ini.target_key = ''8'' THEN ''ｵﾝﾗｲﾝHF''
		            WHEN monitor_data->>vit_ini.target_key = ''10'' THEN ''IHDF''
		            ELSE monitor_data->>vit_ini.target_key
		        END
		    ELSE 
		        monitor_data->>vit_ini.target_key
		END AS vital_data,
        monitor_data,
        vital_all.occur_date
    FROM (
        SELECT
            to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
            monitor_data
        FROM
            mni_monitor
        WHERE
            1 = 1
            AND ord_no = @ordNo
            AND data_type = 1
            AND is_del = ''0''
    ) AS vital_all
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            1 = 1
            AND target_key IS NOT NULL
    ) AS vit_ini
    JOIN trend_interval_value ON TRUE
    WHERE
        1 = 1
        AND vit_ini.target_key IS NOT NULL
        AND to_number(monitor_data->>''1'', ''999'') > 0
        AND (to_number(monitor_data->>''1'', ''999'') % trend_interval_value.trend_value::numeric = 0)
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
)
,query_4_sorted AS (
    SELECT
        detail_id, vital_cd, vital_data, occur_date, monitor_data
    FROM (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY monitor_data->>''1'' ORDER BY occur_date ASC) AS rank_within_value,
            MAX(occur_date) OVER () AS max_occur_date
        FROM query_4
    ) AS ranked
    WHERE
        1 = 1
        AND rank_within_value = 1
        AND occur_date <> max_occur_date
    ORDER BY
        occur_date,
        vital_cd
)
SELECT * FROM query_1_final
UNION ALL
SELECT * FROM query_2
UNION ALL
SELECT * FROM query_3
UNION ALL
SELECT detail_id, vital_cd, vital_data, occur_date FROM query_4_sorted', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)バイタル繰り返し部', '2024-11-26 14:03:54.146', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-202, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NEC''
)
, sendmsg_gen AS ( --項目世代番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''SENDMSG_GEN''
)
, func_addition AS ( --加算(患者)機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ADDITION''
)
, va_coop_cd_no AS ( --VAの連携コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_COOP_CD_NO''
)
, va_func_cd_no AS ( --VAの機能コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_FUNC_CD_NO''
)
, func_bloodaccess AS ( --VAの機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_BLOODACCESS''
)
, treatment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_COOP_CD_NO''
)
, treatment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_FUNC_CD_NO''
)
, func_treat AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_TREAT''
)
, dialyzer_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_COOP_CD_NO''
)
, dialyzer_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_FUNC_CD_NO''
)
, func_dialyzer AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYZER''
)
, other_dialyzer_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYZER_UNIT''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, medicine_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_FUNC_CD_NO''
)
, func_medicine AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_MEDICINE''
)
, func_koucoagulant AS ( --抗凝固剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
)
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
)
, num_auto_calc AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
)
, num_auto_calc_ranges AS ( --透析液量自動計算
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS range_string
        , info ->> ''key2'' AS cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
        AND info ->> ''key2'' <> ''AUTO_CALC_FLG''
)
, parsed_ranges_check_1 AS ( --透析液量自動計算設定チェック
    SELECT
        CASE WHEN split_part(value, '':'', 1) ~ ''^\d+(\.\d+)?$''
        THEN NULLIF(split_part(value, '':'', 1), '''')
        ELSE NULL
        END AS lower_bound,
        CASE WHEN split_part(value, '':'', 2) ~ ''^\d+(\.\d+)?$''
        THEN NULLIF(split_part(value, '':'', 2), '''')
        ELSE NULL
        END AS value,
        ranges.cd
    FROM num_auto_calc_ranges ranges
    CROSS JOIN unnest(string_to_array(range_string, ''/'')) AS value
)
, parsed_ranges_check_2 AS ( --透析液量自動計算設定チェック
    SELECT distinct
        cd,
        ''NG'' AS check_result
    FROM parsed_ranges_check_1
    WHERE lower_bound IS NULL
        OR value IS NULL
)
, parsed_ranges AS ( --透析液量自動計算
    SELECT
        split_part(value, '':'', 1)::numeric AS lower_bound,
        split_part(value, '':'', 2)::numeric AS value,
        lead(split_part(value, '':'', 1)::numeric, 1, 100000) OVER (PARTITION BY ranges.cd ORDER BY split_part(value, '':'', 1)::numeric) -0.0001 AS upper_bound,
        ranges.cd
    FROM num_auto_calc_ranges ranges
    LEFT JOIN parsed_ranges_check_2 on ranges.cd = parsed_ranges_check_2.cd
    CROSS JOIN unnest(string_to_array(range_string, ''/'')) AS value
    WHERE parsed_ranges_check_2.check_result IS NULL
)
, rst_minutes as ( --透析時間(分)
    SELECT TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999999999'') as minutes
    FROM ord_main ord
    WHERE ord_no = @ordNo
)
, parsed_table AS ( --透析液量自動計算
    SELECT pr.value, pr.cd
    FROM parsed_ranges pr, rst_minutes
    WHERE rst_minutes.minutes BETWEEN pr.lower_bound AND pr.upper_bound
)
, oxygen_code AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_CODE''
)
, oxygen_used_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_USED_UNIT''
)
, equipment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_COOP_CD_NO''
)
, equipment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_FUNC_CD_NO''
)
, func_aneedle AS ( --穿刺針
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANEEDLE''
)
, func_consumption AS ( --医療材料
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_CONSUMPTION''
)
, func_another_add AS ( --時間外薬剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANOTHER_ADD''
)
, addmed_cd as ( --時間外薬剤コードリスト
	select *
	FROM coop_ini_info
	WHERE key2 like ''MEDICINE_ADDMED_CODE%''
)
, difficult_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_COOP_CD_NO''
)
, difficult_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_FUNC_CD_NO''
)
, addition_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_COOP_CD_NO''
)
, addition_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_FUNC_CD_NO''
)
, other_dialysis_time AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_TIME''
)
, other_dialysis_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_UNIT''
)
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
)
, other_off_water AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER''
)
, other_off_water_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER_UNIT''
)
, func_item_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ITEM_COMMENT''
)
, func_dialysis_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT''
)
, func_dialysis_comment2 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT2''
)
, func_dialysis_comment3 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT3''
)
, equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  WHERE facility_cd = @facilityCd
)
, medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS a1
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
, pcd_save_3 AS (
  SELECT
    t.values ->> ''item_code'' as item_code
    , t.values ->> ''function_code'' as function_code
    , t.values ->> ''item_generation'' as item_generation
    , t.idx as idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) with ORDINALITY AS t(values, idx)
  WHERE pat_id = @patId
)
SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.*
FROM
  (
    SELECT
      all_cost.*
    FROM
      (
        SELECT
          --加算(患者)Ver1
          ''実績詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''01'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''20''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --VA情報
          ''実績詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION ALL
        SELECT
          --透析方法
          ''実績詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2'' 
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END AS e1 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM treatment_func_cd_no)
            WHEN ''1''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''2''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                ELSE NULL
                END
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.rst_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --医材内ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
        UNION ALL
        SELECT
          --抗凝固剤
          ''実績詳細'' AS detail_id
          , ''抗凝固剤''
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03 --機能コード
          , koucoagulant.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''26'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , (SELECT value ::text FROM other_koucoagulant_speed_unit) AS e07
          , ''06'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --抗凝固剤(単独分）
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
              (
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
              )
            , ''FM00000V9999'') AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text
        UNION ALL
        SELECT
          --薬剤
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
              END
            ELSE CASE (SELECT value FROM medicine_func_cd_no) --時間外薬剤
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_another_add))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_another_add))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_another_add))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_another_add))
              END
            END AS e03 --機能コード
          , CASE (rst_medi.is_auto_calc)
            WHEN ''0'' THEN rst_medi.amount
            WHEN ''1'' THEN
                CASE (SELECT value FROM medicine_coop_cd_no)
                WHEN ''1'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_1), ''FM00000V9999''), rst_medi.amount)
                WHEN ''2'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_2), ''FM00000V9999''), rst_medi.amount)
                WHEN ''3'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_3), ''FM00000V9999''), rst_medi.amount)
                WHEN ''4'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_4), ''FM00000V9999''), rst_medi.amount)
                END
            END AS e04
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
            ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
            END AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN ''07''
            ELSE ''11'' --時間外薬剤
            END AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --透析液
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''透析液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , (SELECT value FROM num_auto_calc WHERE key2 = ''AUTO_CALC_FLG'') AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''15'')
            AND ord.rst_cond_info -> ''15'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --補液
            2 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''補液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''19'')
            AND ord.rst_cond_info -> ''19'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT OUTER JOIN addmed_cd
          ON (CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
            WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
            WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
            WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
            END)
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            END)
        UNION ALL
        SELECT
          --酸素吸入情報
          ''実績詳細'' AS detail_id
          , ''酸素吸入''
          , (SELECT value FROM oxygen_code) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_medicine)  AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(tmedi ->> ''oxygen_amount'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM oxygen_used_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 999 AS e09
        FROM
          ord_main AS ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi
        WHERE
          ord.ord_no = @ordNo
          AND tmedi ->> ''treat_class'' = ''3''
          AND tmedi ->> ''oxygen_amount'' IS NOT NULL
        UNION ALL
        SELECT
          --穿刺針情報
          ''実績詳細'' AS detail_id
          , ''穿刺針''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''08'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION ALL
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''class_type'' IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --医材情報
          ''実績詳細'' AS detail_id
          , ''医材''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , CASE
            WHEN rst_equip.class_type = ''4'' THEN ''000010000'' --吸着カラム使用量1固定
            ELSE TO_CHAR(TO_NUMBER(rst_equip.amount, ''FM99999.9999''), ''FM00000V9999'') 
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''09'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
              , t.equip ->> ''class_type'' AS class_type
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''equip_type'' = ''0''
              AND t.equip ->> ''class_type'' NOT IN (''2'', ''3'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --1次膜2次膜情報
          ''実績詳細'' AS detail_id
          , ''1次膜2次膜''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq.meq_code_order END, meq.meq_code_order
            ) AS e09
          FROM (
            SELECT
              CASE
                WHEN info.key = ''7'' THEN 1
                WHEN info.key = ''8'' THEN 2
                END AS temp_no
              ,info.value ->> ''value'' AS eq_cd
            FROM ord_main ord
            CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''7'',''8'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --加算(その他)その2Ver1
          ''実績詳細'' AS detail_id
          , ''加算(その他)その2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --加算(患者)Ver2、加算(その他)その2Ver2、項目コメントVer2、透析コメント1~3Ver2
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03 --機能コード
          , rst_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            END) AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        UNION ALL 
        SELECT
          --加算(透析困難)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION ALL
        SELECT
          --加算(レセプトメモ)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM addition_coop_cd_no)
            WHEN ''1'' THEN mad.in_hospital_cd_1
            WHEN ''2'' THEN mad.in_hospital_cd_2
            WHEN ''3'' THEN mad.in_hospital_cd_3
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM addition_func_cd_no)
            WHEN ''1'' THEN COALESCE(mad.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mad.in_hospital_cd_2, (SELECT value FROM func_another_add))
            WHEN ''3'' THEN COALESCE(mad.in_hospital_cd_3, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''14'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) addi
          LEFT OUTER JOIN mst_addition AS mad
            ON mad.addition_cd = TO_NUMBER(addi ->> ''cd'', ''FM9999999999'')
        WHERE
          ''2'' = @messageType
          AND ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析所要時間情報
          ''実績詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR((FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60)), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析除水量情報
          ''実績詳細'' AS detail_id
          , ''除水量'' AS sbt_key
          , (SELECT value FROM other_off_water) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(rst_weight_info ->> ''add_total'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_off_water_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''16'' AS e08
          , NULL ::int AS e09
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --項目コメントVer1
          ''実績詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント1Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント2Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント3Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3C''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
      ) all_cost
    WHERE
      all_cost.e01 IS NOT NULL
    ORDER BY
      all_cost.e08
      , CAST(all_cost.e09 as integer)
      , all_cost.e01
  ) cost_fin
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)実績繰り返し部１', '2020-05-18 18:12:46.000', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600118, 'WITH va_coop_co_no AS (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = ''@key0''
    AND info ->> ''key1'' = ''NEC''
    AND info ->> ''key2'' = ''VA_COOP_CD_NO''
)
, coop_va AS (
SELECT
    mva.va_name AS va_name
FROM
    mst_va mva
WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND CASE (SELECT value FROM va_coop_co_no)
        WHEN ''1'' THEN mva.in_hospital_cd_1 = ''@vaCd''
        WHEN ''2'' THEN mva.in_hospital_cd_2 = ''@vaCd''
        END
)
, eve_sub_cate_inhosp_no AS (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = ''@key0''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''PAT_EVENT_SUB_CATEGORY''
)
, va_sub_categories AS (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = ''@key0''
    AND info ->> ''key1'' = ''NEC''
    AND info ->> ''key2'' = ''VA_SUB_CATEGORIES''
)
, eve_sub_cate_info AS (
SELECT
    facility_cd,
    sub_category_cd,
    sub_category_name,
    use_type,
    template_cd,
    category_cd
FROM
    mst_pat_event_sub_category AS sub
WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND CASE (SELECT value FROM eve_sub_cate_inhosp_no)
    WHEN ''2'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a2
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b2
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a2
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b2
        ELSE NULL
        END
    WHEN ''3'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a3
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b3
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a3
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b3
        ELSE NULL
        END
    WHEN ''4'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a4
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b4
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a4
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b4
        ELSE NULL
        END
    ELSE
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a1
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b1
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a1
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b1
        ELSE NULL
        END
    END = ANY (string_to_array((SELECT value FROM va_sub_categories), '',''))
)
, format_class_2_idx AS (
SELECT
    mpedt.template_cd
    , t.value ->> ''format_class'' AS format_class
    , idx AS input_index
    , ROW_NUMBER() OVER (PARTITION BY mpedt.template_cd, t.value ->> ''format_class'') AS row_no
FROM
    eve_sub_cate_info esci
LEFT JOIN mst_pat_event_data_template mpedt
    ON esci.template_cd = mpedt.template_cd
    AND mpedt.is_del = ''0''
    AND mpedt.is_disp = ''1''
CROSS JOIN lateral jsonb_array_elements(mpedt.input_params) WITH ORDINALITY t(value, idx)
WHERE
    t.value ->> ''format_class'' = ''2''
)
, registered_va as ( --登録済みイベント検索 --サブカテゴリごと
SELECT
    row_number () over (partition by pe.sub_category_cd order by coalesce(pe.event_start_time, ''0000'') desc, pe.pat_event_cd desc) as row_no
    , pe.template_cd
    , pe.category_cd
    , pe.input_params
    , pe.sub_category_cd
    , pe.result_params
    , pe.use_type
FROM
    pat_event AS pe
    LEFT JOIN mst_pat_event_sub_category mpesc
    ON pe.sub_category_cd = mpesc.sub_category_cd
WHERE
    pat_id = @patId
    AND pe.facility_cd = ''@facilityCd''
    AND pe.is_del = ''0''
    AND pe.use_type = 1
    and event_start_date = TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')
    AND CASE (SELECT value FROM eve_sub_cate_inhosp_no)
    WHEN ''2'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a2
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b2
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a2
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b2
        ELSE NULL
        END
    WHEN ''3'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a3
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b3
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a3
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b3
        ELSE NULL
        END
    WHEN ''4'' THEN
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a4
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b4
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a4
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b4
        ELSE NULL
        END
    ELSE
        CASE
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND CURRENT_DATE >= in_hosp_b_startdate
        THEN CASE
            WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                THEN in_hospital_cd_a1
            WHEN in_hosp_a_startdate < in_hosp_b_startdate
                THEN in_hospital_cd_b1
            END
        WHEN CURRENT_DATE >= in_hosp_a_startdate
        AND (CURRENT_DATE < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN in_hospital_cd_a1
        WHEN (CURRENT_DATE < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND CURRENT_DATE >= in_hosp_b_startdate
            THEN in_hospital_cd_b1
        ELSE NULL
        END
    END = ANY (string_to_array((SELECT value FROM va_sub_categories), '',''))
)
, registered_va_sub_category_cd AS ( --同日最新登録済みVA
SELECT
    rva.sub_category_cd
    , rva.result_params -> (fc2i.input_index-1)::int -> ''result_value'' -> 0 ->> ''name'' AS registered_va_name
FROM
    registered_va rva
LEFT JOIN format_class_2_idx fc2i
ON fc2i.template_cd = rva.template_cd
AND fc2i.row_no = 1
WHERE
    rva.row_no = 1
)
, event_info AS (
SELECT
    sub_cata.facility_cd,
    sub_cata.sub_category_cd,
    sub_cata.sub_category_name,
    sub_cata.use_type,
    eve_temp.input_params,
    eve_temp.template_cd,
    eve_temp.template_name,
    eve_cata.category_cd,
    eve_cata.category_name,
    fc2i.input_index
FROM
    eve_sub_cate_info sub_cata
JOIN mst_pat_event_data_template eve_temp
ON
    sub_cata.template_cd = eve_temp.template_cd
    AND sub_cata.facility_cd = eve_temp.facility_cd
    AND eve_temp.is_del = ''0''
    AND eve_temp.is_disp = ''1''
JOIN mst_pat_event_category eve_cata
ON
    sub_cata.category_cd = eve_cata.category_cd
    AND sub_cata.facility_cd = eve_cata.facility_cd
    AND eve_cata.is_del = ''0''
    AND eve_cata.is_disp = ''1''
LEFT JOIN format_class_2_idx fc2i
ON
    sub_cata.template_cd = fc2i.template_cd
    AND fc2i.row_no = 1
LEFT JOIN registered_va_sub_category_cd rvscc
ON
    sub_cata.sub_category_cd = rvscc.sub_category_cd
WHERE
    sub_cata.use_type = ''1''                                        -- 利用種別がVA
    AND fc2i.template_cd IS NOT NULL                               -- 画像フィールドをもつ
    AND (SELECT va_name FROM coop_va) IS NOT NULL                  -- 電文のVAと紐づくVAが存在する
    AND (rvscc.registered_va_name  != (SELECT va_name FROM coop_va)
        OR rvscc.registered_va_name IS NULL)                       --同日の同サブカテゴリにて登録された最新のVAが一致
)
, processed_data AS (
    SELECT jsonb_build_object(
            ''format_class'', (elem->>''format_class'')::int,
            ''result_value'', ''''
        ) AS new_elem,
        sub_category_cd,
        info.idx
    FROM event_info
    CROSS JOIN LATERAL jsonb_array_elements(input_params) WITH ORDINALITY AS info(elem, idx)
    WHERE elem->>''format_class'' NOT IN (''2'', ''3'', ''4'', ''6'', ''7'', ''8'')
    UNION ALL
    SELECT jsonb_build_object(
        ''format_class'', (elem->>''format_class'')::int,
        ''result_value'',
        CASE
          WHEN elem->>''format_class'' IN (''3'', ''4'', ''6'', ''7'') THEN ''[]''::jsonb
          WHEN elem->>''format_class'' = ''2'' THEN
            CASE
              WHEN info.idx = event_info.input_index
              THEN 
                CASE
                  WHEN event_info.input_params -> (info.idx-1)::int -> ''item_json'' ->> ''image_num'' = ''1''
                  THEN
                    jsonb_build_array(jsonb_build_object(
                    ''name'', (SELECT va_name FROM coop_va),
                    ''file_name'', '''',
                    ''file_path'', '''',
                    ''is_send_va'', ''0'',
                    ''file_modified_time'', ''''))
                  ELSE
                    jsonb_build_array(jsonb_build_object(
                    ''name'', (SELECT va_name FROM coop_va),
                    ''file_name'', '''',
                    ''file_path'', '''',
                    ''is_send_va'', ''0'',
                    ''file_modified_time'', ''''))
                    || (
                        SELECT jsonb_agg(jsonb_build_object(
                            ''name'', '''',
                            ''file_name'', '''',
                            ''file_path'', '''',
                            ''is_send_va'', ''0'',
                            ''file_modified_time'', '''')) as result
                        FROM
                        (SELECT generate_series(2,
                            (SELECT (input_params -> (info.idx-1)::int -> ''item_json'' ->> ''image_num'') ::int)
                        )) sub
                    )
                  END
              ELSE (
                SELECT jsonb_agg(jsonb_build_object(
                    ''name'', '''',
                    ''file_name'', '''',
                    ''file_path'', '''',
                    ''is_send_va'', ''0'',
                    ''file_modified_time'', '''')) as result
                FROM
                  (SELECT generate_series(1,
                    (SELECT (input_params -> (info.idx-1)::int -> ''item_json'' ->> ''image_num'') ::int)
                  )) sub
              )
              END
          WHEN elem->>''format_class'' = ''8'' THEN jsonb_build_object(
            ''unit'', '''',
            ''score'', ''0'')
        END
    ) AS new_elem,
    sub_category_cd,
    info.idx
    FROM event_info
    CROSS JOIN
    LATERAL jsonb_array_elements(input_params) WITH ORDINALITY AS info(elem, idx)
    WHERE elem->>''format_class'' IN (''2'', ''3'', ''4'', ''6'', ''7'', ''8'')
    ORDER BY sub_category_cd ASC, idx ASC
), final_data AS (
    SELECT jsonb_agg(new_elem) || jsonb_build_array(jsonb_build_object(''upDate'', to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD"T"HH24:MI:SS.MS"+00:00"''))) AS result_info,
    sub_category_cd
    FROM processed_data
    GROUP BY sub_category_cd
)
INSERT
  INTO
  pat_event
(pat_id,
  facility_cd,
  fn_ctl_no,
  event_status,
  template_cd,
  template_name,
  category_cd,
  category_name,
  ord_no,
  input_params,
  event_start_date,
  sub_category_cd,
  sub_category_name,
  result_params,
  score_total,
  reg_staff_info,
  up_staff_info,
  bbs_ctl_no,
  is_newest,
  is_del,
  reg_date,
  up_date,
  letter_info,
  use_type,
  event_end_date,
  event_start_time,
  event_end_time,
  report_url,
  report_date)
SELECT 
@patId, -- pat_id 
''@facilityCd'', -- facility_cd 
0, -- fn_ctl_no 
''1'', -- event_status 
template_cd, -- template_cd 
template_name, -- template_name 
category_cd, -- category_cd 
category_name, -- category_name 
NULL, -- ord_no 
input_params, -- input_params 
TO_CHAR(CURRENT_DATE, ''YYYYMMDD''), -- event_start_date 
event_info.sub_category_cd, -- sub_category_cd 
sub_category_name, -- sub_category_name 
result_info, -- result_params
NULL, -- score_total 
jsonb_build_object(
  ''reg_staff_cd'', NULLIF(''@userId'', ''''),
  ''reg_staff_name'', NULLIF(''@userFullName'', '''')
), -- reg_staff_info 
jsonb_build_object(
  ''up_staff_cd'', NULLIF(''@userId'', ''''),
  ''up_staff_name'', NULLIF(''@userFullName'', '''')
), -- up_staff_info 
0, -- bbs_ctl_no 
''1'', -- is_newest 
''0'', -- is_del 
CURRENT_TIMESTAMP, -- reg_date 
CURRENT_TIMESTAMP, -- up_date 
NULL, -- letter_info 
use_type, -- use_type 
TO_CHAR(CURRENT_DATE, ''YYYYMMDD''), -- event_end_date 
''0000'', -- event_start_time 
NULL, -- event_end_time 
NULL, -- report_url 
NULL -- report_date
FROM event_info
JOIN final_data
ON event_info.sub_category_cd = final_data.sub_category_cd 
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携_VAイベント登録', '2025-01-07 11:58:35.055', CURRENT_TIMESTAMP, '[{"sql_cd": -600116, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -600116, "field_name": "user_full_name", "replace_var": "@userFullName"}]'::jsonb);


INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-600600, 'SELECT
    CASE 
        -- 10桁未満の場合、右に空白を埋めて10桁に
        WHEN LENGTH(step1_result) < 10 THEN RPAD(step1_result, 10, '' '')
        -- 10桁を超過した場合、右端から10桁を切り出し
        WHEN LENGTH(step1_result) > 10 THEN SUBSTR(step1_result, LENGTH(step1_result) - 10 + 1, 10)
        -- 10桁のときはそのまま
        ELSE step1_result
    END AS padding_hpid
FROM (
    SELECT
        CASE 
            -- 患者IDの長さが連携設定桁数を超えている場合、右側から桁数分だけ切り出し
            WHEN LENGTH(hosp_pat_id) > @patidPatidfig 
                THEN SUBSTR(hosp_pat_id, LENGTH(hosp_pat_id) - @patidPatidfig + 1, @patidPatidfig)
            
            -- 患者IDの長さが連携設定桁数より短い場合、左側にゼロ埋め
            WHEN LENGTH(hosp_pat_id) < @patidPatidfig 
                THEN LPAD(TRIM(hosp_pat_id), @patidPatidfig, ''0'')
            
            -- それ以外（長さがちょうど一致する場合）はそのまま
            ELSE hosp_pat_id
        END AS step1_result
    FROM
        pat_personal_main
    WHERE
        is_del = ''0''
        AND pat_id = @patId
) AS temp_table', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者ID桁数設定に則った患者ID取得', '2024-12-06 19:00:31.714', CURRENT_TIMESTAMP, '[{"sql_cd": -600601, "field_name": "patid_patidfig", "replace_var": "@patidPatidfig"}]'::jsonb);



INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-600601, 'SELECT
        COALESCE(info->>''value'', info->>''default_v'') as patid_patidfig
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key0'' = @key0
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key2'' = ''PATID_PATIDFIG''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
        AND COALESCE(NULLIF(info->>''value'', ''''), NULL) IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'バイタル連携）患者ID桁数設定値取得', '2024-12-06 19:00:31.714', CURRENT_TIMESTAMP, NULL);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9107, 'WITH latest_element AS(
  SELECT
    pat_id,
    p_info.VALUE AS elem
  FROM
    pat_unique
    CROSS JOIN
      LATERAL jsonb_array_elements(physical_info) AS p_info
  WHERE
    pat_id = @patId
  ORDER BY
    p_info ->> ''exam_date'' DESC
  LIMIT 1
),
updated_elements AS(
  SELECT
    pat_id,
    jsonb_agg(
      CASE
        WHEN elem ->> ''exam_date'' = CURRENT_DATE::text THEN jsonb_set(elem, ''{height}'', ''"@physicalInfo.height"'')
        ELSE elem
      END
    ) AS updated_data,
    bool_or(
      elem ->> ''exam_date'' = CURRENT_DATE::text
    ) AS has_date,
    bool_or(
      (
        SELECT
          elem ->> ''height''
        FROM
          latest_element
      ) != ''@physicalInfo.height''
    ) AS is_change,
    MAX(
      (
        elem ->> ''ctl_no''
      )::int
    ) + 1 AS next_ctl_no
  FROM
    pat_unique,
    jsonb_array_elements(physical_info) AS elem
  WHERE
    pat_id = @patId
  GROUP BY
    pat_id
),
final_update AS(
  SELECT
    pat_id,
    CASE
      WHEN has_date
    OR  NOT is_change THEN updated_data
      ELSE updated_data || jsonb_build_array(jsonb_build_object(
          ''ctl_no'',
          next_ctl_no,
          ''exam_date'',
          CURRENT_DATE::text,
          ''order_class'',
          ''@physicalInfo.orderClass'',
          ''height'',
          (
            SELECT
              CASE ''@physicalInfo.height''
                WHEN '''' THEN NULL
                ELSE TO_CHAR(@physicalInfo.height, ''FM999.0'')
              END
          ),
          ''ctr_weight'',
          NULL,
          ''breast_dia'',
          NULL,
          ''chest_dia'',
          NULL,
          ''ctr'',
          NULL,
          ''dw'',
          NULL,
          ''indicator_cd'',
          NULL,
          ''indicator_start_date'',
          TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
          ''memo'',
          NULL,
          ''pre_scale_upper'',
          NULL,
          ''pre_scale_lower'',
          NULL,
          ''facility_cd'',
          NULL,
          ''inspect_date'',
          TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
          ''changer_cd'',
          NULL,
          ''target_weight'',
          NULL
        ))
    END AS final_data
  FROM
    updated_elements
),
in_out_class AS(
  SELECT
    (
      CASE
        WHEN ''@dieDate_Date'' != '''' THEN ''2''
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN ''0''
        ELSE ''1''
      END
    ) AS in_out
),
ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE(ctl_no, 1) AS ctl_no,
    in_out AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' WHEN ''2'' THEN ''11'' ELSE ''6'' END)::TEXT AS move_in_out,
    NULL AS to_facility,
    to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2) AS period_start_day,
    to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start_date,
    SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4) AS period_start_year,
    SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2) AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
  FROM
    in_out_class
    LEFT JOIN
      ctl_no_calc
    ON  true
),
data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    in_out_class ioc
  WHERE
    ''@ppmInOutClass'' = ioc.in_out
  UNION
  SELECT
    2 AS order_no,
    ''0'' AS exists_flag
  ORDER BY
    order_no
  LIMIT 1
),
json_data AS(
  SELECT
    jsonb_build_object(
      ''ctl_no'',
      ctl_no,
      ''in_out'',
      in_out::integer,
      ''reason'',
      reason,
      ''to_course'',
      to_course,
      ''to_doctor'',
      to_doctor,
      ''disp_order'',
      disp_order,
      ''period_end'',
      period_end,
      ''facility_cd'',
      facility_cd,
      ''from_course'',
      from_course,
      ''from_doctor'',
      from_doctor,
      ''move_in_out'',
      move_in_out,
      ''to_facility'',
      to_facility,
      ''period_start'',
      period_start,
      ''from_facility'',
      from_facility,
      ''course_is_free'',
      course_is_free,
      ''doctor_is_free'',
      doctor_is_free,
      ''period_end_day'',
      period_end_day,
      ''period_end_year'',
      period_end_year,
      ''facility_is_free'',
      facility_is_free,
      ''period_end_month'',
      period_end_month,
      ''period_start_day'',
      period_start_day,
      ''period_start_date'',
      period_start_date,
      ''period_start_year'',
      period_start_year,
      ''period_start_month'',
      period_start_month,
      ''period_end_input_free'',
      period_end_input_free,
      ''period_start_input_free'',
      period_start_input_free,
      ''to_medicalInstitutionCd'',
      to_medicalInstitutionCd,
      ''from_medicalInstitutionCd'',
      from_medicalInstitutionCd
    ) AS new_data
  FROM
    data_new_info
)
UPDATE
  pat_unique
SET
  physical_info = CASE
    WHEN physical_info IS NULL
  OR  physical_info = ''[]'' THEN jsonb_build_array(jsonb_build_object(
        ''ctl_no'',
        1,
        ''exam_date'',
        CURRENT_DATE::text,
        ''order_class'',
        ''@physicalInfo.orderClass'',
        ''height'',
        TO_CHAR(@physicalInfo.height, ''FM999.0''),
        ''ctr_weight'',
        NULL,
        ''breast_dia'',
        NULL,
        ''chest_dia'',
        NULL,
        ''ctr'',
        NULL,
        ''dw'',
        NULL,
        ''indicator_cd'',
        NULL,
        ''indicator_start_date'',
        TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'',
        NULL,
        ''pre_scale_upper'',
        NULL,
        ''pre_scale_lower'',
        NULL,
        ''facility_cd'',
        NULL,
        ''inspect_date'',
        TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'',
        NULL,
        ''target_weight'',
        NULL
      ))
    ELSE(
      SELECT
        final_data
      FROM
        final_update
    )
  END,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
AND @is_die = ''0''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}, {"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9106, 'INSERT INTO pat_unique(
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  is_del,
  up_date,
  reg_date,
  facility_cd,
  old_up_date_unique
) 
VALUES (
  @patId,
  ''[]'',
  jsonb_build_array(jsonb_build_object(
      ''ctl_no'',
      1,
      ''in_out'',
      CASE
        WHEN ''@dieDate_Date'' != '''' THEN 2
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0
        ELSE 1
      END,
      ''reason'',
      NULL,
      ''to_course'',
      NULL,
      ''to_doctor'',
      NULL,
      ''disp_order'',
      0,
      ''period_end'',
      NULL,
      ''facility_cd'',
      ''@facilityCd'',
      ''from_course'',
      NULL,
      ''from_doctor'',
      NULL,
      ''move_in_out'',
      CASE
        WHEN ''@dieDate_Date'' != '''' THEN ''11''
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN ''6''
        ELSE ''4''
      END,
      ''to_facility'',
      NULL,
      ''period_start'',
      to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
      ''from_facility'',
      NULL,
      ''course_is_free'',
      ''0'',
      ''doctor_is_free'',
      ''0'',
      ''period_end_day'',
      NULL,
      ''period_end_year'',
      NULL,
      ''facility_is_free'',
      ''0'',
      ''period_end_month'',
      NULL,
      ''period_start_day'',
       SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2),
      ''period_start_date'',
      to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
      ''period_start_year'',
      SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4),
      ''period_start_month'',
      SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2),
      ''period_end_input_free'',
      ''0'',
      ''period_start_input_free'',
      ''0'',
      ''to_medicalInstitutionCd'',
      NULL,
      ''from_medicalInstitutionCd'',
      NULL
    )),
  CASE
    WHEN ''@physicalInfo.height'' = '''' THEN ''[]'' :: jsonb
    ELSE jsonb_build_array(
      jsonb_build_object(
        ''ctl_no'', 1,
        ''exam_date'', CURRENT_DATE :: text,
        ''order_class'', @physicalInfo.orderClass,
        ''height'', TO_CHAR(@physicalInfo.height, ''FM999.0''),
        ''ctr_weight'', NULL,
        ''breast_dia'', NULL,
        ''chest_dia'', NULL,
        ''ctr'', NULL,
        ''dw'', NULL,
        ''indicator_cd'', NULL,
        ''indicator_start_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'', NULL,
        ''pre_scale_upper'', NULL,
        ''pre_scale_lower'', NULL,
        ''facility_cd'', NULL,
        ''inspect_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'', NULL,
        ''target_weight'', NULL
      )
    )
  END,
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  ''@facilityCd'',
  NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の登録', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600110, 'WITH pcd_info AS (
SELECT
    ''1'' AS update_target
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_version = @coopVersion
  AND save_2 ->> ''ord_no''::TEXT = @save2.ordNo
  AND is_del = ''0''
  AND is_disp = ''1''
)
SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
    WHERE
        tbl2.pat_id = @patId 
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId
    AND ''1'' = (SELECT update_target FROM pcd_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者基本情報の取得_削除用', '2025-01-21 20:03:34.460', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600111, 'WITH pcd_info AS (
SELECT
    ''1'' AS update_target
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_version = @coopVersion
  AND save_2 ->> ''ord_no''::TEXT = @save2.ordNo
  AND is_del = ''0''
  AND is_disp = ''1''
)
SELECT pu.pat_id,
       medical_hst_info,
       in_out_visit_history_info,
       physical_info,
       is_del,
       up_date,
       reg_date,
       facility_cd,
       old_up_date_unique
FROM pat_unique pu
WHERE pu.pat_id = @patId
  AND is_del = ''0''
  AND ''1'' = (SELECT update_target FROM pcd_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者固有情報の取得_削除用', '2025-01-21 20:03:34.460', CURRENT_TIMESTAMP, '[{"sql_cd": 1604, "field_name": "pat_id", "replace_var": "@pat_id"}]'::jsonb);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600117, '
-- 値を取得しない
SELECT
  1
WHERE
  1 = 0;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携_VAイベント登録', '2025-01-07 11:58:35.055', CURRENT_TIMESTAMP, NULL);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600700, 'SELECT
  1
WHERE
 LENGTH(@examDate)= 12;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9119, 'UPDATE pat_coop_detail
SET
  save_3 = save_3 || jsonb_build_array(jsonb_build_object(
    ''item_number'', NULLIF(''@save3.item_number'', ''''),
    ''item_code'', NULLIF(''@save3.item_code'', ''''),
    ''item_generation'', NULLIF(''@save3.item_generation'', ''''),
    ''item_name'', NULLIF(''@save3.item_name'', ''''),
    ''function_code'', NULLIF(''@save3.function_code'', ''''),
    ''usage_amount'', NULLIF(''@save3.usage_amount'', ''''),
    ''usage_unit'', NULLIF(''@save3.usage_unit'', ''''),
    ''usage_unit_name'', NULLIF(''@save3.usage_unit_name'', ''''),
    ''speed'', NULLIF(''@save3.speed'', ''''),
    ''speed_unit'', NULLIF(''@save3.speed_unit'', ''''),
    ''speed_unit_name'', NULLIF(''@save3.speed_unit_name'', ''''),
    ''comment_code_1'', NULLIF(''@save3.comment_code_1'', ''''),
    ''comment_generation_1'', NULLIF(''@save3.comment_generation_1'', ''''),
    ''comment_name_1'', NULLIF(''@save3.comment_name_1'', ''''),
    ''comment_code_2'', NULLIF(''@save3.comment_code_2'', ''''),
    ''comment_generation_2'', NULLIF(''@save3.comment_generation_2'', ''''),
    ''comment_name_2'', NULLIF(''@save3.comment_name_2'', ''''),
    ''comment_code_3'', NULLIF(''@save3.comment_code_3'', ''''),
    ''comment_generation_3'', NULLIF(''@save3.comment_generation_3'', ''''),
    ''comment_name_3'', NULLIF(''@save3.comment_name_3'', ''''),
    ''free_comment'', NULLIF(''@save3.free_comment'', ''''),
    ''interface_flag'', NULLIF(''@save3.interface_flag'', ''''),
    ''reserve'', NULLIF(''@save3.reserve'', '''')
    )),
  user_id = @userId,
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND is_disp = ''1''
  AND coop_save_no = @coopSaveNo
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9205, 'WITH exam_item_nec AS (
  SELECT
    NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF(''@examResultInfo.type'', '''') AS type
    , NULLIF(''@examResultInfo.unit'', '''') AS unit
    , NULLIF(''@examResultInfo.lower'', '''') AS lower
    , NULLIF(''@examResultInfo.upper'', '''') AS upper
    , NULLIF(
      (
        CASE
          WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> ''''
          THEN ''@examResultInfo.comCd1'' || '','' || ''@examResultInfo.comCd2''
          ELSE ''@examResultInfo.comCd1'' || ''@examResultInfo.comCd2''
          END
      ) , '''') AS com_cd
    , NULLIF(''@examResultInfo.result'', '''') AS result
    , NULLIF(''@examResultInfo.itemCd'', '''') AS item_cd
    , '''' AS freememo
    , NULLIF(''@examResultInfo.itemName'', '''') AS item_name
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.examClass'', '''') AS exam_class
    , NULLIF(''@examResultInfo.resultDate_Date'', '''') AS result_date
)
, exam_item_ntss AS (
  SELECT
    A.exam_item_cd
    , A.exam_item_name
    , A.data_type
    , A.unit
    , A.exam_class
    , A.input_upper
    , A.input_lower
    , A.in_hospital_cd1 AS hospital_cd1
    , A.in_hospital_cd2 AS hospital_cd2
    , A.in_hospital_cd3 AS hospital_cd3
  FROM
    mst_exam_item A
    , (
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX
      FROM
        mst_selector mss
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT)
      WHERE
        facility_cd = ''@facilityCd''
        AND master_physical_name = ''mst_exam_item''
    ) ms
  WHERE
    A.facility_cd = ms.facility_cd
    AND A.exam_item_cd = ms.code
    AND A.is_del = ''0''
    AND A.is_disp = ''1''
  ORDER BY
    ms.INDEX
)
, examincode_position AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''HR''
    AND info ->> ''key1'' = ''EXAMIN_RECV''
    AND info ->> ''key2'' = ''EXAMINCODE_POSITION''
)
, exam_result_nec AS (
  SELECT
    nec.hl
    , COALESCE(nec.type, ntss.data_type) AS type
    , COALESCE(nec.unit, ntss.unit) AS unit
    , COALESCE(nec.lower, ntss.input_lower) AS lower
    , COALESCE(nec.upper, ntss.input_upper) AS upper
    , nec.com_cd
    , nec.result AS result
    , COALESCE((ntss.exam_item_cd ::TEXT), nec.item_cd) AS item_cd
    , nec.freememo
    , COALESCE(nec.item_name, ntss.exam_item_name) AS item_name
    , nec.disp_order
    , COALESCE(COALESCE(nec.exam_class, ntss.exam_class), ''0'') AS exam_class
    , nec.result_date
  FROM
    exam_item_nec AS nec
    LEFT OUTER JOIN exam_item_ntss AS ntss
    ON (CASE (SELECT value FROM examincode_position)
      WHEN ''IN_HOSPITAL_CD'' THEN ntss.hospital_cd1 = nec.item_cd
      WHEN ''IN_HOSPITAL_CD2'' THEN ntss.hospital_cd2 = nec.item_cd
      WHEN ''IN_HOSPITAL_CD3'' THEN ntss.hospital_cd3 = nec.item_cd
      WHEN ''EXAM_ITEM_CD'' THEN ntss.exam_item_cd ::text = nec.item_cd
      END)
)
, exam_result_exists AS (
  SELECT
    count(1) AS data_count
  FROM
    pat_exam_main
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info
    INNER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd''
  WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND exam_main_cd = @examMainCd
)
, exam_result AS (
  -- JOSNにNECのデータが有りの場合、UPDATE
  SELECT
    array_to_json(
      ARRAY_AGG(
        CASE
          WHEN nec.item_cd IS NULL
            THEN info ::JSON
          ELSE json_build_object(
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          )
          END
      )
    ) AS exam_result_info_new
  FROM
    pat_exam_main
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info
    LEFT OUTER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd''
  WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND exam_main_cd = @examMainCd
    AND (SELECT data_count FROM exam_result_exists) > 0

  UNION ALL
  -- JOSNにNECのデータが無しの場合、INSERT
  SELECT
    CAST(
      exam_result_info || (
        SELECT
          json_build_object(
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          )
        FROM
          exam_result_nec AS nec
      ) ::JSONB AS JSON
    ) AS exam_result_info_new
  FROM
    pat_exam_main
  WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
    AND exam_main_cd = @examMainCd
    AND (SELECT data_count FROM exam_result_exists) = 0
)
UPDATE pat_exam_main
SET
  exam_result_info = CASE ''@examResultInfoFlg''
    WHEN '''' THEN ''@examResultInfoValue''
    ELSE (SELECT exam_result_info_new FROM exam_result WHERE exam_result_info_new is not null) ::JSONB
    END
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')
  AND exam_main_cd = @examMainCd
  AND NULLIF(''@examResultInfo.result'', '''') IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2021-11-30 18:21:40.000', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600506, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    char_length(CAST(@inHospitalCd AS TEXT)) > 10
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600513, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    char_length(CAST(@userPassword AS TEXT)) > 16
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600514, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    char_length(CAST(@userName AS TEXT)) > 20
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600515, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    char_length(CAST(@userKana AS TEXT)) > 20
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);



INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600119, '-- 渡された値が空かYYYYMMDD形式の日付の場合に結果を返す
SELECT
        1
WHERE
     CASE 
       WHEN NULLIF(@dateCheck,'''') IS NULL THEN true
       WHEN @dateCheck ~ ''^(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])$'' 
            AND (
                 (@dateCheck ~ ''^(19|20)\\d{2}02(29)$'' AND SUBSTRING(@dateCheck, 1, 4)::int % 4 = 0 AND (SUBSTRING(@dateCheck, 1, 4)::int % 100 != 0 OR SUBSTRING(@dateCheck, 1, 4)::int % 400 = 0))
                 OR (@dateCheck ~ ''^(19|20)\\d{2}(0[13578]|1[02])(0[1-9]|[12]\\d|3[01])$'')
                 OR (@dateCheck ~ ''^(19|20)\\d{2}(0[469]|11)(0[1-9]|[12]\\d|30)$'')
                 OR (@dateCheck ~ ''^(19|20)\\d{2}02(0[1-9]|1\\d|2[0-8])$'')
            )
       THEN true
       ELSE false
     END;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC標準(MegaOakHR) 日付チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9105, 'WITH infection_nec_sub AS ( 
  -- NECから、感染症情報
  SELECT
    1 AS order_no
    , ''@infectInfo1'' AS CONTENT
  UNION 
  SELECT
    2 AS order_no
    , ''@infectInfo2'' AS CONTENT
  UNION 
  SELECT
    3 AS order_no
    , ''@infectInfo3'' AS CONTENT
  UNION 
  SELECT
    4 AS order_no
    , ''@infectInfo4'' AS CONTENT
  UNION 
  SELECT
    5 AS order_no
    , ''@infectInfo5'' AS CONTENT
  UNION 
  SELECT
    6 AS order_no
    , ''@infectInfo6'' AS CONTENT
  UNION 
  SELECT
    7 AS order_no
    , ''@infectInfo7'' AS CONTENT
  UNION 
  SELECT
    8 AS order_no
    , ''@infectInfo8'' AS CONTENT
  UNION 
  SELECT
    9 AS order_no
    , ''@infectInfo9'' AS CONTENT
  UNION 
  SELECT
    10 AS order_no
    , ''@infectInfo10'' AS CONTENT
  UNION 
  SELECT
    11 AS order_no
    , ''@infectInfo11'' AS CONTENT
  UNION 
  SELECT
    12 AS order_no
    , ''@infectInfo12'' AS CONTENT
  UNION 
  SELECT
    13 AS order_no
    , ''@infectInfo13'' AS CONTENT
  UNION 
  SELECT
    14 AS order_no
    , ''@infectInfo14'' AS CONTENT
  UNION 
  SELECT
    15 AS order_no
    , ''@infectInfo15'' AS CONTENT
  UNION 
  SELECT
    16 AS order_no
    , ''@infectInfo16'' AS CONTENT
  UNION 
  SELECT
    17 AS order_no
    , ''@infectInfo17'' AS CONTENT
  UNION 
  SELECT
    18 AS order_no
    , ''@infectInfo18'' AS CONTENT
  UNION 
  SELECT
    19 AS order_no
    , ''@infectInfo19'' AS CONTENT
  UNION 
  SELECT
    20 AS order_no
    , ''@infectInfo20'' AS CONTENT
  ORDER BY
    order_no ASC
) 
, infection_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''INFECT_%'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) ASC
) 
, infection_nec AS ( 
  SELECT
    ini.hospital_cd
    , CASE sub.CONTENT 
      WHEN ''+'' THEN ''2'' 
      WHEN ''-'' THEN ''1''  
      ELSE ''0'' 
      END AS CONTENT 
  FROM
    infection_nec_sub AS sub 
    INNER JOIN infection_ini AS ini 
      ON sub.order_no = ini.order_no
) 
, infection_ntss AS ( 
  SELECT
    A.infection_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, infectInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN NULLIF(infection_nec.CONTENT, '''') IS NULL 
            THEN info.* 
          ELSE json_build_object( 
            ''infect''
            , infection_nec.CONTENT
            , ''exam_date''
            , info ->> ''exam_date''
            , ''up_date''
            , TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')
            , ''infection_cd''
            , (info ->> ''infection_cd'')::integer
          ) 
          END
      )
    ) AS infect_info_new 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.infect_info ::json) info 
    LEFT OUTER JOIN infection_ntss 
      ON infection_ntss.infection_cd ::TEXT = info ->> ''infection_cd'' 
    LEFT OUTER JOIN infection_nec 
      ON infection_nec.hospital_cd = infection_ntss.hospital_cd 
      AND NULLIF(infection_nec.CONTENT, '''') IS NOT NULL 
  WHERE
    pat.pat_id = @patId
)
, taboo_allergy_nec_sub AS ( 
  -- NECから、薬剤禁忌情報
  SELECT
    1 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 1, 1) AS CONTENT 
  UNION 
  SELECT
    2 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 2, 1) AS CONTENT 
  UNION 
  SELECT
    3 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 3, 1) AS CONTENT 
  UNION 
  SELECT
    4 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 4, 1) AS CONTENT 
  UNION 
  SELECT
    5 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 5, 1) AS CONTENT 
  UNION 
  SELECT
    6 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 6, 1) AS CONTENT 
  UNION 
  SELECT
    7 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 7, 1) AS CONTENT 
  UNION 
  SELECT
    8 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 8, 1) AS CONTENT 
  UNION 
  SELECT
    9 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 9, 1) AS CONTENT 
  UNION 
  SELECT
    10 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 10, 1) AS CONTENT 
  UNION 
  SELECT
    11 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 11, 1) AS CONTENT 
  UNION 
  SELECT
    12 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 12, 1) AS CONTENT 
  UNION 
  SELECT
    13 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 13, 1) AS CONTENT 
  UNION 
  SELECT
    14 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 14, 1) AS CONTENT 
  UNION 
  SELECT
    15 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 15, 1) AS CONTENT 
  UNION 
  SELECT
    16 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 16, 1) AS CONTENT 
  UNION 
  SELECT
    17 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 17, 1) AS CONTENT 
  UNION 
  SELECT
    18 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 18, 1) AS CONTENT 
  UNION 
  SELECT
    19 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 19, 1) AS CONTENT 
  UNION 
  SELECT
    20 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 20, 1) AS CONTENT 
  ORDER BY
    order_no ASC
) 
, taboo_allergy_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''TABOO_%'' 
    AND ini_info ->> ''key2'' <> ''TABOO_CTL_NO'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) ASC
) 
, taboo_allergy_nec AS ( 
  SELECT
    ini.order_no
    , ini.hospital_cd
    , ROW_NUMBER() OVER () AS index_no 
  FROM
    taboo_allergy_nec_sub AS sub 
    INNER JOIN taboo_allergy_ini AS ini 
      ON sub.order_no = ini.order_no 
  WHERE
    sub.CONTENT = ''1'' 
  ORDER BY
    ini.order_no
) 
, taboo_allergy_ntss AS ( 
  SELECT
    A.taboo_allergy_cd
    , A.in_hospital_cd_1 AS hospital_cd
    , A.CONTENT 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, tabooAllergyInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG(
        json_build_object(
          ''memo'',
          NULL,
          ''ctl_no'',
          nec.index_no,
          ''content'',
          ntss_hospital_cd.content,
          ''disp_order'',
          nec.index_no,
          ''category_class'',
          ''0'',
          ''taboo_allergy_cd'',
          ntss_hospital_cd.taboo_allergy_cd,
          ''taboo_allergy_class'',
          ''1''
        )
      )
    ) AS taboo_allergy_info_new 
  FROM
    taboo_allergy_nec AS nec 
    LEFT OUTER JOIN taboo_allergy_ntss AS ntss_hospital_cd 
      ON nec.hospital_cd = ntss_hospital_cd.hospital_cd 
  WHERE ntss_hospital_cd.taboo_allergy_cd IS NOT NULL
)
, check_staff_code AS (
  SELECT (CASE
    -- Case 1: スタッフコードが空またはNULLの場合
    WHEN  '''' = ''@user_id''
         OR ''@'' || ''user_id'' = ''@user_id''
    THEN 
        ''-999999''
    -- Case 2: スタッフコードが数値でない場合
    WHEN NOT ''@user_id'' ~ ''^[0-9]+$''
    THEN
        ''-999999''
    -- Case 3: 該当するユーザーが存在しない場合
    WHEN NOT EXISTS (
        SELECT 1
        FROM mst_user
        WHERE facility_cd = ''@facilityCd''
          AND user_id::text = ''@user_id''
          AND is_disp = ''1''
          AND is_del = ''0''
    )
    THEN
        ''-999999''
    -- Case 4: すでに同じstaff_cdが存在する場合
    WHEN EXISTS (
        SELECT 1
        FROM pat_main, jsonb_array_elements(charge_staff_info) elem
        WHERE pat_id = @patId 
        AND facility_cd = ''@facilityCd''
        AND elem ->> ''staff_cd''::text = ''@user_id''
    )
    THEN
        ''-999999''
    -- Case 5: すべての条件を満たさない場合のみ新規追加
    ELSE ''@user_id''
    END) AS staff_code
)

UPDATE pat_main 
SET
charge_staff_info = CASE 
    WHEN  (SELECT staff_code FROM check_staff_code) = ''-999999''
    THEN 
        charge_staff_info
    ELSE 
        charge_staff_info || jsonb_build_array(
            jsonb_build_object(
                ''ctl_no'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''disp_order'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''staff_cd'', (SELECT staff_code FROM check_staff_code) :: int,
                ''is_main'', ''1'',
                ''is_charge'', ''0'',
                ''is_puncture'', ''0''
            )
        )
END
  , infect_info = (SELECT infect_info_new FROM infectInfo) ::JSONB
  , taboo_allergy_info = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          taboo_allergy_info_new 
        FROM
          tabooAllergyInfo
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}, {"sql_cd": -600106, "field_name": "user_id", "replace_var": "@user_id"}]'::jsonb);