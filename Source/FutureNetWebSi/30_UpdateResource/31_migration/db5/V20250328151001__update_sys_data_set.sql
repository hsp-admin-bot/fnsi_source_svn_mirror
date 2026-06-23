DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-102,-600304,-600014,-600015,-600016,-600018,-600019);

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
, ord_main_switch AS(
(
    SELECT
        ord.rst_edition_date as up_date_switch,
        ord.ord_no,
        ord.rst_bed_cd,
        ord.up_ind_user_id,
        ord.up_user_id,
        ord.treat_date
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.del_date as up_date_switch,
        ord.ord_no,
        ord.rst_bed_cd,
        ord.up_ind_user_id,
        ord.up_user_id,
        ord.treat_date
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
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
        FROM ord_main_switch AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
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
    FROM ord_main_switch ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_ind_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
,up_user_id AS ( --最終更新者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main_switch ord
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
    ELSE (SELECT treat_date FROM ord_main_switch)
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE (SELECT treat_date FROM ord_main_switch)
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
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address,
    COALESCE(NULLIF((SELECT in_hospital_cd FROM rst_del_nec_bed_cd), '''')) as bed_cd
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
    ELSE (SELECT treat_date FROM ord_main_switch)
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE (SELECT treat_date FROM ord_main_switch)
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
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address,
    COALESCE(NULLIF((SELECT in_hospital_cd FROM rst_del_nec_bed_cd), '''')) as bed_cd
FROM pat_coop_detail pcd
WHERE pcd.pat_id = @patId
    AND is_del = ''0''
    AND coop_version = @coopVersion
    AND ''2'' = @messageType
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者補完情報20個', '2024-12-09 16:44:42.537', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600304, 'WITH treatment_coop_cd_no AS (
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''TREATMENT_COOP_CD_NO''
)
, ord_main_switch AS(
    (
        SELECT
            ord.rst_edition_date as up_date_switch,
            ord.ord_no,
            ord.rst_treatment_cd,
            ord.treat_date
        FROM
            ord_main ord
        WHERE
            ord.ord_no = @ordNo
    )
    UNION
        (
            SELECT
            ord.del_date as up_date_switch,
            ord.ord_no,
            ord.rst_treatment_cd,
            ord.treat_date
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
SELECT
    COALESCE(
        CASE (SELECT value FROM treatment_coop_cd_no)
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
        END
    , '''') AS treatment_cd_coop
FROM ord_main_switch AS ord
LEFT JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)実績) 治療方法連携コード', '2025-01-21 16:00:58.768', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600014, 'WITH mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN ''@inOutClass'' = ''1'' -- ''1''：入院
      THEN (SELECT course_cd FROM mst_course_cd)
      ELSE null
    END AS main_course_cd
    , (SELECT ward_cd FROM mst_ward_cd) AS ward_cd
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''dialysis_course_cd''
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''ward_cd''
      , (SELECT ward_cd FROM cource_ward_info)
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE NULL
      END
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の新規', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600015, 'WITH new_name_info AS (
  SELECT
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') = 0 AND POSITION(''　'' IN ''@patLastName'') = 0 THEN ''@patLastName''
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM 1 FOR POSITION('' '' IN ''@patLastName'') - 1))
        ELSE TRIM(substring(''@patLastName'' FROM 1 FOR POSITION(''　'' IN ''@patLastName'') - 1))
    END AS patLastName,
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION('' '' IN ''@patLastName'') + 1))
        WHEN POSITION(''　'' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION(''　'' IN ''@patLastName'') + 1))
        ELSE ''''
    END AS patFirstName,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') = 0 AND POSITION(''　'' IN ''@patLastNmKana'') = 0 THEN ''@patLastNmKana''
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION('' '' IN ''@patLastNmKana'') - 1))
        ELSE TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION(''　'' IN ''@patLastNmKana'') - 1))
    END AS patLastNmKana,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION('' '' IN ''@patLastNmKana'') + 1))
        WHEN POSITION(''　'' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION(''　'' IN ''@patLastNmKana'') + 1))
        ELSE ''''
    END AS patFirstNmKana
)
UPDATE pat_personal_main
SET
  pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info))
  , pat_first_name = personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex''
    WHEN '''' THEN NULL
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'')
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo''
    WHEN '''' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'')
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh''
    WHEN '''' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'')
    END
  , in_out_class = CASE
    WHEN ''@dieDate_Date'' != '''' THEN 2
    WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0
    ELSE 1
    END
  , severity_cd = CASE ''@mstSeverityCd''
    WHEN ''@'' || ''mstSeverityCd'' THEN NULL
    ELSE TO_NUMBER(''@mstSeverityCd'', ''FM99999999999999999999999999999999'')
    END
  , transport_cd = CASE ''@mstTransportCd''
    WHEN ''@'' || ''mstTransportCd'' THEN NULL
    ELSE TO_NUMBER(''@mstTransportCd'', ''FM99999999999999999999999999999999'')
    END
  , pat_contact_info = CASE ''@patContactInfoFlg''
    WHEN '''' THEN ''@patContactInfoValue''
    ELSE json_build_object(
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    )
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND pat_id = ''@patId''
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', '2025-03-18 11:34:58.308', CURRENT_TIMESTAMP, '[{"sql_cd": -600011, "field_name": "severity_cd", "replace_var": "@mstSeverityCd"}, {"sql_cd": -600012, "field_name": "transport_cd", "replace_var": "@mstTransportCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600016, 'WITH mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT
    (
      CASE
        WHEN ''@inOutClass'' = ''1'' -- ''1''：入院
        THEN CAST((SELECT course_cd FROM mst_course_cd) AS TEXT)
        ELSE medical_care_info ->> ''main_course_cd''
      END
    ) AS main_course_cd,
    (
      select
        ward_cd
      from
        mst_ward_cd
    ) AS ward_cd
  FROM
    pat_main
  WHERE
    is_del = ''0''
    AND pat_id = @patId
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
)
UPDATE
  pat_main
SET
  up_date = CURRENT_TIMESTAMP,
  in_out_current_state = (
    case
      ''@isDie''
      when ''1'' then ''11''
      else in_out_current_state
    end
  ),
  medical_care_info = json_build_object(
    ''main_course_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            main_course_cd
          FROM
            cource_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_course_cd'',
    COALESCE(
        TO_NUMBER(medical_care_info ->> ''dialysis_course_cd'',''FM999999999''),
        TO_NUMBER(
            NULLIF(
                (
                    SELECT main_course_cd
                    FROM cource_ward_info
                ),
                ''''
            ),
            ''FM999999999''
        )
    ),
    ''ward_cd'',
    (
        SELECT
          ward_cd
        FROM
          cource_ward_info
      ),
    ''dialysis_count'',
    medical_care_info -> ''dialysis_count'',
    ''purification_count'',
    medical_care_info -> ''purification_count'',
    ''other_dialysis_count'',
    medical_care_info -> ''other_dialysis_count'',
    ''pat_dialysis_count'',
    medical_care_info -> ''pat_dialysis_count'',
    ''facility_cd'',
    medical_care_info ->> ''facility_cd'',
    ''dialysis_start_date'',
    CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE medical_care_info ->> ''dialysis_start_date''
      END,
    ''hospital_start_date'',
    medical_care_info ->> ''hospital_start_date''
  )
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の更新', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}]'::jsonb);


INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-600019, 'SELECT
	CASE
		WHEN COALESCE(ord.rst_fn_dialysis_no,
		0) = 0 THEN (
		SELECT
			COALESCE(NULLIF(ini_info ->> ''value'',
			''''),
			ini_info ->> ''default_v'')
		FROM
			mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
		WHERE
			ini.is_del = ''0''
			AND ini.is_disp = ''1''
			AND ini.facility_cd = @facilityCd
			AND COALESCE(ini_info->>''key0'',
			'''') = ''HR''
			AND TRIM(ini_info ->> ''key1'') = ''NEC''
			AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'') || ''_'' || to_char(NOW(),
		''YYYYMMDDHH24MISSMS'') || ''_'' || journal.hosp_pat_id || ''_0.pdf''
		ELSE journal.hosp_pat_id || lpad(trim(to_char(ord.rst_fn_dialysis_no, ''999999999999'')),
		12,
		''0'') || lpad(trim(to_char(ord.rst_edition, ''9999'')),
		4,
		''0'') || ''.pdf''
	END AS filename
FROM
	sys_coop_journal journal
INNER JOIN ord_main ord ON
	ord.ord_no = journal.ord_no
WHERE
	journal.ord_no = @ordNo
	AND journal.direction = ''S''
	AND journal.ana_result = ''1''
	AND journal.is_del = ''0''
LIMIT 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', '2025-01-28 18:11:12.244', CURRENT_TIMESTAMP, NULL);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-600018, 'SELECT
	(
	SELECT
		COALESCE(NULLIF(ini_info ->> ''value'',
		''''),
		ini_info ->> ''default_v'')
	FROM
		mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
	WHERE
		ini.is_del = ''0''
		AND ini.is_disp = ''1''
		AND ini.facility_cd = @facilityCd
		AND COALESCE(ini_info->>''key0'',
		'''') = ''HR''
		AND TRIM(ini_info ->> ''key1'') = ''NEC''
		AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'') || ''_'' || to_char(NOW(),
	''YYYYMMDDHH24MISSMS'') || ''_'' || journal.hosp_pat_id || ''_0.'' || @extension AS filename
FROM
	sys_coop_journal journal
WHERE
	journal.ord_no = @ordNo
	AND journal.direction = ''S''
	AND journal.ana_result = ''1''
	AND journal.is_del = ''0''
LIMIT 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', '2025-01-28 18:11:12.244', CURRENT_TIMESTAMP, NULL);