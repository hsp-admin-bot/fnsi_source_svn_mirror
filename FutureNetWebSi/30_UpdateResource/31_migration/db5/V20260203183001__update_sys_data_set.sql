DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
  -1100000,
  -1100019,
  -1100006,
  -1102000,
  -1102029,
  -1103000,
  -1103016
);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100000, '-- SQL:-1100000 begin
WITH all_values AS (
SELECT
  COALESCE(NULLIF(info.value, ''''), info.default_v) AS value,
  info.key1 AS key1,
  info.key2 AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL jsonb_to_recordset(ini.coop_ini_info::jsonb)
  AS info(key0 TEXT, key1 TEXT, key2 TEXT, value TEXT, default_v text)
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info.key0, '''') = @key0
  AND info.key1 IN (
    ''SCM_COMMON'',
    ''SCM_XRAY_ORDER_SEND'',
    ''SCM_CONV_UNIT_MEDI''
    )
  AND info.key2 IN (
    ''HOSPITAL_ID'',
    ''COURSE_CD1'',
    ''COURSE_CD2'',
    ''ml'',
    ''XX_TYPE_CODE''
  )
)
, ini_value AS (
  SELECT
    MAX(value) FILTER (WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') AS hospital_id,
    MAX(value) FILTER (WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') AS course_cd1,
    MAX(value) FILTER (WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') AS course_cd2,
    MAX(value) FILTER (WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    MAX(value) FILTER (WHERE key1 = ''SCM_COMMON'' AND key2 = ''XX_TYPE_CODE'') AS xx_type_code
  FROM all_values
)
, jounal AS (
SELECT
  to_char(reg_date, ''YYYY-MM-DD'') AS occur_date,
  to_char(reg_date, ''HH24:MI:SS'') AS occur_time
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo
)
SELECT
  ini_value.hospital_id AS hospital_id,
  ini_value.course_cd1 AS course_cd1,
  ini_value.course_cd2 AS course_cd2,
  ini_value.unit_medi AS unit_medi,
  ini_value.xx_type_code AS xx_type_code
FROM
  ini_value
CROSS JOIN jounal', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1100019, '-- SQL: -1100019 begin
with patid_len_setting as (
    select split_part(
            coalesce(nullif(x.value, ''''), x.default_v),
            '','',
            1
        ) as value
    from mst_coop_ini as ini
        cross join lateral jsonb_to_recordset(ini.coop_ini_info::jsonb) as x(
            key0 text,
            key1 text,
            key2 text,
            value text,
            default_v text
        )
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and x.key0 = @key0
        and x.key1 = ''SCM_COMMON''
        and x.key2 = ''PATID_LEN''
    limit 1
), patid_len as (
    select case
            when value::int > 12 then 12
            else value::int
        end as patid_len
    from patid_len_setting
),
conv_inout_to_karte_setting as (
    select x.key2,
        unnest(
            string_to_array(
                coalesce(nullif(x.value, ''''), x.default_v),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral jsonb_to_recordset(ini.coop_ini_info::jsonb) as x(
            key0 text,
            key1 text,
            key2 text,
            value text,
            default_v text
        )
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and x.key0 = @key0
        and x.key1 = ''CONV_INOUT_TO_KARTE''
),
conv_inout as (
    select jsonb_agg(
            to_jsonb(s)
            order by key2,
                value
        ) as conv_inout_to_karte
    from conv_inout_to_karte_setting s
)
select jsonb_build_object(
        ''patid_len'',( select patid_len from patid_len ),
        ''conv_inout_to_karte'',( select conv_inout_to_karte from conv_inout )
    )::text as settings;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（連携設定 患者ID桁数, 入外区分変換設定 取得用）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1100006, '-- SQL:-1100006 begin
with settings as (
    select @settings::jsonb as j
),
patid_len as (
    select (settings.j->>''patid_len'')::int as value
    from settings
),
conv_inout_to_karte_setting as (
    select key2,
        value
    from settings
        cross join lateral jsonb_to_recordset(settings.j->''conv_inout_to_karte'') as x(key2 text, value text)
),
converted_in_out_class as (
    --     in_out_class変換値の取得（なければ''1''をデフォルトにする）
    select ppm.pat_id,
        ppm.hosp_pat_id,
        ppm.in_out_class,
        coalesce(
            (
                select value
                from conv_inout_to_karte_setting
                where key2 = case
                        when ppm.in_out_class::text = ''3'' then ''0''
                        else ppm.in_out_class::text
                    end
                limit 1
            ), ''1''
        ) as converted_in_out_class
    from pat_personal_main ppm
    where ppm.pat_id = @patId
)
SELECT LPAD(
        RIGHT(converted.hosp_pat_id::text, p.value::integer),
        p.value::integer,
        ''0''
    ) AS hosp_pat_id,
    converted.converted_in_out_class AS in_out_class
FROM converted_in_out_class converted
cross join patid_len p', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100019, "field_name": "settings", "replace_var": "@settings"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102000, '-- SQL:-1102000 begin
WITH RECURSIVE coop_ini_info AS MATERIALIZED (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(r.value, ''''), r.default_v) AS value,
        r.key1,
        r.key2
    FROM mst_coop_ini ini
    CROSS JOIN LATERAL jsonb_to_recordset(ini.coop_ini_info::jsonb)
        AS r(key0 text, key1 text, key2 text, value text, default_v text)
    WHERE ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(r.key0, '''') = @key0
        AND r.key1 IN (''SCM_COMMON'',''SCM_DIALYSISSCHESEND'',''SCM_DIALYSISSCHESEND_KARTE_NOTE'',''SCM_IN_HOSPITAL_CD'')
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
        --DEFAULT_DOCTORの設定値がusers.disp_user_idに存在しない場合も考慮して設定値をそのまま取得する
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR'') AS defalut_disp_user_id,
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
    SELECT
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
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
        pat_unique.pat_id = @patId
        AND pat_unique.facility_cd = @facilityCd 
        AND 
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
        coalesce(NULLIF(
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''IN_HOSP_CD'')
            WHEN ''1'' THEN personal.in_hospital_cd_1
            WHEN ''2'' THEN personal.in_hospital_cd_2
        END, ''''),
        NULLIF((SELECT defalut_in_hospital_cd FROM default_doctor), ''''),
        NULLIF((SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_APPOINTMENT_SLOT_CODE''), '''')
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
            WHEN omi.in_hospital_cd IS NULL THEN NULL
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
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''),
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''),
            NULLIF((SELECT defalut_disp_user_id FROM default_doctor), ''''),
            ''''
            )
        END
    ,6) AS user_id,
    RIGHT(res_user_id,6) AS res_user_id,
    CASE WHEN cbn.in_hospital_cd IS NULL THEN ''''
    ELSE cbn.in_hospital_cd || cbn.bed_name
    END AS res_cd_comment,
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
    rp_count rc
-- SQL: -1102000 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102029, '-- SQL:-1102029 begin
WITH RECURSIVE -- mst_coop_distributeから設定を取得
distribute_setting AS (
  SELECT COALESCE(
      mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',
      ''|''
    ) AS file_name_delimiter,
    COALESCE(
      REPLACE(
        mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
        ''%s'',
        ''%''
      ),
      ''----- % -----''
    ) AS file_split_delimite_format
  FROM mst_coop_distribute mcd
  WHERE mcd.facility_cd = @facilityCd
    AND coop_cd = @coopCd
    AND is_del = ''0''
  LIMIT 1
)
-- 最新の新規登録のsys_coop_journalを取得
, get_sys_coop_journal AS (
  SELECT coop_result,
    ctl_no,
    STRING_TO_ARRAY(dump_path, ds.file_name_delimiter) AS path_array
  FROM sys_coop_journal
    CROSS JOIN distribute_setting ds
  WHERE coop_cd = @coopCd
    AND facility_cd = @facilityCd
    AND ord_no = @ordNo
    AND pat_id = @patId
    AND crud = ''C''
    AND dump_path IS NOT NULL
  ORDER BY up_date DESC
  LIMIT 1
)
-- ファイル名を取得
, file_names AS (
  SELECT u.ord AS id,
    u.path
  FROM get_sys_coop_journal j,
    UNNEST(j.path_array) WITH ORDINALITY AS u(path, ord)
)
-- ファイル数を取得
, file_count AS (
  SELECT COUNT(*) AS cnt
  FROM file_names
)
-- 透析指示連携で生成されるファイル種類の列挙
, file_sub_kinds(id, name) AS (
  SELECT *
  FROM (
    -- 12ファイル
    SELECT * FROM (VALUES
      (1, ''res''),
      (2, ''trt_index''),
      (3, ''trt_header''),
      (4, ''trt_unit''),
      (5, ''trt_item''),
      (6, ''trt_null''),
      (7, ''inj_index''),
      (8, ''inj_header''),
      (9, ''inj_unit''),
      (10, ''inj_item''),
      (11, ''inj_null''),
      (12, ''med'')
    ) v(id, name)
    WHERE (SELECT cnt FROM file_count) = 12
    UNION ALL
    -- 11ファイル
    SELECT * FROM (VALUES
      (1, ''trt_index''),
      (2, ''trt_header''),
      (3, ''trt_unit''),
      (4, ''trt_item''),
      (5, ''trt_null''),
      (6, ''inj_index''),
      (7, ''inj_header''),
      (8, ''inj_unit''),
      (9, ''inj_item''),
      (10, ''inj_null''),
      (11, ''med'')
    ) v(id, name)
    WHERE (SELECT cnt FROM file_count) = 11
    UNION ALL
    -- 7ファイル
    SELECT * FROM (VALUES
      (1, ''res''),
      (2, ''trt_index''),
      (3, ''trt_header''),
      (4, ''trt_unit''),
      (5, ''trt_item''),
      (6, ''trt_null''),
      (7, ''med'')
    ) v(id, name)
    WHERE (SELECT cnt FROM file_count) = 7
    UNION ALL
    -- 6ファイル
    SELECT * FROM (VALUES
      (1, ''trt_index''),
      (2, ''trt_header''),
      (3, ''trt_unit''),
      (4, ''trt_item''),
      (5, ''trt_null''),
      (6, ''med'')
    ) v(id, name)
    WHERE (SELECT cnt FROM file_count) = 6
  ) AS pattern
)
-- ファイル名とファイル種類を結合
, joined_files AS (
  SELECT fk.id,
    fk.name,
    fn.path
  FROM file_sub_kinds fk
    LEFT JOIN file_names fn ON fk.id = fn.id
)
-- SHIFT_JISにでコード（文字化け対策）
, decoded AS (
  SELECT ctl_no,
    CONVERT_FROM(dump, ''SHIFT_JIS'') AS text_data
  FROM sys_coop_journal
  WHERE ctl_no = (
      SELECT ctl_no
      FROM get_sys_coop_journal
    )
)
-- dumpの内容をレコードにして出力
, lines AS (
  SELECT l.ctl_no,
    ROW_NUMBER() OVER (
      PARTITION BY l.ctl_no
      ORDER BY ordinality
    ) AS rn,
    line
  FROM decoded l,
    LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
)
-- 再帰的にファイル名を伝播させる
, parsed AS (
  -- 初期状態：最初の行から始める
  SELECT l.ctl_no,
    l.rn,
    CASE
      WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\1'')
      ELSE NULL
    END AS file_name,
    CASE
      WHEN l.line NOT LIKE ds.file_split_delimite_format THEN l.line
      ELSE NULL
    END AS content
  FROM lines l
    CROSS JOIN distribute_setting ds
  WHERE rn = 1
  UNION ALL
  -- 次の行にファイル名を引き継ぐ
  SELECT l.ctl_no,
    l.rn,
    CASE
      WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\1'')
      ELSE p.file_name
    END AS file_name,
    CASE
      WHEN l.line NOT LIKE ds.file_split_delimite_format THEN l.line
      ELSE NULL
    END AS content
  FROM lines l
    CROSS JOIN distribute_setting ds
    JOIN parsed p ON l.ctl_no = p.ctl_no
    AND l.rn = p.rn + 1
)

-- ファイル種別ごとの内容行を抽出
, file_content_rows AS (
  SELECT 
    jf.name AS file_sub_kind,
    p.file_name,
    ARRAY_AGG(
      t.col
      ORDER BY t.ordinality
    ) AS content_array
  FROM parsed p
    LEFT JOIN joined_files jf ON p.file_name = jf.path,
    LATERAL ntss.parse_csv_row(p.content) WITH ORDINALITY AS t(col, ordinality)
  WHERE p.content IS NOT NULL
  GROUP BY p.ctl_no,
    p.file_name,
    jf.name,
    p.rn
)
, content_cte AS (
  SELECT
    file_sub_kind,
    JSON_AGG(content_array)::TEXT AS content_json
  FROM file_content_rows
  WHERE file_sub_kind = @fileSubKind
  GROUP BY file_sub_kind
)

SELECT *
FROM content_cte

UNION ALL
-- content_cteがなかったときはデフォルト値を返す
SELECT
  NULL AS file_sub_kind,
  ''[]'' AS content_json
WHERE NOT EXISTS (SELECT 1 FROM content_cte);
-- SQL:-1102029 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 新規処理dump取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103000, '-- SQL: -1103000 begin
WITH RECURSIVE coop_ini_info AS (
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
  AND info ->> ''key1'' IN(
            ''SCM_DIALYSISSEND'',
            ''SCM_COMMON'',
            ''SCM_DIALYSISSEND_KARTE_NOTE'',
            ''PAT_EVENT_TEMPLATE_SETTING''
        )
)
, ini_value AS(
--連携設定取得値
SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_IDX_TITLE'') AS treat_title,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''FREE_WORD'') AS free_word,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_BEFORE'') AS weight_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_AFTER'') AS weight_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_BEFORE'') AS vital_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_AFTER'') AS vital_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''START_DATE'') AS start_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''END_DATE'') AS end_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADD_TOTAL'') AS add_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''DIALYSIS_TIME'') AS dialysis_time,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VA'') AS va,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''TARGET_WEIGHT'') AS target_weight,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''BLOOD_FLOW'') AS blood_flow,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''SOLUTION_RESOLVE_FLUX'') AS solution_resolve_flux,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''REPLACE_RESOLVE_MEASURE'') AS replace_resolve_measure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_ONE_SHOT'') AS kou_one_shot,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_SPEED'') AS kou_speed,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_TOTAL'') AS kou_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADDITION'') AS addition,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''PAT_LIFE'') AS pat_life,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KARTE_SUB_CATEGORIES'') AS karte_sub_categories,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''TEXTBOX'') AS textbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''TEXTAREA'') AS textarea,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''IMAGE'') AS pat_event_image,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''LISTBOX'') AS listbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''RADIOBUTTON'') AS radiobutton,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''DATE'') AS pat_event_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''CHECKBOX'') AS checkbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''FILE_ATTACHMENT'') AS file_attachment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''SCORE_CALCULATION'') AS score_calculation,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''BULLETIN_LINK'') AS bulletin_link
)
, staff_cd_list AS (
--担当医の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id,
  ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
FROM
  pat_main pm
CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  staff_info ->> ''staff_cd'' = users ->> ''user_id''
WHERE
  pm.facility_cd = @facilityCd
  AND pm.pat_id = @patId
  AND pm.is_del = ''0''
  AND staff_info ->> ''is_main'' = ''1''
)
, journal_staff_cd AS (
--版確定者の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id
FROM
  sys_coop_journal AS journal
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  journal.user_id = (users ->> ''user_id'')::NUMERIC
WHERE
  journal.ctl_no = @ctlNo
  AND journal.facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.del_date AS up_date,
            ord.rst_cond_info,
            ord.ind_kur_cd,
            ord.rst_treatment_cd,
            ord.rst_start_date,
            ord.rst_end_date,
            ord.treat_date,
            ord.rst_weight_info,
            ord.rst_running_time,
            ord.rst_ind_comment_info,
            ord.ord_no,
            ord.facility_cd,
            ord.is_del,
            ord.pat_id
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
            AND journal.ord_no = @ordNo            
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            ord.rst_edition_date AS up_date,
            ord.rst_cond_info,
            ord.ind_kur_cd,
            ord.rst_treatment_cd,
            ord.rst_start_date,
            ord.rst_end_date,
            ord.treat_date,
            ord.rst_weight_info,
            ord.rst_running_time,
            ord.rst_ind_comment_info,
            ord.ord_no,
            ord.facility_cd,
            ord.is_del,
            ord.pat_id
        FROM
            ord_main AS ord
        WHERE
        	ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_main_info AS (
-- 治療情報
SELECT
  to_char(om.rst_start_date, ''YYYY-MM-DD'') AS rst_start_date,
  to_char(om.rst_start_date, ''HH24:MI:SS'') AS rst_start_time,
  to_char(om.rst_end_date, ''HH24:MI:SS'') AS rst_end_time,
  to_char(
    TRUNC(EXTRACT(EPOCH FROM (rst_end_date - rst_start_date)) / 60),
    ''FM9990''
) AS treat_time,
  to_char(om.treat_date::timestamp, ''YYYY-MM-DD'') AS treat_date,
  to_char(mk.kur_standard_start_time::time, ''HH24:MI:SS'') AS kur_standard_start_time,
  ROUND((om.rst_weight_info ->> ''weight_before'')::NUMERIC, 2) AS weight_before,
  ROUND((om.rst_weight_info ->> ''weight_after'')::NUMERIC, 2) AS weight_after,
  ROUND((om.rst_weight_info ->> ''water_removal_rst'')::NUMERIC, 2) AS add_total,
  mv.va_name AS va_name,
  ROUND((om.rst_cond_info ->''3''->>''value'')::NUMERIC, 2) AS target_weight,
  ROUND((om.rst_cond_info ->''14''->>''value'')::NUMERIC) AS blood_flow,
  ROUND((om.rst_cond_info ->''16''->>''value'')::NUMERIC) AS alqd_flood_vol,
  CASE WHEN mt.device_mode not in (10) THEN ROUND((om.rst_cond_info ->''20''->>''value'')::NUMERIC, 1) ELSE NULL END AS repl_amount,
  ROUND((om.rst_cond_info ->''26''->>''value'')::NUMERIC, 2) AS anti_oneshot,
  ROUND((om.rst_cond_info ->''27''->>''value'')::NUMERIC, 2) AS anti_speed,
  ROUND((om.rst_cond_info ->''28''->>''value'')::NUMERIC, 2) AS anti_amount,
  om.rst_running_time AS rst_running_time,
  (SELECT
    string_agg(elem ->> ''content'', E''\r\n'')
  FROM
    jsonb_array_elements(om.rst_ind_comment_info) AS elem
    ) AS addition,
  COALESCE(mm.unit, mmx.unit) AS kou_unit,
  -- 透析液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''15'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_dialysate_present,
  -- 補液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''19'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_infusion_present,
  -- 抗凝固剤に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''25'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_anticoagulant_present
FROM
  ord_main_max om
LEFT JOIN mst_va mv ON om.rst_cond_info ->''2''->>''value'' = mv.va_cd::text
LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd AND mk.facility_cd = @facilityCd
LEFT JOIN mst_treatment mt on om.rst_treatment_cd = mt.treatment_cd AND mt.facility_cd = @facilityCd
LEFT JOIN mst_medicine mm ON om.rst_cond_info ->''25''->>''medicine_type'' = ''1''
  AND om.rst_cond_info ->''25''->>''value'' = mm.medicine_cd::text
  AND mm.facility_cd = @facilityCd
LEFT JOIN mst_medicine_mix mmx ON om.rst_cond_info ->''25''->>''medicine_type'' = ''2''
  AND om.rst_cond_info ->''25''->>''value'' = mmx.medicine_mix_cd::text
  AND mmx.facility_cd = @facilityCd
WHERE
  om.ord_no = @ordNo
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.pat_id = @patId
)
, mni_monitor_info AS (
--装置モニタデータから取得
SELECT
  mm.data_type,
  mm.monitor_data ->> ''90'' AS b_max,
  mm.monitor_data ->> ''91'' AS b_min,
  mm.monitor_data ->> ''92'' AS b_ave,
  mm.monitor_data ->> ''93'' AS pulse
FROM
  mni_monitor mm
WHERE
  data_type IN (''5'', ''6'')
    AND mm.ord_no = @ordNo
    AND mm.pat_id = @patId
    AND mm.is_del = ''0''
)
, send_his_memo AS (
-- 送信履歴メモ
SELECT
  save_2 ->> ''injection_send_day'' AS req_date,
  save_2 ->> ''injection_seq_no'' AS req_seq_no,
  save_2 ->> ''injection_user_id'' AS req_user_id,
  save_2 ->> ''treatment_send_day'' AS tre_send_day,
  save_2 ->> ''treatment_seq_no'' AS tre_seq_no,
  save_2 ->> ''treatment_user_id'' AS tre_user_id
FROM
  pat_coop_detail
WHERE
  facility_cd = @facilityCd
  AND pat_id = @patId
  AND save_2 ->> ''ord_no'' = @ordNo::TEXT
  AND save_2 ->> ''coop_cd'' = ''ind_dial''
ORDER BY
  up_date DESC
LIMIT 1
)
, coop_detail AS (
SELECT
  sh.req_date AS req_date,
  sh.req_seq_no AS req_seq_no,
  sh.req_user_id AS req_user_id,
  sh.tre_send_day AS tre_send_day,
  sh.tre_seq_no AS tre_seq_no,
  sh.tre_user_id AS tre_user_id
FROM
  send_his_memo sh
UNION ALL
SELECT
  '''',
  '''',
  '''',
  '''',
  '''',
  ''''
WHERE
  NOT EXISTS (SELECT 1 FROM send_his_memo)
)
, pat_event_category_order AS (
-- 患者イベントカテゴリマスタ表示順
SELECT
  index_no ::int AS category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_category''
)
, pat_event_sub_category_order AS (
-- 患者イベントサブカテゴリマスタ表示順
SELECT
  index_no ::int AS sub_category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS sub_category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_sub_category''
)
, pat_event_info AS materialized (
--観察記録情報
SELECT
  pe.event_start_date::date AS rec_date,
  pe.category_cd AS category_cd,
  pe.sub_category_cd AS sub_category_cd,
  coalesce(pe.event_start_time, ''0000'') AS event_start_time,
  pe.sub_category_name::text AS label_name,
  STRING_AGG(
    CASE
      WHEN ini.textbox = ''1'' AND (input.params ->> ''format_class'') = ''0'' AND COALESCE((result.params ->> ''result_value''), '''') <> '''' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params ->> ''result_value'')
      WHEN ini.textarea = ''1'' AND (input.params ->> ''format_class'') = ''1'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\r\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\r\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\r\n'', '''', ''''), E''\r\n$'', '''', ''''), E''(\\r?\\n)+'', E''\r\n   '', ''g''),E''\uFEFF'' ,''''))

      WHEN ini.pat_event_image = ''1'' AND (input.params ->> ''format_class'') = ''2''
      AND COALESCE(rv.has_file,false)
      THEN rv.file_lines
      
      WHEN ini.listbox = ''1'' AND (input.params ->> ''format_class'') = ''3'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''name'')
      WHEN ini.radiobutton = ''1'' AND (input.params ->> ''format_class'') = ''4'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''name'')
      WHEN ini.pat_event_date = ''1'' AND (input.params ->> ''format_class'') = ''5'' 
      AND COALESCE((result.params ->> ''result_value''), '''') <> ''''
      THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || to_char((result.params ->> ''result_value'')::date, ''YYYY/MM/DD'')

      WHEN ini.checkbox = ''1'' AND (input.params ->> ''format_class'') = ''6'' THEN
      COALESCE(input.params ->> ''field_name'','''') || '':'' || COALESCE(rv.names_agg,'''') 

        WHEN ini.file_attachment = ''1'' AND (input.params ->> ''format_class'') = ''7'' THEN
        rv.file_lines

      WHEN ini.score_calculation = ''1'' AND (input.params ->> ''format_class'') = ''8'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''score'') || (result.params -> ''result_value'' ->> ''unit'')
      WHEN ini.bulletin_link = ''1'' AND (input.params ->> ''format_class'') = ''10'' THEN 
        CASE WHEN COALESCE(result.params -> ''result_value'' ->> ''notice_start_date'', '''') <> ''''
          THEN ''掲示板リンク:掲載有り'' || E''\r\n'' || ''期間:''|| to_char((result.params -> ''result_value'' ->> ''notice_start_date'')::timestamptz, ''YYYY/MM/DD'') || '' - '' || to_char((result.params -> ''result_value'' ->> ''notice_end_date'')::timestamptz, ''YYYY/MM/DD'')
          ELSE ''掲示板リンク:掲載無し''
        END
    END,
    E''\r\n''
    ORDER BY input.idx
  ) AS content
FROM
  pat_event pe
CROSS JOIN LATERAL 
  jsonb_array_elements(pe.input_params ::jsonb) WITH ORDINALITY AS input(params, idx)
JOIN LATERAL (
  SELECT pe.result_params::jsonb -> ((input.idx - 1)::int) AS params
) AS RESULT
  ON RESULT.params IS NOT NULL
  CROSS JOIN ini_value ini

  LEFT JOIN LATERAL (
    SELECT
      bool_or(COALESCE(elem->>''file_name'', '''') <> '''') AS has_file,
      string_agg(
        COALESCE(input.params->>''field_name'', '''') || '':'' || (elem->>''file_name''),
        E''\r\n'' ORDER BY ord
      ) FILTER (WHERE COALESCE(elem->>''file_name'', '''') <> '''') AS file_lines,
      string_agg(elem->>''name'', '','' ORDER BY ord) AS names_agg
    FROM jsonb_array_elements(COALESCE(result.params->''result_value'',''[]''::jsonb))
      WITH ORDINALITY AS t(elem,ord)
  ) rv
    ON (
      (ini.pat_event_image=''1'' AND input.params->>''format_class''=''2'')
      OR (ini.checkbox=''1'' AND input.params->>''format_class''=''6'')
      OR (ini.file_attachment=''1'' AND input.params->>''format_class''=''7'')
    )

WHERE
  pe.facility_cd = @facilityCd
  AND pe.pat_id = @patId
  AND pe.ord_no = @ordNo
  AND pe.is_del = ''0''
  AND pe.use_type = 2
  AND pe.event_start_date IS NOT NULL
  AND pe.sub_category_name = ANY (string_to_array(ini.karte_sub_categories, '',''))
GROUP BY
  pe.pat_event_cd
)
, merged_pat_event_category as (
-- サブカテゴリ毎にマージした観察記録情報
  SELECT
    rec_date,
    label_name || '':'' || E''\r\n'' ||
      STRING_AGG(
      content,
      E''\r\n''
      ORDER BY label_name, event_start_time
    ) AS merged_content,
    category_code_order,
    sub_category_code_order
  FROM pat_event_info pei
  left join pat_event_category_order peco on pei.category_cd = peco.category_code
  left join pat_event_sub_category_order pesco on pei.sub_category_cd = pesco.sub_category_code
  GROUP BY rec_date, label_name,category_code_order,sub_category_code_order
  ORDER BY rec_date
)
, merged_pat_event_contents as (
-- 日付毎にマージした観察記録情報
  SELECT
    rec_date,
    STRING_AGG(
      merged_content,
      E''\r\n''
      ORDER BY category_code_order, sub_category_code_order
    ) AS merged_content
  FROM merged_pat_event_category
  GROUP BY rec_date
  ORDER BY rec_date
)
, karute_txt AS (
-- カルテ記録テキスト
SELECT
  COALESCE(ini.free_word) AS free_word,
  CASE
    WHEN ini.weight_before <> '''' AND om.weight_before IS NOT NULL THEN
        ini.weight_before || '':'' || om.weight_before || '' Kg''
      ELSE NULL
  END AS weight_before,
  CASE
    WHEN ini.weight_after <> '''' AND om.weight_after IS NOT NULL THEN
    ini.weight_after || '':'' || om.weight_after || '' Kg''
    ELSE NULL
  END AS weight_after,
  CASE
    WHEN ini.vital_before <> '''' THEN
    ini.vital_before || '':'' ||
     array_to_string(ARRAY[
     COALESCE(vbefore.b_max, ''-''), COALESCE(vbefore.b_min, ''-''), 
     COALESCE(vbefore.b_ave, ''-''), ''('' || COALESCE(vbefore.pulse, ''-'') || '')''], ''/'')
    ELSE NULL
  END AS vital_before,
  CASE
    WHEN ini.vital_after <> '''' THEN
    ini.vital_after || '':'' ||
    array_to_string(ARRAY[
    COALESCE(vafter.b_max, ''-''), COALESCE(vafter.b_min, ''-''), 
    COALESCE(vafter.b_ave, ''-''), ''('' || COALESCE(vafter.pulse, ''-'') || '')''], ''/'')
      ELSE NULL
  END AS vital_after,
  CASE
    WHEN ini.start_date <> '''' AND om.rst_start_time IS NOT NULL THEN
      ini.start_date || '':'' || om.rst_start_time::text
    ELSE NULL
  END AS start_date,
  CASE
    WHEN ini.end_date <> '''' AND om.rst_end_time IS NOT NULL THEN
      ini.end_date || '':'' || om.rst_end_time
    ELSE NULL
  END AS end_date,
  CASE
    WHEN ini.add_total <> '''' AND om.add_total IS NOT NULL THEN
      ini.add_total || '':'' || om.add_total || '' L''
    ELSE NULL
  END AS add_total,
  CASE
    WHEN ini.dialysis_time <> '''' AND om.treat_time IS NOT NULL THEN
      ini.dialysis_time || '':'' || om.treat_time || '' 分''
    ELSE NULL
  END AS dialysis_time,
  CASE
    WHEN ini.va <> '''' AND om.va_name IS NOT NULL THEN
      ini.va || '':'' || om.va_name
    ELSE NULL
  END AS va,
  CASE
    WHEN ini.target_weight <> '''' AND om.target_weight IS NOT NULL THEN
      ini.target_weight || '':'' || om.target_weight || '' Kg''
    ELSE NULL
  END AS target_weight,
  CASE
    WHEN ini.blood_flow <> '''' AND om.blood_flow IS NOT NULL THEN
      ini.blood_flow || '':'' || om.blood_flow || '' mL/min''
    ELSE NULL
  END AS blood_flow,
  -- 透析液が設定されている時のみ出力
  CASE
    WHEN ini.solution_resolve_flux <> '''' AND om.alqd_flood_vol IS NOT NULL AND om.is_dialysate_present THEN
      ini.solution_resolve_flux || '':'' || om.alqd_flood_vol || '' mL/min''
    ELSE NULL
  END AS solution_resolve_flux,
  -- 補液が設定されている時のみ出力
  CASE
    WHEN ini.replace_resolve_measure <> '''' AND om.repl_amount IS NOT NULL AND om.is_infusion_present THEN
      ini.replace_resolve_measure || '':'' || om.repl_amount || '' L''
    ELSE NULL
  END AS replace_resolve_measure,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_one_shot <> '''' AND om.anti_oneshot IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_one_shot || '':'' || om.anti_oneshot || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_one_shot,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_speed <> '''' AND om.anti_speed IS NOT NULL  AND om.is_anticoagulant_present THEN
      ini.kou_speed || '':'' || om.anti_speed || COALESCE('' '' || om.kou_unit || ''/h'', '''')
    ELSE NULL
  END AS kou_speed,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_total <> '''' AND om.anti_amount IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_total || '':'' || om.anti_amount || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_total,
  CASE
    WHEN ini.addition <> '''' AND om.addition IS NOT NULL THEN
      ini.addition || '':'' || E''\r\n'' || om.addition
    ELSE NULL
  END AS ind_comment,
  CASE
    WHEN ini.pat_life = ''1'' THEN
     merged_content
    ELSE NULL
  END AS obs_record
FROM
  ord_main_info om
CROSS JOIN ini_value ini
LEFT JOIN merged_pat_event_contents pe ON pe.rec_date::date = om.treat_date::date
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''5'' ) AS vbefore ON TRUE
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''6'') AS vafter ON TRUE
)
, cut_positions AS (
SELECT
  ini.treat_title AS value,
  octet_length(ini.treat_title) AS byte_len,
  char_length(ini.treat_title) AS char_len,
  CASE
    WHEN octet_length(ini.treat_title) <= 56 THEN char_length(ini.treat_title)
    ELSE 
    (SELECT
      MAX(i)
    FROM
      generate_series(1, char_length(ini.treat_title)) AS i
    WHERE
      octet_length(substring(ini.treat_title FROM 1 FOR i)) <= 60
    )
  END AS cut_index
FROM
  ini_value ini
)
, title_limited AS (
SELECT
  substring(value FROM 1 FOR cut_index) AS limited_title
FROM
  cut_positions
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
, default_doctor AS (
    --デフォルト医師の院内コードと表示用利用者IDを取得
    SELECT
        --DEFAULT_DOCTORの設定値がusers.disp_user_idに存在しない場合も考慮して設定値をそのまま取得する
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR'') AS defalut_disp_user_id,
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
SELECT
  RIGHT(
        CASE (SELECT value::NUMERIC FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN ''0'' THEN 
            (SELECT disp_user_id FROM journal_staff_cd)
        WHEN ''1'' THEN 
            COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''),
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''),
            NULLIF((SELECT defalut_disp_user_id FROM default_doctor), ''''),
            ''''
            )
        END
    , 6) AS user_id,
  (SELECT
    limited_title
  FROM
    title_limited) AS treat_title,
  omi.treat_date AS treat_date,
  omi.rst_start_date AS rst_start_date,
  omi.rst_start_time AS rst_start_time,
  TO_CHAR(TO_DATE(cd.tre_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS treatment_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.tre_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS treatment_req_seq_no,
  cd.tre_user_id AS treatment_req_user_id,
  TO_CHAR(TO_DATE(cd.req_date, ''YYYYMMDD''), ''YYYY-MM-DD'') AS injection_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.req_seq_no::TEXT, ''HH24MISS''), ''HH24:MI:SS'') AS injection_req_seq_no,
  cd.req_user_id AS injection_req_user_id,
  omi.kur_standard_start_time AS kur_standard_start_time,
  array_to_string(array_remove(ARRAY[
      kt.free_word,
      kt.weight_before,
      kt.weight_after,
      kt.vital_before,
      kt.vital_after,
      kt.start_date,
      kt.end_date,
      kt.add_total,
      kt.dialysis_time,
      kt.va,
      kt.target_weight,
      kt.blood_flow,
      kt.solution_resolve_flux,
      kt.replace_resolve_measure,
      kt.kou_one_shot,
      kt.kou_speed,
      kt.kou_total,
      kt.ind_comment,
      kt.obs_record
    ], NULL),
    E''\r\n''
  ) AS medical_record_text
FROM
  ord_main_info omi,
  karute_txt kt,
  coop_detail cd
-- SQL: -1103000 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103016, '-- SQL:-1103016 begin
WITH RECURSIVE 
distribute_setting AS (
    -- mst_coop_distributeから設定を取得
    SELECT COALESCE(
            mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',
            ''|''
        ) AS file_name_delimiter,
        COALESCE(
            REPLACE(
                mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
                ''%s'',
                ''%''
            ),
            ''----- % -----''
        ) AS file_split_delimite_format
    FROM mst_coop_distribute mcd
    WHERE mcd.facility_cd = @facilityCd
        AND coop_cd = @coopCd
        AND is_del = ''0''
    LIMIT 1
) 
,
get_sys_coop_journal AS (
    -- 最新の新規登録のsys_coop_journalを取得
    SELECT coop_result,
        ctl_no,
        STRING_TO_ARRAY(dump_path, ds.file_name_delimiter) AS path_array
    FROM sys_coop_journal
        CROSS JOIN distribute_setting ds
    WHERE coop_cd = @coopCd
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND crud = ''C''
        AND dump_path IS NOT NULL
    ORDER BY up_date DESC
    LIMIT 1
), file_names AS (
    -- ファイル名を取得
    SELECT u.ord AS id,
        u.path
    FROM get_sys_coop_journal j,
        UNNEST(j.path_array) WITH ORDINALITY AS u(path, ord)
),
file_count AS (
    -- ファイル数を取得
    SELECT COUNT(*) AS cnt
    FROM file_names
),

max_id AS (
    -- max id を取得（最後が med）
    SELECT MAX(id) AS max_id
    FROM file_names
) 
,
pattern_flags AS (
    -- ファイル出力状況がどのパターンに該当するかを判定
    SELECT cnt,
        -- パターン1: trtあり + injあり + medあり
        CASE
            WHEN cnt >= 9
            AND (cnt - 6) % 3 = 0 THEN TRUE
            ELSE FALSE
        END AS is_pattern1,
        -- パターン2: trtなし + injあり + medあり 
        CASE
            WHEN cnt >= 4
            AND (cnt - 1) % 3 = 0 THEN TRUE
            ELSE FALSE
        END AS is_pattern2,
        -- パターン3: trtあり + injなし + medあり
        CASE
            WHEN cnt = 6 THEN TRUE
            ELSE FALSE
        END AS is_pattern3,
        -- パターン4: trtなし + injなし + medあり
        CASE
            WHEN cnt = 1 THEN TRUE
            ELSE FALSE
        END AS is_pattern4
    FROM file_count
),
inj_files AS (
    -- inj_xxx 割り当て（trtの有無に応じてIDの開始を切り替え）
    SELECT fn.id,
        ROW_NUMBER() OVER (
            ORDER BY fn.id
        ) AS rn
    FROM file_names fn,
        file_count,
        pattern_flags
    WHERE 
        -- パターン1, 3 の場合は処置実績(trt_xxx) が存在するので5からスタート
        -- パターン2 の場合は処置実績 が存在しないので、先頭から使えるため id > 0
        fn.id > CASE
            WHEN is_pattern1 THEN 5
            WHEN is_pattern3 THEN 5
            ELSE 0
        END
        -- file_names の最大ID（つまり最後のファイル＝med）を除外
        AND fn.id < (
            SELECT max_id
            FROM max_id
        )
),
inj_tagged AS (
    SELECT id,
        CASE
            (rn - 1) % 3
            WHEN 0 THEN ''inj_index''
            WHEN 1 THEN ''inj_item''
            WHEN 2 THEN ''inj_null''
        END AS name
    FROM inj_files
),
trt_fixed AS (
    SELECT *
    FROM (
            VALUES (1, ''trt_index''),
                (2, ''trt_header''),
                (3, ''trt_unit''),
                (4, ''trt_item''),
                (5, ''trt_null'')
        ) AS t(id, name)
),
med_file AS (
    SELECT id,
        ''med'' AS name
    FROM file_names
    WHERE id = (
            SELECT max_id
            FROM max_id
        )
),
-- パターンごとのファイル種別を組み合わせ
file_sub_kinds AS (
    SELECT *
    FROM trt_fixed
    WHERE EXISTS (
            SELECT 1
            FROM pattern_flags
            WHERE is_pattern1
                OR is_pattern3
        )
    UNION ALL
    SELECT *
    FROM inj_tagged
    WHERE EXISTS (
            SELECT 1
            FROM pattern_flags
            WHERE is_pattern1
                OR is_pattern2
        )
    UNION ALL
    SELECT *
    FROM med_file
) 
,joined_files AS (
    -- ファイル名とファイル種類を結合
    SELECT fk.id,
        fk.name,
        fn.path
    FROM file_sub_kinds fk
        LEFT JOIN file_names fn ON fk.id = fn.id
) 
,decoded AS (
    -- SHIFT_JISにでコード（文字化け対策）
    SELECT ctl_no,
        CONVERT_FROM(dump, ''SHIFT_JIS'') AS text_data
    FROM sys_coop_journal
    WHERE ctl_no = (
            SELECT ctl_no
            FROM get_sys_coop_journal
        )
) 
,lines AS (
    -- dumpの内容をレコードにして出力
    SELECT l.ctl_no,
        ROW_NUMBER() OVER (
            PARTITION BY l.ctl_no
            ORDER BY ordinality
        ) AS rn,
        line
    FROM decoded l,
        LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
),
multiple_file_parsed AS (
    -- 複数ファイルが出力されている時は再帰的にファイル名を伝播させる
    -- 初期状態：最初の行から始める
    SELECT l.ctl_no,
        l.rn,
        CASE
            WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\1'')
            ELSE NULL
        END AS file_name,
        CASE
            WHEN l.line NOT LIKE ds.file_split_delimite_format THEN l.line
            ELSE NULL
        END AS content
    FROM lines l
        CROSS JOIN distribute_setting ds
    WHERE rn = 1
    UNION ALL
    -- 次の行にファイル名を引き継ぐ
    SELECT l.ctl_no,
        l.rn,
        CASE
            WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\1'')
            ELSE p.file_name
        END AS file_name,
        CASE
            WHEN l.line NOT LIKE ds.file_split_delimite_format THEN l.line
            ELSE NULL
        END AS content
    FROM lines l
        CROSS JOIN distribute_setting ds
        JOIN multiple_file_parsed p ON l.ctl_no = p.ctl_no
        AND l.rn = p.rn + 1
),
single_file_parsed as (
    -- ファイル数が1件の時はdump内にファイル名が入ってこないためそのまま返却
    select jf.name as file_sub_kind,
        jf.path as file_name,
        case
            when l.line not like ds.file_split_delimite_format then l.line
            else null
        end as content
    from lines l
        CROSS JOIN distribute_setting ds
        cross join joined_files jf
    where (
            select cnt
            from file_count
        ) = 1
) 
,file_content_rows AS (
    -- ファイル種別ごとの内容行を抽出
    -- 単一ファイルの時
    select p.file_sub_kind,
        p.file_name,
        ARRAY_AGG(
            t.col
            ORDER BY t.ordinality
        ) AS content_array
    from single_file_parsed p,
        LATERAL ntss.parse_csv_row(p.content) WITH ORDINALITY AS t(col, ordinality)
    where p.content IS NOT null
        and (
            select cnt
            from file_count
        ) = 1
    GROUP BY file_sub_kind,
        file_name
    union all
    -- 複数ファイルの時
    SELECT jf.name AS file_sub_kind,
        p.file_name,
        ARRAY_AGG(
            t.col
            ORDER BY t.ordinality
        ) AS content_array
    FROM multiple_file_parsed p
        LEFT JOIN joined_files jf ON p.file_name = jf.path,
        LATERAL ntss.parse_csv_row(p.content) WITH ORDINALITY AS t(col, ordinality)
    WHERE p.content IS NOT null
        and (
            select cnt
            from file_count
        ) > 1
    GROUP BY p.ctl_no,
        p.file_name,
        jf.name,
        p.rn
),
content_cte AS (
    SELECT file_sub_kind,
        JSON_AGG(content_array)::TEXT AS content_json
    FROM file_content_rows
    WHERE file_sub_kind = @fileSubKind
    GROUP BY file_sub_kind
)
SELECT *
FROM content_cte
UNION ALL
-- content_cteがなかったときはデフォルト値を返す
SELECT NULL AS file_sub_kind,
    ''[]'' AS content_json
WHERE NOT EXISTS (
        SELECT 1
        FROM content_cte
    );
-- SQL:-1103016 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 新規処理dump取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
