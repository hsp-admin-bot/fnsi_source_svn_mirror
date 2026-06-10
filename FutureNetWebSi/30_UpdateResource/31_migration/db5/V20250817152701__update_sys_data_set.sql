DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1102000,-1102003,-1102010,-1102011,-1102012,-1102032);

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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
, pat_unique_dw AS (
	-- pat_unique.physical_info 内の各要素（JSONB配列）から「DW（目標体重）」を取得する。
	-- exam_date の形式には "YYYY-MM-DD"（日付のみ）と "YYYY-MM-DDTHH:MM:SS+09:00"（ISO 8601形式）が混在しているため、
	-- "T" の有無で形式を判別し、いずれも日付型に変換して比較を行っている。
	-- 比較対象は ord_main_max から取得した treat_date（YYYYMMDD形式）を DATE 型に変換したもの。
	-- 条件に合致する（treat_date 以下の）データのうち、exam_date が最も新しい1件の dw を取得する。
	-- 時刻部分は無視し、日付のみで比較を行っている。
    SELECT physical_data->>''dw'' AS latest_dw
    FROM (
        SELECT 
            physical_info_elem AS physical_data, 
            treat_date
        FROM pat_unique,
            LATERAL jsonb_array_elements(physical_info) AS physical_info_elem,
            (
                SELECT treat_date
                FROM ord_main_max
                LIMIT 1
            ) AS ord_max
        WHERE
        (
            CASE
            WHEN (physical_info_elem->>''exam_date'') ~ ''T''
                THEN (physical_info_elem->>''exam_date'')::timestamptz::date
            ELSE (physical_info_elem->>''exam_date'')::date
            END
        ) <= TO_DATE(ord_max.treat_date, ''YYYYMMDD'')
        ORDER BY (physical_info_elem->>''exam_date'')::date DESC
        LIMIT 1
    ) sub
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
        to_char(to_date(om.treat_date,''YYYYMMDD''),''YYYY-MM-DD'') AS treat_date,
        om.ind_cond_info ->''25''->>''medicine_type'' AS medicine_type,
        ROUND((om.ind_cond_info ->''1''->>''value'')::numeric) as dialysis_time,
        mv.va_name as va,
        -- 目標体重が-1の場合は、pat_uniqueから取得した最新のDWを使用
        ROUND(
            CASE WHEN (om.ind_cond_info -> ''3'' ->> ''value'') = ''-1'' THEN pat_unique_dw.latest_dw::numeric
                ELSE (om.ind_cond_info -> ''3'' ->> ''value'')::numeric
            END,
            2
        ) AS target_weight,
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
        COALESCE(mm.unit, mmx.unit) AS kou_unit,
		-- 透析液に値が存在する場合TRUEを返却する       
        CASE 
		  WHEN (om.ind_cond_info -> ''15'' ->> ''value'') IS NOT NULL THEN TRUE 
		  ELSE FALSE 
		END as is_dialysate_present,
		-- 補液に値が存在する場合TRUEを返却する       
        CASE 
		  WHEN (om.ind_cond_info -> ''19'' ->> ''value'') IS NOT NULL THEN TRUE 
		  ELSE FALSE 
		END as is_infusion_present,
		-- 抗凝固剤に値が存在する場合TRUEを返却する       
        CASE 
		  WHEN (om.ind_cond_info -> ''25'' ->> ''value'') IS NOT NULL THEN TRUE 
		  ELSE FALSE 
		END as is_anticoagulant_present
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
    LEFT JOIN pat_unique_dw ON true 
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
			-- 透析液が設定されている時のみ出力する
            CASE 
            WHEN omi.is_dialysate_present
            THEN mri.solution_resolve_flux || ''：'' || omi.solution_resolve_flux || '' mL/min''
            ELSE NULL 
            END,
            -- 補液が設定されている時のみ出力する 
            CASE 
            WHEN omi.is_infusion_present
            THEN mri.replace_resolve_measure || ''：'' || omi.replace_resolve_measure || '' L''
            ELSE NULL 
            END,
			-- 抗凝固剤が設定されている時のみ出力する
            CASE 
            WHEN omi.is_anticoagulant_present 
            THEN mri.kou_one_shot || ''：'' || omi.kou_one_shot || COALESCE('' '' || omi.kou_unit, '''') 
            ELSE NULL 
            END,
            CASE 
            WHEN omi.is_anticoagulant_present 
            THEN mri.kou_speed || ''：'' || omi.kou_speed || COALESCE('' '' || omi.kou_unit, '''') || 
                CASE 
                    WHEN omi.medicine_type = ''1'' AND omi.kou_unit IS NOT NULL THEN ''/h'' 
                    ELSE '''' 
                END
            ELSE NULL 
            END,
            CASE 
            WHEN omi.is_anticoagulant_present 
            THEN mri.kou_total || ''：'' || omi.kou_total || COALESCE('' '' || omi.kou_unit, '''') 
            ELSE NULL 
            END,
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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
        TRUNC((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
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
            WHEN ''0'' THEN TRUNC(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN TRUNC((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
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
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
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
        TRUNC((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
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
            WHEN ''0'' THEN TRUNC(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN TRUNC((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
        TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
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
        TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
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

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102032, 'WITH coop_ini_info AS (
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
            ''SCM_IN_HOSPITAL_CD''
        )
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
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mp.procedure_cd,
        ord.treat_date,
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
        mp.procedure_cd,
        ord.treat_date,
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
        MIN(NULLIF(CASE
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
	    END,'''')) AS procedure_hosp_cd,
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
    SELECT
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
)

SELECT
  ''01'' AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no
WHERE EXISTS (
  SELECT 1 FROM final_ord_medi_infos
)
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL', '2025-07-29 18:23:10.538', current_timestamp, NULL);