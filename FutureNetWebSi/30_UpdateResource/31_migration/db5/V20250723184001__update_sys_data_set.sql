DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1102000,-1102002,-1102003,-1102010,-1102011,-1102012,-1102015);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102000, 'WITH RECURSIVE coop_ini_info AS (
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
            cii.value = users.disp_user_id
        LEFT JOIN personal_list AS personal ON
            users.user_id = personal.user_id
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
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
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
        AND mm.is_del = ''0''
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
    (SELECT
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
    LIMIT 20
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
            WHEN ''0'' THEN LEAST((SELECT COUNT(*) FROM final_ord_medi_infos), 10)
            WHEN ''1'' THEN LEAST((SELECT COUNT(DISTINCT rp_num) FROM rp_num_assigned), 10)
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
), 
title_values AS (
    SELECT
        key2,
        value
    FROM coop_ini_info
    WHERE key1 = ''SCM_DIALYSISSCHESEND''
      AND key2 IN (''TREAT_IDX_TITLE'', ''INJECT_IDX_TITLE'')
),
cut_positions AS (
  SELECT
    key2,
    value,
    octet_length(value) AS byte_len,
    char_length(value) AS char_len,
    CASE WHEN octet_length(value) <= 56 THEN char_length(value)
    ELSE 
    (
      SELECT MAX(i)
      FROM generate_series(1, char_length(value)) AS i
      WHERE octet_length(substring(value FROM 1 FOR i)) <= 60
    ) END AS cut_index
  FROM title_values
),
title_limited AS (
  SELECT
    key2,
    substring(value FROM 1 FOR cut_index) AS limited_title
  FROM cut_positions
)
SELECT
    (SELECT limited_title FROM title_limited WHERE key2 = ''TREAT_IDX_TITLE'') AS treat_title,
    (SELECT limited_title FROM title_limited WHERE key2 = ''INJECT_IDX_TITLE'') AS shot_title,
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
    rp_count rc', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示', '2025-07-16 10:43:50.504', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102002, '-- SQL: -1102002 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_CONV_UNIT_MEDI''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit_equip,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON
  mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
