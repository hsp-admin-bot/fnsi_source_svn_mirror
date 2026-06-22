DELETE FROM sys_data_set WHERE sql_cd IN (-1102000,-1102001);



INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
 (-1102000, 'WITH RECURSIVE coop_ini_info AS (
    --連携設定から取得
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
            ''SCM_COMMON'',
            ''SCM_DIALYSISSCHESEND'',
            ''SCM_DIALYSISSCHESEND_KARTE_NOTE'',
            ''SCM_IN_HOSPITAL_CD''
        )
)
, medical_record_ini AS(
    --カルテ記録テキスト関連連携設定
    SELECT
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''FREE_WORD'') AS free_word,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''DIALYSIS_TIME'') AS dialysis_time,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''VA'') AS va,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''TARGET_WEIGHT'') AS target_weight,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''BLOOD_FLOW'') AS blood_flow,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''SOLUTION_RESOLVE_FLUX'') AS solution_resolve_flux,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''REPLACE_RESOLVE_MEASURE'') AS replace_resolve_measure,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_ONE_SHOT'') AS kou_one_shot,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_SPEED'') AS kou_speed,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_TOTAL'') AS kou_total,
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND_KARTE_NOTE'' AND key2 = ''ADDITION'') AS addition
)
, user_list AS (
    --mst_user_authenticationのuser_idとdisp_user_idを取得(pre_sqlにて取得)
    SELECT
        users ->> ''user_id'' AS user_id,
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        jsonb_array_elements(@userList) AS users
)
, personal_list AS (
    --mst_personal_userのuser_idとin_hospital_cd_1とin_hospital_cd_2を取得(pre_sqlにて取得)
    SELECT
        personal ->> ''user_id'' AS user_id,
        personal ->> ''in_hospital_cd_1'' AS in_hospital_cd_1,
        personal ->> ''in_hospital_cd_2'' AS in_hospital_cd_2
    FROM
        jsonb_array_elements(@personalList) AS personal
)
, staff_cd_list AS (
  --担当医の取得
    SELECT
        users.disp_user_id,
        ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
    LEFT JOIN user_list AS users ON
        staff_info ->> ''staff_cd'' = users.user_id
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND staff_info ->> ''is_main'' = ''1''
)
, journal_info AS (
    --オーダ番号の取得
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal AS journal
    WHERE
        journal.ctl_no = @ctlNo
        AND journal.facility_cd = @facilityCd
)
, default_doctor AS (
    --デフォルト医師の院内コードと表示用利用者IDを取得
    SELECT
        users.disp_user_id AS defalut_disp_user_id,
        CASE
			(SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''IN_HOSP_CD'')
			WHEN ''1'' THEN personal.in_hospital_cd_1
			WHEN ''2'' THEN personal.in_hospital_cd_2
		END as defalut_in_hospital_cd
    FROM
        coop_ini_info cii
        LEFT JOIN user_list AS users ON 
            cii.value = users.user_id
        LEFT JOIN personal_list AS personal ON
            cii.value = personal.user_id
    WHERE
        cii.key1 = ''SCM_COMMON''
        AND cii.key2 = ''DEFAULT_DOCTOR''
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.ind_cond_info,
            ord.rst_start_date,
            ord.treat_date,
            ord.ind_ind_comment_info,
            ord.ind_treatment_cd,
            ord.up_ind_user_id,
            ord.ind_schedule_user_info,
            ord.ind_bed_cd,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.ind_cond_info,
            ord.rst_start_date,
            ord.treat_date,
            ord.ind_ind_comment_info,
            ord.ind_treatment_cd,
            ord.up_ind_user_id,
            ord.ind_schedule_user_info,
            ord.ind_bed_cd,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        ord_medi_info ->> ''cd'' AS medicine_cd,
        ord.treat_date,
        mp.procedure_cd,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        medi_mix_info ->> ''cd'' AS medicine_cd,
        ord.treat_date,
        mp.procedure_cd,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    --薬剤の出力タイプが薬剤単位
    SELECT
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        *,
        (ROW_NUMBER() OVER (PARTITION BY procedure_hosp_cd) - 1) / 10 + 1 AS rp_chunk
    FROM final_ord_medi_infos
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY procedure_hosp_cd, rp_chunk) AS rp_num
    FROM numbered_base
)
, rp_count AS(
    --RP総数を取得
    SELECT
        CASE (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'')
            WHEN ''0'' THEN (SELECT COUNT(*) FROM final_ord_medi_infos)
            WHEN ''1'' THEN (SELECT COUNT(DISTINCT rp_num) FROM rp_num_assigned)
        END AS rp_num_sum
)
, ord_main_info AS (
    SELECT
        users.disp_user_id,
        res_users.disp_user_id AS res_user_id,
        coalesce(
        CASE
			(SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''IN_HOSP_CD'')
			WHEN ''1'' THEN personal.in_hospital_cd_1
			WHEN ''2'' THEN personal.in_hospital_cd_2
		END,
        (SELECT defalut_in_hospital_cd FROM default_doctor)
        ) as in_hospital_cd,
        mb.bed_cd,
        REPLACE(REPLACE(mb.bed_name,'','',''_''),''，'',''_'') AS bed_name,
        to_char(om.rst_start_date,''YYYY-MM-DD'') AS rst_start_date,
        --to_char(om.rst_start_date, ''HH24:MI:SS'') AS rst_start_time,
        to_char(to_date(om.treat_date,''YYYYMMDD''),''YYYY-MM-DD'') AS treat_date,
        om.ind_cond_info ->''25''->>''medicine_type'' AS medicine_type,
        ROUND((om.ind_cond_info ->''1''->>''value'')::numeric) as dialysis_time,
        mv.va_name as va,
        ROUND((om.ind_cond_info ->''3''->>''value'')::numeric,2) as target_weight,
        ROUND((om.ind_cond_info ->''14''->>''value'')::numeric) as blood_flow,
        ROUND((om.ind_cond_info ->''16''->>''value'')::numeric) as solution_resolve_flux,
        CASE WHEN mt.device_mode not in (10) THEN ROUND((om.ind_cond_info ->''20''->>''value'')::numeric,1) ELSE NULL END AS replace_resolve_measure,
        ROUND((om.ind_cond_info ->''26''->>''value'')::numeric,2) as kou_one_shot,
        ROUND((om.ind_cond_info ->''27''->>''value'')::numeric,2) as kou_speed,
        ROUND((om.ind_cond_info ->''28''->>''value'')::numeric,2) as kou_total,
        (
            SELECT string_agg(elem ->> ''content'', E''\r\n'')
            FROM jsonb_array_elements(om.ind_ind_comment_info) AS elem
        ) AS addition,
        COALESCE(mm.unit, mmx.unit) AS kou_unit
    FROM
        ord_main_max om
    LEFT JOIN mst_va mv on om.ind_cond_info ->''2''->>''value'' = mv.va_cd::text AND mv.facility_cd = @facilityCd
    LEFT JOIN mst_treatment mt on om.ind_treatment_cd = mt.treatment_cd AND mt.facility_cd = @facilityCd
    -- medicine_type = ''1'' 用の結合
    LEFT JOIN mst_medicine mm ON om.ind_cond_info ->''25''->>''medicine_type'' = ''1'' AND om.ind_cond_info ->''25''->>''value'' = mm.medicine_cd::text AND mm.facility_cd = @facilityCd
    -- medicine_type = ''2'' 用の結合
    LEFT JOIN mst_medicine_mix mmx ON om.ind_cond_info ->''25''->>''medicine_type'' = ''2'' AND om.ind_cond_info ->''25''->>''value'' = mmx.medicine_mix_cd::text AND mmx.facility_cd = @facilityCd
    LEFT JOIN user_list AS users ON
        om.up_ind_user_id = users.user_id::numeric
    LEFT JOIN user_list AS res_users ON
        om.ind_schedule_user_info ->> ''ind_user_id'' = res_users.user_id
    LEFT JOIN personal_list AS personal ON
        om.ind_schedule_user_info ->> ''ind_user_id'' = personal.user_id
    LEFT JOIN mst_bed mb on om.ind_bed_cd = mb.bed_cd AND mb.facility_cd = @facilityCd
)
, char_split AS (
    --ベッド名の再帰処理
    SELECT
        omi.bed_cd,
        omi.bed_name,
        1 AS pos,
        substr(omi.bed_name, 1, 1) AS char_part,
        octet_length(substr(omi.bed_name, 1, 1)) AS byte_sum
    FROM ord_main_info omi
    WHERE omi.bed_name IS NOT NULL
    UNION ALL
    SELECT
        cs.bed_cd,
        cs.bed_name,
        cs.pos + 1,
        substr(cs.bed_name, cs.pos + 1, 1),
        cs.byte_sum + octet_length(substr(cs.bed_name, cs.pos + 1, 1))
    FROM char_split cs
    WHERE substr(cs.bed_name, cs.pos + 1, 1) IS NOT NULL
        AND substr(cs.bed_name, cs.pos + 1, 1) != ''''
        AND cs.byte_sum + octet_length(substr(cs.bed_name, cs.pos + 1, 1)) <= 40
)
, aggregated AS (
    --40byte未満のベッド名を取得
    SELECT
        bed_cd,
        string_agg(char_part, '''') AS safe_bed_name
    FROM char_split
    GROUP BY bed_cd
)
, cd_bed_name AS(
    --予約枠コード+コメントの取得
    SELECT
        CASE
            WHEN omi.in_hospital_cd IS NULL THEN repeat('' '', 4)
            WHEN OCTET_LENGTH(omi.in_hospital_cd) <= 4 THEN
            omi.in_hospital_cd || repeat('' '', 4 - OCTET_LENGTH(omi.in_hospital_cd))
            ELSE
            convert_from(substring(omi.in_hospital_cd::bytea from 1 for 4),''UTF8'')
        END AS in_hospital_cd,
        CASE
            WHEN omi.bed_name IS NULL THEN repeat('' '', 40)
            WHEN OCTET_LENGTH(omi.bed_name) <= 40 THEN
            omi.bed_name
            ELSE
            ag.safe_bed_name || repeat('' '', 40 - OCTET_LENGTH(ag.safe_bed_name))
        END AS bed_name
    FROM
        ord_main_info omi
        LEFT JOIN aggregated ag ON omi.bed_cd = ag.bed_cd
)
SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND'' AND key2 = ''TREAT_IDX_TITLE'') AS treat_title,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND'' AND key2 = ''INJECT_IDX_TITLE'') AS shot_title,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND'' AND key2 = ''INJECT_HEAD_TYPE_CODE'') AS shot_type,
    RIGHT(
        CASE (SELECT value::numeric FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSCHESEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN 0 THEN 
            omi.disp_user_id
        WHEN 1 THEN 
            coalesce(
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1),
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2),
            (SELECT defalut_disp_user_id FROM default_doctor),
            ''''
            )
        END
    ,6) AS user_id,
    RIGHT(res_user_id,6) AS res_user_id,
    cbn.in_hospital_cd || cbn.bed_name AS res_cd_comment,
    ji.coop_ord_no,
    omi.treat_date,
    omi.rst_start_date,
    --omi.rst_start_time,
    rc.rp_num_sum,
    array_to_string(
        array_remove(ARRAY[
            mri.free_word,
            mri.dialysis_time || ''：'' || omi.dialysis_time || '' 分'',
            mri.va || ''：'' || omi.va,
            mri.target_weight || ''：'' || omi.target_weight || '' Kg'',
            mri.blood_flow || ''：'' || omi.blood_flow || '' mL/min'',
            mri.solution_resolve_flux || ''：'' || omi.solution_resolve_flux || '' mL/min'',
            mri.replace_resolve_measure || ''：'' || omi.replace_resolve_measure || '' L'',
            mri.kou_one_shot || ''：'' || omi.kou_one_shot || COALESCE('' '' || omi.kou_unit, ''''),
            mri.kou_speed || ''：'' || omi.kou_speed || COALESCE('' '' || omi.kou_unit, '''') || CASE WHEN omi.medicine_type = ''1'' AND omi.kou_unit IS NOT NULL THEN ''/h'' ELSE '''' END,
            mri.kou_total || ''：'' || omi.kou_total || COALESCE('' '' || omi.kou_unit, ''''),
            mri.addition || ''：'' || E''\r\n'' || omi.addition
        ], NULL),
        E''\r\n''
    ) AS medical_record_text
FROM
    medical_record_ini mri,
    ord_main_info omi,
    journal_info ji,
    cd_bed_name cbn,
    rp_count rc',2,'[{}]','0','{"applications": [4]}',NULL,'(送信用)セコムの透析指示',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]');

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102001, 'WITH personal_user AS (
    SELECT
        user_id,
        in_hospital_cd_1,
        in_hospital_cd_2
    FROM
        mst_personal_user mpu
    WHERE
        facility_cd = @facilityCd
        And is_del = ''0''
)
SELECT
    jsonb_agg(personal_user)::text AS personal_list
FROM
    personal_user', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);