-- 施設設定マスタから投与薬剤表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS a1
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3007''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3007''
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON
  mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON
  mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS ora
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3006''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3006''
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
      WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
      WHEN ''2'' THEN mt.in_hospital_cd_a2
      WHEN ''3'' THEN mt.in_hospital_cd_a3
      WHEN ''4'' THEN mt.in_hospital_cd_a4
    END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
      WHEN ''2'' THEN mt.in_hospital_cd_b2
      WHEN ''3'' THEN mt.in_hospital_cd_b3
      WHEN ''4'' THEN mt.in_hospital_cd_b4
    END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  1200 AS temp_no,
  om.ind_cond_info->''5''->>''value'' AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  1300 AS temp_no,
  om.ind_cond_info->''6''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  1800 AS temp_no,
  om.ind_cond_info->''25''->>''value'' AS mst_cd,
  (om.ind_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric
      WHEN ''2'' THEN 
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              ((om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric) * mst_mix.amount::numeric
        WHEN ''1'' THEN mst_mix.amount::numeric
      END
    END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_touseki AS (
-- 透析液
SELECT
  1900 AS temp_no,
  om.ind_cond_info->''15''->>''value'' AS mst_cd,
  (om.ind_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''16''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_hoeki AS (
-- 補液
SELECT
  2000 AS temp_no,
  om.ind_cond_info->''19''->>''value'' AS mst_cd,
  (om.ind_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,  
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.ind_cond_info->''22''->>''value'')::numeric
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_one_film AS (
-- 1次膜
SELECT
  1500 AS temp_no,
  om.ind_cond_info->''7''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_two_film AS (
-- 2次膜
SELECT
  1600 AS temp_no,
  om.ind_cond_info->''8''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  2100 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN CAST(medi_info ->> ''amount'' AS NUMERIC)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              CAST(medi_info ->> ''amount'' AS NUMERIC) * CAST(mst_mix.amount AS NUMERIC)
        WHEN ''1'' THEN
              CAST(mst_mix.amount AS NUMERIC)
      END
      ELSE 0
    END
  END AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
        CASE t1.medi_info ->> ''medicine_type''
             WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''1''
    AND mst_medi.is_del = ''0''
    AND mst_medi.is_disp = ''1''
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
  CROSS JOIN ini_value
  WHERE
    om.is_del = ''0''
    AND om.ord_no = @ordNo
    AND om.pat_id = @patId
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  1700 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1100 AS temp_no,
  CASE
    ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON
  mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_cd AS timing_cd,
    coa.procedure_cd AS procedure_cd,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd,
    coa.amount AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_cd AS timing_cd,
    tou.procedure_cd AS procedure_cd,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd,
    tou.amount AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_cd AS timing_cd,
    hoe.procedure_cd AS procedure_cd,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd,
    hoe.amount AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    imi.temp_no AS temp_no,
    imi.medicine_type AS medicine_type,
    imi.timing_cd AS timing_cd,
    imi.procedure_cd AS procedure_cd,
    imi.interval_no AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.amount AS amount,
    imi.unit AS unit
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
) AS ind_medi_table
LEFT JOIN mst_medi mmd ON
  ind_medi_table.mst_cd = mmd.medicine_cd::text
LEFT JOIN timing_order ON
  ind_medi_table.timing_cd = timing_order.timing_code
LEFT JOIN procedure_order ON
  ind_medi_table.procedure_cd = procedure_order.procedure_code
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(mst.pricedure_name) AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  CASE
    WHEN ((MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  medi_indo imi2
INNER JOIN mst_procedure mst
  ON mst.procedure_cd = imi2.procedure_cd
CROSS JOIN ini_value
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot = ''0''
  AND imi2.procedure_cd IS NOT NULL
GROUP BY
  imi2.procedure_cd,
  imi2.mst_cd,
  imi2.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
SELECT
  DISTINCT ON (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  ams.amount AS amount,
  ams.unit AS unit,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM
    equip_union
  GROUP BY
    hosp_cd,
    unit
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  ddi.amount AS amount,
  ddi.unit AS unit,
  NULL AS proc_cd
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''ダイアライザ'' AS title,
  dia.hosp_cd AS hosp_cd,
  dia.amount AS amount,
  dia.unit AS unit,
  NULL AS proc_cd
FROM
  ind_dialyzer dia
WHERE
  dia.hosp_cd IS NOT NULL
UNION ALL
SELECT
  eu.title AS title,
  eu.hosp_cd AS hosp_cd,
  eu.amount AS amount,
  eu.unit AS unit,
  NULL AS proc_cd
FROM
  equip_sort_union eu
WHERE
  eu.hosp_cd IS NOT NULL
UNION ALL
SELECT
  mu1.title AS title,
  mu1.hosp_cd AS hosp_cd,
  mu1.amount AS amount,
  mu1.unit AS unit,
  NULL AS proc_cd
FROM
  medi_union_1 mu1
WHERE
  mu1.hosp_cd IS NOT NULL
UNION ALL
SELECT
  mu2.title AS title,
  mu2.hosp_cd AS hosp_cd,
  mu2.amount AS amount,
  mu2.unit AS unit,
  mu2.pro_hosp_cd AS proc_cd
FROM
  medi_union_2 mu2
WHERE
  mu2.hosp_cd IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  CASE
    WHEN r.RP >= 11 THEN r.RP
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN r.RP >= 11 THEN r.RpItem
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
       OR (r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL))) THEN 2
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
       OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
       OR r.RpItem >= 20 AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20 AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
  JOIN numbered n ON n.rn = r.rn + 1
  CROSS JOIN ini_value m
WHERE
  r.RP < 10
)

, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  1 AS amount,
  '''' AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
  CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  RP AS rp_no,
  RpItem AS item_no,
  hosp_cd AS medi_cd,
  ROUND(amount, 4)::FLOAT8::TEXT AS medi_amount,
  unit,
  ''01'' AS detail_id
FROM
  final_data
ORDER BY
  RP,
  sort_key;

-- SQL: -1102002 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示_処置項目情報取得', '2025-07-01 17:38:01.233', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102003, 'WITH coop_ini_info AS (
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
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
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
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
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
            ord.treat_date,
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
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
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
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
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
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
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
        omi.registration_order AS registration_order,
        mst_medi.medi_code_order AS medi_code_order,
        mst_medi.medi_class_code_order AS class_code_order,
        omi.medicine_type::numeric AS medicine_type_order,
        t.timing_code_order AS timing_code_order,
        p.procedure_code_order AS procedure_code_order,
        omi.date_interval::numeric AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
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
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_count,
    LPAD(RIGHT(procedure_hosp_cd,2),2,'' '') AS procedure_hosp_cd
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    ROW_NUMBER() OVER (ORDER BY rp_num) AS sort_key,
    rp_num,
    COUNT(*) AS medi_count,
    MIN(LPAD(RIGHT(procedure_hosp_cd,2),2,'' '')) AS procedure_hosp_cd
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
GROUP BY
    rp_num', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-27 10:16:58.198', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102010, 'WITH coop_ini_info AS (
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
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
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
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
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
            ord.treat_date,
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
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
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
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
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
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
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
        omi.registration_order AS registration_order,
        mst_medi.medi_code_order AS medi_code_order,
        mst_medi.medi_class_code_order AS class_code_order,
        omi.medicine_type::numeric AS medicine_type_order,
        t.timing_code_order AS timing_code_order,
        p.procedure_code_order AS procedure_code_order,
        omi.date_interval::numeric AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
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
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
,select_seq AS(
    SELECT
        sort_key,
        ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
        1 AS medi_count,
        LPAD(RIGHT(procedure_hosp_cd,2),2,'' '') AS procedure_hosp_cd
    FROM
        sort_order
    WHERE
        sort_key <= 10
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    SELECT
        ROW_NUMBER() OVER (ORDER BY rp_num) AS sort_key,
        rp_num,
        COUNT(*) AS medi_count,
        MIN(LPAD(RIGHT(procedure_hosp_cd,2),2,'' '')) AS procedure_hosp_cd
    FROM
        medi_numbering
    WHERE
        rp_num <= 10
        AND new_sort_key <= 20
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        rp_num
)
SELECT 
   *
FROM
   select_seq
WHERE
   sort_key = @sortKey', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-25 09:35:04.176', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102011, 'WITH coop_ini_info AS (
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
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
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
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
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
            ord.treat_date,
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
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        round((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        CASE
            medi_mix_info ->> ''solvent''
            WHEN ''0'' THEN round(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
        END AS medi_amount,
        ini_unit.value AS unit_convert
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
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
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
        omi.registration_order AS registration_order,
        mst_medi.medi_code_order AS medi_code_order,
        mst_medi.medi_class_code_order AS class_code_order,
        omi.medicine_type::numeric AS medicine_type_order,
        t.timing_code_order AS timing_code_order,
        p.procedure_code_order AS procedure_code_order,
        omi.date_interval::numeric AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        medi_amount,
        unit_convert
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        SUM(medi_amount),
        MIN(unit_convert)
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
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
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd,
        f.medi_amount,
        f.unit_convert
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    ''01'' AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    medi_amount,
    unit_convert
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    new_sort_key AS sort_key,
    rp_num,
    medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    medi_amount,
    unit_convert
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-27 10:16:58.198', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102012, '-- SQL: -1102012 begin
WITH coop_ini_info AS (
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
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
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
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
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
            ord.treat_date,
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
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        round((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        CASE
            medi_mix_info ->> ''solvent''
            WHEN ''0'' THEN round(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
        END AS medi_amount,
        ini_unit.value AS unit_convert
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
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
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
        omi.registration_order AS registration_order,
        mst_medi.medi_code_order AS medi_code_order,
        mst_medi.medi_class_code_order AS class_code_order,
        omi.medicine_type::numeric AS medicine_type_order,
        t.timing_code_order AS timing_code_order,
        p.procedure_code_order AS procedure_code_order,
        omi.date_interval::numeric AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        medi_amount,
        unit_convert
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        SUM(medi_amount),
        MIN(unit_convert)
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
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
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd,
        f.medi_amount,
        f.unit_convert
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
,select_seq AS(
    SELECT
        sort_key,
        ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
        1 AS medi_num,
        LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
        ROUND(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
        unit_convert
    FROM
        sort_order
    WHERE
        sort_key <= 10
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    SELECT
        new_sort_key AS sort_key,
        rp_num,
        medi_num,
        LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
        ROUND(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
        unit_convert
    FROM
        medi_numbering
    WHERE
        rp_num <= 10
        AND new_sort_key <= 20
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
)
SELECT 
   *
FROM
   select_seq
WHERE
   sort_key = @sortKey
-- SQL: -1102012 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-24 17:02:31.955', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102015, '-- SQL: -1102015 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_CONV_UNIT_MEDI''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit_equip,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON
  mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
-- 施設設定マスタから投与薬剤表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS a1
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3007''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3007''
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON
  mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON
  mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS ora
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3006''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3006''
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
      WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
      WHEN ''2'' THEN mt.in_hospital_cd_a2
      WHEN ''3'' THEN mt.in_hospital_cd_a3
      WHEN ''4'' THEN mt.in_hospital_cd_a4
    END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
      WHEN ''2'' THEN mt.in_hospital_cd_b2
      WHEN ''3'' THEN mt.in_hospital_cd_b3
      WHEN ''4'' THEN mt.in_hospital_cd_b4
    END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  1200 AS temp_no,
  om.ind_cond_info->''5''->>''value'' AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  1300 AS temp_no,
  om.ind_cond_info->''6''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  1800 AS temp_no,
  om.ind_cond_info->''25''->>''value'' AS mst_cd,
  (om.ind_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric
      WHEN ''2'' THEN 
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              ((om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric) * mst_mix.amount::numeric
        WHEN ''1'' THEN mst_mix.amount::numeric
      END
    END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_touseki AS (
-- 透析液
SELECT
  1900 AS temp_no,
  om.ind_cond_info->''15''->>''value'' AS mst_cd,
  (om.ind_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''16''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_hoeki AS (
-- 補液
SELECT
  2000 AS temp_no,
  om.ind_cond_info->''19''->>''value'' AS mst_cd,
  (om.ind_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,  
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.ind_cond_info->''22''->>''value'')::numeric
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_one_film AS (
-- 1次膜
SELECT
  1500 AS temp_no,
  om.ind_cond_info->''7''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_two_film AS (
-- 2次膜
SELECT
  1600 AS temp_no,
  om.ind_cond_info->''8''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  2100 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN CAST(medi_info ->> ''amount'' AS NUMERIC)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              CAST(medi_info ->> ''amount'' AS NUMERIC) * CAST(mst_mix.amount AS NUMERIC)
        WHEN ''1'' THEN
              CAST(mst_mix.amount AS NUMERIC)
      END
      ELSE 0
    END
  END AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
        CASE t1.medi_info ->> ''medicine_type''
             WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''1''
    AND mst_medi.is_del = ''0''
    AND mst_medi.is_disp = ''1''
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
  CROSS JOIN ini_value
  WHERE
    om.is_del = ''0''
    AND om.ord_no = @ordNo
    AND om.pat_id = @patId
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  1700 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1100 AS temp_no,
  CASE
    ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON
  mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_cd AS timing_cd,
    coa.procedure_cd AS procedure_cd,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd,
    coa.amount AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_cd AS timing_cd,
    tou.procedure_cd AS procedure_cd,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd,
    tou.amount AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_cd AS timing_cd,
    hoe.procedure_cd AS procedure_cd,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd,
    hoe.amount AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    imi.temp_no AS temp_no,
    imi.medicine_type AS medicine_type,
    imi.timing_cd AS timing_cd,
    imi.procedure_cd AS procedure_cd,
    imi.interval_no AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.amount AS amount,
    imi.unit AS unit
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
) AS ind_medi_table
LEFT JOIN mst_medi mmd ON
  ind_medi_table.mst_cd = mmd.medicine_cd::text
LEFT JOIN timing_order ON
  ind_medi_table.timing_cd = timing_order.timing_code
LEFT JOIN procedure_order ON
  ind_medi_table.procedure_cd = procedure_order.procedure_code
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(mst.pricedure_name) AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  CASE
    WHEN ((MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  medi_indo imi2
INNER JOIN mst_procedure mst
  ON mst.procedure_cd = imi2.procedure_cd
CROSS JOIN ini_value
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot = ''0''
  AND imi2.procedure_cd IS NOT NULL
GROUP BY
  imi2.procedure_cd,
  imi2.mst_cd,
  imi2.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
  SELECT DISTINCT ON (un.hosp_cd) un.hosp_cd AS hosp_cd, un.r_num
  FROM (
    SELECT ROW_NUMBER() OVER () AS r_num, ut.hosp_cd FROM equip_union ut
  ) AS un
  ORDER BY un.hosp_cd, un.r_num
),
equip_sort_union AS (
  SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM equip_union
  GROUP BY hosp_cd, unit
),
union_table AS (
  SELECT ''治療方法'' AS title, hosp_cd, NULL AS proc_cd FROM ind_treatment
  UNION ALL
  SELECT ''透析困難コード'', hosp_cd, NULL FROM dial_diff_info WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT ''ダイアライザ'', hosp_cd, NULL FROM ind_dialyzer WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, NULL FROM equip_sort_union WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, NULL FROM medi_union_1 WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, pro_hosp_cd FROM medi_union_2 WHERE hosp_cd IS NOT NULL
),
numbered AS (
  SELECT *, ROW_NUMBER() OVER () AS rn FROM union_table
),
recursive_rp AS (
  SELECT
    n.rn,
    n.hosp_cd,
    n.proc_cd,
    1 AS RP,
    1 AS RpItem,
    NULL::text AS last_proc_cd,
    ARRAY[]::text[] AS proc_cd_list,
    FALSE AS need_procedure_insert,
    FALSE AS need_treatment_insert
  FROM numbered n, ini_value m
  WHERE n.rn = 1

  UNION ALL

  SELECT
    n.rn,
    n.hosp_cd,
    n.proc_cd,
    CASE
      WHEN r.RP >= 11 THEN r.RP
      WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
      WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL) THEN r.RP + 1
      ELSE r.RP
    END,
    CASE
      WHEN r.RP >= 11 THEN r.RpItem
      WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
         OR (r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL))) THEN 2
      ELSE r.RpItem + 1
    END,
    CASE WHEN n.proc_cd IS NOT NULL THEN n.proc_cd ELSE r.last_proc_cd END,
    CASE
      WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
      ELSE r.proc_cd_list
    END,
    CASE
      WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
         OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
         OR r.RpItem >= 20 AND n.proc_cd IS NOT NULL) THEN TRUE
      ELSE FALSE
    END,
    CASE
      WHEN r.RpItem >= 20 AND n.proc_cd IS NULL THEN TRUE
      ELSE FALSE
    END
  FROM recursive_rp r
  JOIN numbered n ON n.rn = r.rn + 1
  CROSS JOIN ini_value m
  WHERE r.RP < 10
),
procedure_inserts AS (
  SELECT
    RP, 1 AS RpItem, (rn - 0.5)::NUMERIC AS sort_key
  FROM recursive_rp
  WHERE need_procedure_insert
),
treatment_inserts AS (
  SELECT
    RP, 1 AS RpItem, (rn - 0.5)::NUMERIC AS sort_key
  FROM recursive_rp
  CROSS JOIN ind_treatment
  WHERE need_treatment_insert
),
recursive_rp_with_sort AS (
  SELECT RP, RpItem, rn::NUMERIC AS sort_key FROM recursive_rp
),
final_data AS (
  SELECT RP, RpItem, sort_key FROM recursive_rp_with_sort
  UNION ALL
  SELECT RP, RpItem, sort_key FROM procedure_inserts
  UNION ALL
  SELECT RP, RpItem, sort_key FROM treatment_inserts
)
,max_rp AS (
  SELECT MAX(RP) AS max_rp FROM final_data
),
rp_series AS (
  SELECT generate_series(1, (SELECT max_rp FROM max_rp)) AS RP
)
SELECT
  RP as rp_no,
  ''01'' AS detail_id
FROM rp_series;
-- SQL: -1102015 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_処置依頼ファイル_処置単位のRP番号取得', '2025-06-26 17:23:48.129', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
