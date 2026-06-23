delete from sys_data_set where sql_cd in (-1202022,-1202023);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202022, '-- 【SQL_CD=-1202022】
WITH do_ord_main AS (
    (
    SELECT
        ord_i.ord_no,
        ord_i.del_date AS up_date,
        ord_i.facility_cd,
        ord_i.pat_id,
        ord_i.rst_cond_info,
        ord_i.rst_medi_info,
        ord_i.rst_equip_info,
        ord_i.rst_treatment_info,
        ord_i.addition_info,
        ord_i.rst_treatment_cd,
        ord_i.rst_start_date,
        ord_i.rst_end_date,
        ord_i.rst_in_out_class
    FROM ord_main_restore AS ord_i
    LEFT JOIN sys_coop_journal AS journal
      ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND journal.reg_date >= ord_i.del_date
    ORDER BY ord_i.del_date DESC
    LIMIT 1
    )
    UNION
    (
    SELECT
        ord_i.ord_no,
        ord_i.rst_edition_date AS up_date,
        ord_i.facility_cd,
        ord_i.pat_id,
        ord_i.rst_cond_info,
        ord_i.rst_medi_info,
        ord_i.rst_equip_info,
        ord_i.rst_treatment_info,
        ord_i.addition_info,
        ord_i.rst_treatment_cd,
        ord_i.rst_start_date,
        ord_i.rst_end_date,
        ord_i.rst_in_out_class
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
    )
    ORDER BY
    up_date DESC NULLS LAST
    LIMIT
      1
),
patient_info AS (
    SELECT
      auth_info ->> ''reg_date'' AS reg_date,
      auth_info ->> ''is_main'' AS is_main,
      auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
      auth_info ->> ''is_dial_diff'' AS is_dial_diff
    FROM
      json_array_elements(@patPersonalInfo::json) auth_info
),
-- =========================================
-- 2. オーダー × 患者情報結合
-- =========================================
do_ord_pat AS (
    -- 患者情報結合
    SELECT
        o.ord_no,
        o.facility_cd,
        o.pat_id,
        o.rst_start_date,
        o.rst_end_date,
        o.rst_in_out_class,
        p.addition_info AS pat_addition_info,  -- 患者側加算情報
        o.addition_info AS ord_addition_info,  -- オーダー側加算情報
        NULLIF(p.medical_care_info->>''dialysis_start_date'', '''')::int AS introduction_date -- 導入期開始日
    FROM do_ord_main o
    JOIN pat_main p
      ON p.pat_id = o.pat_id
     AND p.facility_cd = o.facility_cd
     AND p.is_del = ''0''
),
-- =========================================
-- 3. 対象オーダー抽出（世代判定用）
-- =========================================
target_order AS (
    SELECT
        ord_no,
        facility_cd,
        rst_start_date
    FROM do_ord_main
),
-- =========================================
-- 4. 算定世代取得（rst_start_date 基準）
-- =========================================
target_version AS (
    SELECT
        t.ord_no,
        t.facility_cd,
        (
            SELECT MAX(c.master_version)
            FROM mst_recept c
            WHERE c.facility_cd = t.facility_cd
              AND c.master_version <= to_char(t.rst_start_date, ''YYYYMM'')::numeric
        ) AS master_version
    FROM target_order t
),
-- =========================================
-- 5. 治療方法区分判定（STANDARD / SPECIAL）
-- =========================================
treatment_method AS (
    SELECT
        d.ord_no,
        d.facility_cd,
        m.in_hospital_cd_a1 AS  in_hospital_cd,
        CASE
            WHEN m.in_hospital_cd_a1 IN (''0'',''1'',''2'',''3'',''6'',''7'',''8'')
                THEN ''STANDARD''
            ELSE ''SPECIAL''
        END AS treatment_kind
    FROM do_ord_main d
    LEFT JOIN mst_treatment m
      ON m.treatment_cd = d.rst_treatment_cd
     AND m.facility_cd  = d.facility_cd
),
-- =========================================
-- 5. 導入期加算フラグ
-- =========================================
induction_addition_flag AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        CASE WHEN EXISTS (
            SELECT 1
            FROM mst_addition a
            JOIN LATERAL jsonb_array_elements(o.addition_info) AS ai(info) ON true
            WHERE a.addition_cd = (ai.info ->> ''cd'')::bigint
              AND a.addition_class = ''9'' 
        ) THEN TRUE ELSE FALSE END AS has_induction
    FROM do_ord_main o
    LEFT JOIN treatment_method tm
      ON tm.ord_no = o.ord_no
     AND tm.facility_cd = o.facility_cd
    WHERE tm.in_hospital_cd IN (''0'',''7'')  -- HD / OHDF のみ対象
),
-- =========================================
-- 6. 透析実施時間計算
-- =========================================
dialysis_calc AS (
    SELECT
        dp.ord_no,
        dp.facility_cd,
        dp.pat_id,
        dp.rst_start_date,
        dp.rst_end_date,
        dp.rst_in_out_class,
        dp.introduction_date,
        EXTRACT(EPOCH FROM dp.rst_end_date - dp.rst_start_date)/60 AS enforcement_time_minutes
    FROM do_ord_pat dp
),
-- =========================================
-- 1. 抗凝固剤（DRUG_KIND = 2）
-- =========================================
coag_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        2 AS class_type,
        NULLIF(trim(rst_cond_info -> ''25'' ->> ''value''), '''')::numeric AS code,
        m.medicine_name AS name,
        TRUNC(
            COALESCE(NULLIF(trim(rst_cond_info -> ''26'' ->> ''value''), '''')::numeric, 0) +
            COALESCE(NULLIF(trim(rst_cond_info -> ''28'' ->> ''value''), '''')::numeric, 0),
        2) AS quantity,
        m.in_hospital_cd_2 AS unit,
        m.in_hospital_cd_1 AS recept_cd
    FROM do_ord_main o
    LEFT JOIN mst_medicine m
      ON m.medicine_cd = NULLIF(trim(rst_cond_info -> ''25'' ->> ''value''), '''')::numeric
     AND m.facility_cd = o.facility_cd
    WHERE rst_cond_info -> ''25'' ->> ''value'' IS NOT NULL
),
-- =========================================
-- 2. ダイアライザ（DRUG_KIND = 1）
-- =========================================
dialyzer_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        1 AS class_type,
        NULLIF(trim(rst_cond_info -> ''5'' ->> ''value''), '''')::numeric AS code,
        d.model_number AS name,
        1::numeric AS quantity,
        d.in_hospital_cd_2 AS unit,
        d.in_hospital_cd_1 AS recept_cd
    FROM do_ord_main o
    LEFT JOIN mst_dialyzer d
      ON d.dialyzer_cd = NULLIF(trim(rst_cond_info -> ''5'' ->> ''value''), '''')::numeric
     AND d.facility_cd = o.facility_cd
    WHERE rst_cond_info -> ''5'' ->> ''value'' IS NOT NULL
),

-- =========================================
-- 3. 透析液（DRUG_KIND = 4）
-- =========================================
dialysate_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        4 AS class_type,
        NULLIF(trim(rst_cond_info -> ''15'' ->> ''value''), '''')::numeric AS code,
        m.medicine_name AS name,
        TRUNC(
            COALESCE(NULLIF(trim(rst_cond_info -> ''17'' ->> ''value''), '''')::numeric, 0),
        2) AS quantity,
        m.in_hospital_cd_2 AS unit,
        m.in_hospital_cd_1 AS recept_cd
    FROM do_ord_main o
    LEFT JOIN mst_medicine m
      ON m.medicine_cd = NULLIF(trim(rst_cond_info -> ''15'' ->> ''value''), '''')::numeric
     AND m.facility_cd = o.facility_cd
    WHERE rst_cond_info -> ''15'' ->> ''value'' IS NOT NULL
),

-- =========================================
-- 4. 消耗品（DRUG_KIND = 5）
-- =========================================
material_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        5 AS class_type,
        NULLIF(equip.elem ->> ''cd'', '''')::numeric AS code,
        me.equipment_name AS name,
        COALESCE(NULLIF(equip.elem ->> ''amount'', ''''), ''1'')::numeric AS quantity,
        me.in_hospital_cd_2 AS unit,
        me.in_hospital_cd_1 AS recept_cd
    FROM do_ord_main o
    CROSS JOIN LATERAL jsonb_array_elements(o.rst_equip_info::jsonb) AS equip(elem)
    LEFT JOIN mst_equipment me
      ON me.equipment_cd = NULLIF(equip.elem ->> ''cd'', '''')::numeric
     AND me.facility_cd = o.facility_cd
),
-- =========================================
-- 5. 処置薬剤（DRUG_KIND = 6）
-- =========================================
drug_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        6 AS class_type,
        NULLIF(trim(t.medi ->> ''cd''), '''')::numeric AS code,
        NULLIF(trim(t.medi ->> ''amount''), '''')::numeric AS quantity,
        m.medicine_name AS name,
        m.in_hospital_cd_2 AS unit,
        m.in_hospital_cd_1 AS recept_cd
    FROM do_ord_main o
    CROSS JOIN jsonb_array_elements(o.rst_medi_info::jsonb) AS t(medi)
    LEFT JOIN mst_medicine m
      ON m.medicine_cd = NULLIF(trim(t.medi ->> ''cd''), '''')::numeric
     AND m.facility_cd = o.facility_cd
    WHERE t.medi ->> ''effect_flg'' = ''1''
),
-- =========================================
-- 6. 酸素
-- =========================================
oxygen_info_base AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        0 AS class_type,
        NULL::int AS code,
        ''酸素'' AS name,
        NULLIF(elem ->> ''oxygen_amount'', '''')::numeric AS quantity,
        NULL AS unit,
        NULL AS recept_cd
    FROM do_ord_main o
    CROSS JOIN jsonb_array_elements(o.rst_treatment_info) AS elem
    WHERE elem ->> ''oxygen_amount'' IS NOT NULL
),
-- =========================================
-- 13. 算定マスタ（適用世代に絞り込み済み）
-- =========================================
mst_calc_setting_current AS (
    SELECT 
        vc.facility_cd,
        vc.calc_cd,
        vc.calc_name,
        vc.recept_cd
    FROM mst_calc_setting vc
    JOIN target_version tv
      ON vc.facility_cd = tv.facility_cd
     AND vc.master_version = tv.master_version
    WHERE is_del = ''0''
      AND recept_cd IS NOT NULL
      AND recept_cd <> ''0''
),
-- =========================================
-- 14. レセマスタ（適用世代に絞り込み済み）
-- =========================================
mst_recept_current AS (
    SELECT 
        r.facility_cd,
        r.recept_cd,
        r.section_type,
        r.master_category,
        r.formal_name,
        r.input_unit,
        r.expiry_date
    FROM mst_recept r
    JOIN target_version tv
      ON r.facility_cd = tv.facility_cd
     AND r.master_version = tv.master_version
),
-- =========================================
-- 15. 患者透析困難症（json 展開）
-- =========================================
dialysis_difficulty AS (
    SELECT
        md.facility_cd,
        md.dialysis_difficulty_name,
        md.dialysis_difficulty_cd,
        md.in_hospital_cd_2 AS pat_state_sub,
        md.in_hospital_cd_1 AS recept_cd
    FROM mst_dialysis_difficulty md
    JOIN target_order t
      ON t.facility_cd = md.facility_cd
    WHERE md.is_del = ''0''
),
-- =========================================
-- 15. 患者透析困難症（do_ord_main を JOIN して情報を補完）
-- =========================================
pat_difficulty AS (
    SELECT
        d.pat_id,           -- do_ord_main から取得
        d.facility_cd,      -- do_ord_main から取得
        p.dial_diff_cd::int AS dialysis_difficulty_cd,
        p.is_main,
        p.is_dial_diff,
        p.reg_date
    FROM patient_info p
    CROSS JOIN do_ord_main d
    WHERE p.is_dial_diff = ''1''
),
-- =========================================
-- 16. 患者状態透析難易度（医事コード付与）
-- =========================================
pat_conditions_ex AS (
    SELECT *
    FROM (
        SELECT
            pd.pat_id,
            pd.facility_cd,
            dd.dialysis_difficulty_cd,
            dd.dialysis_difficulty_name,
            dd.pat_state_sub,     -- A〜K
            dd.recept_cd,
            pd.is_main,
            pd.reg_date,
            ROW_NUMBER() OVER (
                PARTITION BY pd.pat_id, pd.facility_cd
                ORDER BY pd.reg_date DESC
            ) AS rn
        FROM pat_difficulty pd
        JOIN dialysis_difficulty dd
          ON dd.dialysis_difficulty_cd = pd.dialysis_difficulty_cd
         AND dd.facility_cd = pd.facility_cd
         AND dd.pat_state_sub IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'')
    ) t
    WHERE rn = 1  -- ord ごとに最新行だけ
),
-- =========================================
-- 16. 患者透析困難症（医事コード付与）
-- =========================================
pat_difficulty_ex AS (
    SELECT *
    FROM (
        SELECT
            pd.pat_id,
            pd.facility_cd,
            dd.dialysis_difficulty_cd,
            dd.dialysis_difficulty_name,
            dd.pat_state_sub,     -- A〜K以外
            dd.recept_cd,
            pd.is_main,
            pd.reg_date,
            ROW_NUMBER() OVER (
                PARTITION BY pd.pat_id, pd.facility_cd
                ORDER BY pd.reg_date DESC
            ) AS rn
        FROM pat_difficulty pd
        JOIN dialysis_difficulty dd
          ON dd.dialysis_difficulty_cd = pd.dialysis_difficulty_cd
         AND dd.facility_cd = pd.facility_cd
         AND (
                dd.pat_state_sub NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'')
             OR dd.pat_state_sub IS NULL
            )
    ) t
    WHERE rn = 1  -- ord ごとに最新行だけ
),
-- =========================================
-- 17. オーダー加算情報（json 展開）
-- =========================================
ord_addition AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        o.pat_id,
        (elem->>''cd'')::bigint AS addition_cd,
        elem->>''is_enable'' AS is_enable,
        elem->>''start_date'' AS start_date,
        elem->>''last_date'' AS last_date
    FROM do_ord_main o
    CROSS JOIN LATERAL
         jsonb_array_elements(o.addition_info) elem
    WHERE elem->>''is_enable'' = ''1''
),
-- =========================================
-- 18. 加算マスタ結合
-- =========================================
addition_ex AS (
    SELECT
        oa.ord_no,
        oa.facility_cd,
        oa.pat_id,
        am.addition_cd,
        am.addition_class,
        am.in_hospital_cd_1 AS recept_cd,
        am.in_hospital_cd_2 AS comment_cd,
        am.addition_name
    FROM ord_addition oa
    JOIN mst_addition am
      ON am.addition_cd = oa.addition_cd
     AND am.facility_cd = oa.facility_cd
     AND am.is_del = ''0''
),
-- =========================================
-- 15回以上算定フラグ
-- =========================================
dialysis_15_times_flag AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        o.pat_id,
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM ord_main o2
                WHERE o2.facility_cd = o.facility_cd
                  AND o2.pat_id = o.pat_id
                  AND o2.rst_start_date::date >= date_trunc(''month'', o.rst_start_date)
                  AND o2.rst_start_date::date <= o.rst_start_date::date
                  AND o2.is_del = ''0''
            ) >= 15
            THEN TRUE
            ELSE FALSE
        END AS is_15_times
    FROM do_ord_main o
),
-- =========================================
-- 19. 算定ルート決定（世代 × 治療区分）
-- =========================================
dialyze_route AS (
    SELECT DISTINCT
        v.ord_no,
        v.facility_cd,
        v.master_version,
        t.treatment_kind,
        CASE
            WHEN v.master_version >= 202204
             AND t.treatment_kind = ''STANDARD''
                THEN ''CALC_202204_STANDARD''
            WHEN v.master_version >= 202204
             AND t.treatment_kind = ''SPECIAL''
                THEN ''CALC_202204_SPECIAL''
            ELSE ''UNSUPPORTED''
        END AS calc_route
    FROM target_version v
    JOIN treatment_method t
      ON t.ord_no      = v.ord_no
     AND t.facility_cd = v.facility_cd
),
-- =========================================
-- 患者フラグ整理（導入期・15回・透析難易度）
-- =========================================
patient_flag AS (
    SELECT
        dc.ord_no,
        dc.facility_cd,
        dc.pat_id,
        COALESCE(imf.has_induction, FALSE) AS has_induction,
        COALESCE(d15.is_15_times, FALSE) AS is_15_times,
        EXISTS (
            SELECT 1
            FROM pat_conditions_ex pde
            WHERE pde.facility_cd = dc.facility_cd
              AND pde.pat_id = dc.pat_id
              AND (
                   pde.pat_state_sub IN (''A'',''B'',''C'',''D'')
                OR (dc.rst_in_out_class = ''1'' AND pde.pat_state_sub IN (''E'',''F'',''G'',''H'',''I'',''J'',''K''))
              )
        ) AS has_difficulty
    FROM dialysis_calc dc
    LEFT JOIN induction_addition_flag imf
      ON imf.ord_no = dc.ord_no
    LEFT JOIN dialysis_15_times_flag d15
      ON d15.ord_no = dc.ord_no
),
-- =========================================
-- 20. 人工腎臓本体（BASE / COMMENT 行生成）
--   ※ CALC_202204_STANDARD 専用（HD / OHDF 対応）
-- =========================================
calc_202204_standard_base AS (

    -- ---------- BASE 行（OTHER） ----------
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''CALC_202204_STANDARD'' AS calc_route,
        ''OTHER'' AS row_kind,
        ''BASE'' AS unit_kind,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        nyu.recept_cd,
        NULL::text AS addition_class,
        NULL::text AS addition_name
    FROM dialysis_calc dc
    JOIN treatment_method tm
      ON tm.ord_no = dc.ord_no
     AND tm.facility_cd = dc.facility_cd
    JOIN mst_calc_setting_current nyu
      ON nyu.facility_cd = dc.facility_cd
     AND nyu.calc_cd = ''Nyu''
    JOIN patient_flag pf
      ON pf.ord_no = dc.ord_no
     AND pf.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = dc.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp''
    WHERE pf.is_15_times = FALSE
      AND (
            -- ① 治療法で強制 OTHER
            tm.in_hospital_cd IN (''1'',''2'',''3'',''6'',''8'')   -- ECUM/HDF/HF/AFBF/OHF
            OR
            -- ② HD / OHDF で、導入期あり OR 難易度あり
            (
                tm.in_hospital_cd IN (''0'',''7'')          -- HD / OHDF
                AND (
                       pf.has_induction = TRUE
                       OR pf.has_difficulty = TRUE
                    )
            )
          )

    UNION ALL

    -- ---------- BASE 行（DIALY） ----------
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''CALC_202204_STANDARD'' AS calc_route,
        ''DIALY'' AS row_kind,
        ''BASE'' AS unit_kind,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        vc.recept_cd,
        NULL::text AS addition_class,
        NULL::text AS addition_name
    FROM dialysis_calc dc
    JOIN treatment_method tm
      ON tm.ord_no = dc.ord_no
     AND tm.facility_cd = dc.facility_cd
    JOIN mst_calc_setting_current vc
      ON vc.facility_cd = dc.facility_cd
     AND (
          (dc.enforcement_time_minutes < 240  AND vc.calc_cd LIKE ''Gai4miman_%'')
       OR (dc.enforcement_time_minutes >= 240 AND dc.enforcement_time_minutes < 300 AND vc.calc_cd LIKE ''Gai4to5_%'')
       OR (dc.enforcement_time_minutes >= 300 AND vc.calc_cd LIKE ''Gai5ijou_%'')
     )
    JOIN patient_flag pf
      ON pf.ord_no = dc.ord_no
     AND pf.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = dc.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp''
    WHERE pf.is_15_times = FALSE
      AND tm.in_hospital_cd IN (''0'',''7'')      -- HD / OHDF
      AND pf.has_induction = FALSE
      AND pf.has_difficulty = FALSE
),
-- =========================================
-- 20. 特殊血液浄化（SPECIAL）算定
-- =========================================
calc_202204_special_base AS (
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''CALC_202204_SPECIAL'' AS calc_route,
        ''SPECIAL'' AS row_kind,
        ''BASE'' AS unit_kind,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        sp.recept_cd,
        NULL::text AS addition_class,
        sp.calc_name AS addition_name
    FROM dialysis_calc dc
    JOIN treatment_method tm
      ON tm.ord_no = dc.ord_no
     AND tm.facility_cd = dc.facility_cd
    -- 世代絞り込み済みのマスタを参照
    JOIN mst_calc_setting_current sp
      ON sp.facility_cd = dc.facility_cd
     AND sp.calc_cd = (
            CASE tm.in_hospital_cd
                WHEN ''A'' THEN ''SpCont''               -- 持続緩徐式血液濾過(CHDF)
                WHEN ''B'' THEN ''SpPlasma''             -- 血漿交換療法(PE/DFPP)
                WHEN ''C'' THEN ''SpSectionMalignant''   -- 局所灌流（悪性腫瘍）
                WHEN ''D'' THEN ''SpSectionPeriosteum''  -- 局所灌流（骨膜・骨髄炎）
                WHEN ''E'' THEN ''SpAdsorption''         -- 吸着式血液浄化法(PA)
                WHEN ''F'' THEN ''SpHemocyte''           -- 血球成分除去療法(LCAP/GCAP)
                WHEN ''G'' THEN ''SpPeritoneum''         -- 連続携行式腹膜灌流(CAPD)
                WHEN ''H'' THEN ''SpPeritoneumOther''    -- その他の腹膜灌流
                WHEN ''I'' THEN ''SpOther1''
                WHEN ''J'' THEN ''SpOther2''
                WHEN ''K'' THEN ''SpOther3''
                WHEN ''L'' THEN ''SpOther4''
                WHEN ''M'' THEN ''SpOther5''
                WHEN ''N'' THEN ''SpOther6''
                WHEN ''O'' THEN ''SpOther7''
                WHEN ''P'' THEN ''SpOther8''
                WHEN ''Q'' THEN ''SpOther9''
                WHEN ''R'' THEN ''SpOther10''
                ELSE ''Unknown''
            END
         )
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = dc.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp''
    WHERE tm.treatment_kind = ''SPECIAL''
      -- マスタに recept_cd が設定されているものだけを算定対象とする
    AND sp.recept_cd IS NOT NULL 
),
-- =========================================
-- 21-補助. OHDF水質未確保などの判定用
-- =========================================
check_ohdf_status AS (
    SELECT 
        o.ord_no,
        o.facility_cd
    FROM do_ord_main o
    JOIN LATERAL jsonb_array_elements(o.addition_info) AS ai(info) ON true
    JOIN mst_addition a 
      ON a.addition_cd = (ai.info ->> ''cd'')::bigint
     AND a.addition_class = ''2''
    JOIN mst_treatment m
      ON m.treatment_cd = o.rst_treatment_cd
     AND m.facility_cd  = o.facility_cd
    WHERE m.in_hospital_cd_a1 = ''7'' -- OHDF判定
),
-- =========================================
-- 21. 薬剤・材料の出来高判定フラグ
-- =========================================
drug_calc_flag AS (
    SELECT
        o.ord_no,
        o.facility_cd,
        CASE
            -- 15回以上算定
            WHEN EXISTS (
                SELECT 1 FROM dialysis_15_times_flag d15
                WHERE d15.ord_no = o.ord_no AND d15.is_15_times = TRUE
            ) THEN true

            -- OHDF 水質未確保 (先に定義したCTEを参照)
            WHEN EXISTS (
                SELECT 1 FROM check_ohdf_status c
                WHERE c.ord_no = o.ord_no AND c.facility_cd = o.facility_cd
            ) THEN true

            -- 人工腎臓が「通常算定でない」
            WHEN EXISTS (
                SELECT 1 FROM calc_202204_standard_base b
                WHERE b.ord_no = o.ord_no
                  AND b.facility_cd = o.facility_cd
                  AND b.unit_kind = ''BASE''
                  AND b.row_kind = ''OTHER''
            ) THEN true

            ELSE false
        END AS is_drug_calc
    FROM do_ord_main o
),
-- =========================================
-- 22. 抗凝固剤（出来高のみ算定、包括判定無視）
-- =========================================
coag_info AS (
    SELECT
        d.*,
        f.is_drug_calc AS is_drug_calc
    FROM coag_info_base d
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = d.ord_no
     AND f.facility_cd = d.facility_cd
    WHERE d.class_type = 2
      AND d.code IS NOT NULL
),
-- =========================================
-- 23. ダイアライザ（常に算定）
-- =========================================
dialyzer_info AS (
    SELECT
        d.*,
        f.is_drug_calc AS is_drug_calc
    FROM dialyzer_info_base d
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = d.ord_no
     AND f.facility_cd = d.facility_cd
    WHERE d.class_type = 1
      AND d.code IS NOT NULL
),
-- =========================================
-- 24. 透析液（抗凝固剤と同じ扱い、包括判定無視）
-- =========================================
dialysate_info AS (
    SELECT
        b.*,
        f.is_drug_calc AS is_drug_calc
    FROM dialysate_info_base b
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = b.ord_no
     AND f.facility_cd = b.facility_cd
    WHERE b.class_type = 4
      AND b.code IS NOT NULL
),
-- =========================================
-- 25. 医療材料（全明細表示、包括判定保持）
-- =========================================
material_info AS (
    SELECT
        b.*,
        f.is_drug_calc AS is_drug_calc
    FROM material_info_base b
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = b.ord_no
     AND f.facility_cd = b.facility_cd
    WHERE b.class_type = 5
      AND b.code IS NOT NULL
),
-- =========================================
-- 26. 投与薬剤（全明細表示、包括判定保持）
-- =========================================
treatment_drug_info AS (
    SELECT
        b.*,
        f.is_drug_calc AS is_drug_calc
    FROM drug_info_base b
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = b.ord_no
     AND f.facility_cd = b.facility_cd
    WHERE b.class_type = 6
      AND b.code IS NOT NULL
),
-- =========================================
-- 27. ダイアライザ（常に算定）
-- =========================================
calc_unit_dialyzer AS (
    SELECT
        d.ord_no,
        d.facility_cd,
        ''DATA'' AS row_kind,
        ''DIALYZER'' AS unit_kind,
        1 AS unit_no,
        d.code AS code,
        d.name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        d.recept_cd AS recept_cd,
        r.section_type AS section_type,
        r.master_category AS master_category,
        r.formal_name AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,  
        d.quantity AS quantity,
        d.unit AS unit,
        ''1'' AS medical_type,
        ''ダイアライザ'' AS name_type,
        NULL::text AS comment_text,
        TRUE AS is_final_calc
    FROM dialyzer_info d
    LEFT JOIN mst_recept_current r
      ON r.recept_cd      = d.recept_cd
     AND r.facility_cd    = d.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = d.facility_cd
     AND zom.map_calc_cd = ''tsk_yk_kbn1_grp''
),
-- =========================================
-- 27. 抗凝固剤（出来高条件のみ）
-- =========================================
calc_unit_coag AS (
    SELECT
        c.ord_no,
        c.facility_cd,
        ''DATA'' AS row_kind,
        ''COAG'' AS unit_kind,
        1 AS unit_no,
        c.code AS code,
        c.name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        c.recept_cd AS recept_cd,
        r.section_type AS section_type,
        r.master_category AS master_category,        
        r.formal_name AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,                  
        c.quantity AS quantity,
        c.unit AS unit,
        ''2'' AS medical_type,
        ''抗凝固剤'' AS name_type,
        NULL::text AS comment_text,
        COALESCE(f.is_drug_calc,false) AS is_final_calc
    FROM coag_info c
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = c.ord_no
     AND f.facility_cd = c.facility_cd
    LEFT JOIN mst_recept_current r
      ON r.recept_cd      = c.recept_cd
     AND r.facility_cd    = c.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = c.facility_cd
     AND zom.map_calc_cd = ''tsk_yk_kbn2_grp''
),

-- =========================================
-- 27. 透析液（出来高条件のみ）
-- =========================================
calc_unit_dialysate AS (
    SELECT
        d.ord_no,
        d.facility_cd,
        ''DATA'' AS row_kind,
        ''DIALYSATE'' AS unit_kind,
        1 AS unit_no,
        d.code AS code,
        d.name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        d.recept_cd AS recept_cd,
        r.section_type AS section_type,
        r.master_category AS master_category,
        r.formal_name AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,  
        d.quantity,
        d.unit,
        ''4'' AS medical_type,
        ''透析液'' AS name_type,
        NULL::text AS comment_text,
        COALESCE(f.is_drug_calc,false) AS is_final_calc
    FROM dialysate_info d
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = d.ord_no
     AND f.facility_cd = d.facility_cd
    LEFT JOIN mst_recept_current r
      ON r.recept_cd      = d.recept_cd
     AND r.facility_cd    = d.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = d.facility_cd
     AND zom.map_calc_cd = ''tsk_yk_kbn4_grp''
),
-- =========================================
-- 27. 投与薬剤（出来高・包括反映）
-- =========================================
calc_unit_drug AS (
    SELECT
        g.ord_no,
        g.facility_cd,
        ''DATA'' AS row_kind,
        ''DRUG'' AS unit_kind,
        1 AS unit_no,
        g.code AS code,
        g.name AS name,
        NULL::int AS group_cd,
        g.recept_cd AS recept_cd,
        r.section_type AS section_type,
        r.master_category AS master_category,
        r.formal_name AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,
        g.quantity,
        g.unit,
        ''6'' AS medical_type,
        ''投与薬剤'' AS name_type,
        NULL::text AS comment_text,

        -- 算定有無
        CASE
            -- 透析包括（Hk_Yakuzai_%）に属する薬剤か
            WHEN EXISTS (
                SELECT 1
                FROM mst_calc_setting_current cs
                WHERE cs.recept_cd::text = g.recept_cd::text
                  AND cs.calc_cd LIKE ''Hk_Yakuzai_%''
                  AND cs.facility_cd = g.facility_cd
            ) THEN
                -- 包括薬剤なら、例外（出来高フラグ）のときだけ算定
                COALESCE(f.is_drug_calc, FALSE)
            ELSE
                -- 非包括薬剤は常に算定
                TRUE
        END AS is_final_calc

    FROM treatment_drug_info g
    LEFT JOIN drug_calc_flag f
        ON f.ord_no = g.ord_no
       AND f.facility_cd = g.facility_cd
    LEFT JOIN mst_recept_current r
        ON r.recept_cd = g.recept_cd
       AND r.facility_cd = g.facility_cd
),
-- =========================================
-- 27. 医療材料（出来高・包括反映）
-- =========================================
calc_unit_material AS (
    SELECT
        m.ord_no,
        m.facility_cd,
        ''DATA'' AS row_kind,
        ''MATERIAL'' AS unit_kind,
        1 AS unit_no,
        m.code AS code,
        m.name AS name,
        NULL::int AS group_cd,
        m.recept_cd AS recept_cd,
        r.section_type AS section_type,
        r.master_category AS master_category,
        r.formal_name AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,  
        m.quantity AS quantity,
        m.unit AS unit,
        ''5'' AS medical_type,
        ''医療材料'' AS name_type,
        NULL::text AS comment_text,
        CASE
            -- 透析包括（Hk_Yakuzai_%）に属する材料か
            WHEN EXISTS (
                SELECT 1
                FROM mst_calc_setting_current cs
                WHERE cs.recept_cd::text = m.recept_cd::text
                  AND cs.calc_cd LIKE ''Hk_Yakuzai_%''
                  AND cs.facility_cd   = m.facility_cd
            )
            THEN
                -- 包括材料なら、例外（出来高フラグ）のときだけ算定
                COALESCE(f.is_drug_calc,false)
            ELSE
                -- 非包括材料は常に算定
                true
        END AS is_final_calc
    FROM material_info m
    LEFT JOIN drug_calc_flag f
      ON f.ord_no = m.ord_no
     AND f.facility_cd = m.facility_cd
    LEFT JOIN mst_recept_current r
      ON r.recept_cd      = m.recept_cd
     AND r.facility_cd    = m.facility_cd
),
-- =========================================
-- 27. 酸素（常に算定）
-- =========================================
oxygen_info AS (
    SELECT
        o2.*,
        true AS is_drug_calc,
        false AS is_package_drug
    FROM oxygen_info_base o2
),
calc_unit_oxy AS (
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''BASE'' AS row_kind,
        ''OXYGEN'' AS unit_kind,
        1 AS unit_no,
        o.code AS code,
        o.name AS name,       
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        cs.recept_cd AS recept_cd, 
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,    
        NULL::numeric AS quantity,
        NULL AS unit,  
        ''9''::text AS medical_type,
        ''酸素'' AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean  AS is_final_calc
    FROM oxygen_info o
    JOIN dialysis_calc dc
      ON dc.ord_no = o.ord_no
     AND dc.facility_cd = o.facility_cd
    JOIN mst_calc_setting_current cs
      ON cs.calc_cd = ''Sank''
     AND cs.facility_cd = o.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = o.facility_cd
     AND zom.map_calc_cd = ''tsk_sanso_grp''
     
    UNION ALL
    
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''DATA'' AS row_kind,
        ''OXYGEN'' AS unit_kind,
        1 AS unit_no,
        o.code AS code,
        o.name AS name,       
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        cs.recept_cd AS recept_cd, 
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,    
        o.quantity AS quantity,
        NULL AS unit,  
        ''9''::text AS medical_type,
        ''酸素量'' AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean  AS is_final_calc
    FROM oxygen_info o
    JOIN dialysis_calc dc
      ON dc.ord_no = o.ord_no
     AND dc.facility_cd = o.facility_cd
    JOIN mst_calc_setting_current cs
      ON cs.calc_cd = ''Sans''
     AND cs.facility_cd = o.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = o.facility_cd
     AND zom.map_calc_cd = ''tsk_sanso_grp'' 
),
-- =========================================
-- 31. その他の加算行生成
-- =========================================
calc_unit_etc AS (
    SELECT
        ae.ord_no,
        ae.facility_cd,
        ''ADDITION'' AS row_kind,
        ''OTHER'' AS unit_kind,
         1 AS unit_no,
        ae.addition_cd AS code,
        ae.addition_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        ae.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        ae.addition_class AS addition_type,
        ae.addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        ae.addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM addition_ex ae
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = ae.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
    WHERE ae.addition_class NOT IN (''2'', ''9'', ''13'')
),
-- =========================================
-- 10. 回数15回以上を除外
-- =========================================
calc_target AS (
    SELECT
        pf.ord_no,
        pf.facility_cd,
        pf.pat_id,
        pf.has_induction,
        pf.has_difficulty,
        pf.is_15_times
    FROM patient_flag pf
    WHERE pf.is_15_times = FALSE
),
-- =========================================
-- 31. 慢性医事透析外来医学管理料
-- =========================================
calc_unit_mgmt AS (
    -- 慢性医事透析外来医学管理料
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''BASE'' AS row_kind,
        ''MANAGEMENT'' AS unit_kind,
         1 AS unit_no,
        a.addition_cd AS code,
        a.addition_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        a.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        addition_class AS addition_type,
        addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''13''
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_mansei_grp'' 
    
    UNION ALL
    
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''ADDITION'' AS row_kind,
        ''MANAGEMENT'' AS unit_kind,
         1 AS unit_no,
        NULL::int AS code,
        ''人工腎臓（腎代替療法実績加算）'' AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        a.comment_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        addition_class AS addition_type,
        addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        ''人工腎臓（腎代替療法実績加算）'' AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''13''
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_mansei_grp'' 

),
-- =========================================
-- 31. 患者状態透析難易度
-- =========================================
calc_unit_comment_diff AS (
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''COMMENT'' AS row_kind,
        ''BASE'' AS unit_kind,
        0 AS unit_no,
        pd.dialysis_difficulty_cd AS code,
        pd.dialysis_difficulty_name AS name,
        -- zom.pattern_cd AS group_cd ,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        pd.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        ''患者状態コメント''::text AS name_type,
        NULL::text AS comment_text,       
        TRUE::boolean AS is_final_calc
    FROM calc_target pf
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN pat_conditions_ex pd
      ON pd.pat_id = dc.pat_id
     AND pd.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
),
-- =========================================
-- 31. 障害者加算＆コメント
-- =========================================
calc_unit_dis AS (
    -- 障害者加算
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''ADDITION'' AS row_kind,
        ''DISABILITY'' AS unit_kind,
         1 AS unit_no,
        a.addition_cd AS code,
        a.addition_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        a.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        addition_class AS addition_type,
        addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''2''   -- 障害者加算
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
     
    UNION ALL
    
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''COMMENT'' AS row_kind,
        ''DISABILITY'' AS unit_kind,
         1 AS unit_no,
        pd.dialysis_difficulty_cd AS code,
        pd.dialysis_difficulty_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        pd.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        ''障害者加算コメント''::text AS name_type,
        NULL::text AS comment_text,
        TRUE
    FROM calc_target pf    
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''2''   -- 障害者加算
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    JOIN pat_difficulty_ex pd
      ON pd.pat_id = dc.pat_id
     AND pd.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
),
-- =========================================
-- 31. 導入期加算＆コメント
-- =========================================
calc_unit_intro AS (
    -- 導入期加算
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''ADDITION'' AS row_kind,
        ''INDUCTION'' AS unit_kind,
         1 AS unit_no,
        a.addition_cd AS code,
        a.addition_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        a.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        addition_class AS addition_type,
        addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''9''
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
     
    UNION ALL
    
    SELECT
        dc.ord_no,
        dc.facility_cd,
        ''COMMENT'' AS row_kind,
        ''INDUCTION'' AS unit_kind,
         1 AS unit_no,
        a.addition_cd AS code,
        a.addition_name AS name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        ''WP''::text AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        NULL::text AS addition_type,
        NULL::text AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        ''導入期加算コメント''::text AS name_type,
        CASE
            WHEN dc.introduction_date IS NOT NULL THEN
              translate(
                ''透析導入日：''
                || e.era_name
                || e.era_year
                || ''年''
                || e.month
                || ''月''
                || e.day
                || ''日'',
                ''0123456789'',
                ''０１２３４５６７８９'')
            ELSE
                NULL
        END AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf    
    JOIN dialysis_calc dc
      ON dc.ord_no = pf.ord_no
     AND dc.facility_cd = pf.facility_cd
    JOIN addition_ex a
      ON a.addition_class = ''9''   -- 障害者加算
     AND a.ord_no = dc.ord_no
     AND a.facility_cd = dc.facility_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = pf.facility_cd
     AND zom.map_calc_cd = ''tsk_jinkou_grp'' 
    LEFT JOIN LATERAL ntss.date_jp_era_translate(dc.introduction_date) e
      ON TRUE
),
-- =========================================
-- 特殊血液浄化（SPECIAL）世代統合ハブ
-- =========================================
calc_standard_base AS (
    -- =========================================
    -- 2022年4月改定分を整形
    -- =========================================
    SELECT
        sb.calc_route,
        sb.ord_no,
        sb.facility_cd,
        sb.row_kind,
        sb.unit_kind,
        1 AS unit_no,
        NULL::int AS code,
        NULL::text AS name,
        sb.group_cd AS group_cd,
        sb.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        sb.addition_class AS addition_type,
        sb.addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        sb.addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf  
    JOIN calc_202204_standard_base sb
      ON sb.ord_no = pf.ord_no
     AND sb.facility_cd = pf.facility_cd
    -- =========================================
    -- 2026年6月改定分 UNION
    -- =========================================
),
calc_standard_unit_dis AS (
    SELECT
        ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_dis cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_dis AS (
    SELECT
        ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_dis cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_intro AS (
    SELECT
        ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_intro cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_intro AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_intro cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_comment_diff AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_comment_diff cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_etc AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_etc cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_mgmt AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_mgmt cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_oxy AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_oxy cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_oxy AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_oxy cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_dialyzer AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_dialyzer cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_dialyzer AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_dialyzer cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_coag AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_coag cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_coag AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_coag cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_standard_unit_dialysate AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_STANDARD'' AS calc_route,
        cu.*
    FROM calc_unit_dialysate cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
calc_special_unit_dialysate AS (
    SELECT
       ''CALC_'' || tv.master_version || ''_SPECIAL'' AS calc_route,
        cu.*
    FROM calc_unit_dialysate cu
    JOIN target_version tv
      ON tv.ord_no = cu.ord_no
     AND tv.facility_cd = cu.facility_cd
),
-- =========================================
-- 特殊血液浄化（SPECIAL）世代統合ハブ
-- =========================================
calc_special_base AS (
    -- =========================================
    -- 2022年4月改定分を整形
    -- =========================================
    SELECT
        sb.calc_route,
        sb.ord_no,
        sb.facility_cd,
        sb.row_kind,
        sb.unit_kind,
        1 AS unit_no,
        NULL::int AS code,
        NULL::text AS name,
        sb.group_cd AS group_cd,
        sb.recept_cd AS recept_cd,
        NULL::int AS section_type,
        NULL::int AS master_category,
        NULL::text AS formal_name,
        sb.addition_class AS addition_type,
        sb.addition_name AS addition_name,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS medical_type,
        sb.addition_name AS name_type,
        NULL::text AS comment_text,
        TRUE::boolean AS is_final_calc
    FROM calc_target pf  
    JOIN calc_202204_special_base sb
      ON sb.ord_no = pf.ord_no
     AND sb.facility_cd = pf.facility_cd
    -- =========================================
    -- 2026年6月改定分 UNION
    -- =========================================
),
-- =========================================
-- 32. 算定行統合（BASE + COMMENT + ADDITION + DATA）
-- =========================================
all_calc AS (
    -- =========================================
    -- 1. SPECIAL ルート専用（特殊浄化セット）
    -- =========================================
    SELECT sp_base.* FROM calc_special_base sp_base
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_base.ord_no
      AND dr.calc_route = sp_base.calc_route

    UNION ALL

    SELECT sp_dis.* FROM calc_special_unit_dis sp_dis        -- 持続緩徐式血液濾過（障害者加算）＋コメント（セット）
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_dis.ord_no
      AND dr.calc_route = sp_dis.calc_route

    UNION ALL

    SELECT sp_intro.* FROM calc_special_unit_intro sp_intro    -- 連続携行式腹膜灌流（導入期）＋コメント（セット）
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_intro.ord_no
      AND dr.calc_route = sp_intro.calc_route

    -- =========================================
    -- 2. STANDARD ルート専用（維持透析セット）
    -- =========================================
    UNION ALL

    SELECT st_base.* FROM calc_standard_base st_base
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_base.ord_no
      AND dr.calc_route = st_base.calc_route
    
    UNION ALL 
    
    SELECT st_diff.* FROM calc_standard_unit_comment_diff st_diff  -- 難易度コメント単体（BASE用）
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_diff.ord_no
      AND dr.calc_route = st_diff.calc_route
    
    UNION ALL
    
    SELECT st_dis.* FROM calc_standard_unit_dis st_dis  -- 維持透析障害者加算＋コメント（セット）
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_dis.ord_no
      AND dr.calc_route = st_dis.calc_route

    UNION ALL
    
    SELECT st_intro.* FROM calc_standard_unit_intro st_intro -- 維持透析導入期加算＋コメント（セット）
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_intro.ord_no
      AND dr.calc_route = st_intro.calc_route

    UNION ALL
    
    SELECT st_etc.* FROM calc_standard_unit_etc st_etc     -- 維持透析その他加算
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_etc.ord_no
      AND dr.calc_route = st_etc.calc_route
    
    UNION ALL
    
    SELECT st_mgmt.* FROM calc_standard_unit_mgmt st_mgmt   -- 慢性医事透析外来医学管理料
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_mgmt.ord_no
      AND dr.calc_route = st_mgmt.calc_route
    
    -- =========================================
    -- 3. 共通セクション
    -- =========================================    
    UNION ALL
    
    SELECT st_oxy.* FROM calc_standard_unit_oxy st_oxy
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_oxy.ord_no
      AND dr.calc_route = st_oxy.calc_route
    
    UNION ALL
    
    SELECT sp_oxy.* FROM calc_special_unit_oxy sp_oxy
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_oxy.ord_no
      AND dr.calc_route = sp_oxy.calc_route
    
    UNION ALL

    SELECT st_dialyzer.* FROM calc_standard_unit_dialyzer st_dialyzer
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_dialyzer.ord_no
      AND dr.calc_route = st_dialyzer.calc_route

    UNION ALL

    SELECT sp_dialyzer.* FROM calc_special_unit_dialyzer sp_dialyzer
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_dialyzer.ord_no
      AND dr.calc_route = sp_dialyzer.calc_route
    
    UNION ALL
    
    SELECT st_coag.* FROM calc_standard_unit_coag st_coag
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_coag.ord_no
      AND dr.calc_route = st_coag.calc_route

    UNION ALL

    SELECT sp_coag.* FROM calc_special_unit_coag sp_coag
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_coag.ord_no
      AND dr.calc_route = sp_coag.calc_route
    
    UNION ALL
    
    SELECT st_dialysate.* FROM calc_standard_unit_dialysate st_dialysate
    INNER JOIN dialyze_route dr
       ON dr.ord_no = st_dialysate.ord_no
      AND dr.calc_route = st_dialysate.calc_route

    UNION ALL

    SELECT sp_dialysate.* FROM calc_special_unit_dialysate sp_dialysate
    INNER JOIN dialyze_route dr
       ON dr.ord_no = sp_dialysate.ord_no
      AND dr.calc_route = sp_dialysate.calc_route
),
-- =========================================
-- mapped_group_material（DRUG の group_cd 付与）
-- =========================================
mapped_group_material AS (
    SELECT
        mu.ord_no,
        mu.facility_cd,
        mu.row_kind,
        mu.unit_kind,
        mu.unit_no,
        mu.code,
        mu.name,
        -- CASE
        --     WHEN mu.recept_cd IS NULL THEN NULL
        --     ELSE zom.pattern_cd::int
        -- END AS group_cd,
        COALESCE(
        CASE
            WHEN mu.recept_cd IS NULL THEN NULL
            ELSE zom.pattern_cd::int
        END,
        99
        ) AS group_cd,
        mu.recept_cd,
        mu.section_type,
        mu.master_category,
        mu.formal_name,
        mu.addition_type,
        mu.addition_name,
        mu.quantity,
        mu.unit,
        mu.medical_type,
        mu.name_type,
        mu.comment_text,
        mu.is_final_calc
    FROM calc_unit_material mu
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd::text = mu.facility_cd::text
     AND zom.map_calc_cd = ''tsk_yk_kbn5_grp''
     AND zom.is_del = ''0''
),
-- =========================================
-- mapped_group_drug（DRUG の group_cd 付与）
-- =========================================
mapped_group_drug AS (
    SELECT
        cu.ord_no,
        cu.facility_cd,
        cu.row_kind,
        cu.unit_kind,
        cu.unit_no,
        cu.code,
        cu.name,
        -- zom.pattern_cd AS group_cd,
        COALESCE(zom.pattern_cd, 99) AS group_cd,
        cu.recept_cd,
        cu.section_type,
        cu.master_category,
        cu.formal_name,
        cu.addition_type,
        cu.addition_name,
        cu.quantity,
        cu.unit,
        cu.medical_type,
        cu.name_type,
        cu.comment_text,
        cu.is_final_calc
    FROM calc_unit_drug cu
    -- ① recept_cd → map_calc_cd（必ず分類を返す）
    LEFT JOIN LATERAL (
        SELECT
            CASE
                -- 包括対象薬剤
                WHEN EXISTS (
                    SELECT 1
                    FROM mst_calc_setting_current cs
                    WHERE cs.recept_cd::text = cu.recept_cd::text
                      AND cs.calc_cd LIKE ''Hk_Yakuzai_%''
                      AND cs.facility_cd = cu.facility_cd
                )
                THEN
                    CASE
                        -- 出来高なら包括グループ
                        WHEN cu.is_final_calc = TRUE
                            THEN ''tsk_hou_grp''
                        -- 包括算定なら診療区分グループ
                        ELSE
                            ''tsk_shink_grp'' || LPAD(cu.section_type::text, 2, ''0'')
                    END

                -- 非包括だが消炎鎮痛等処置
                WHEN EXISTS (
                    SELECT 1
                    FROM mst_calc_setting_current cs2
                    WHERE cs2.recept_cd::text = cu.recept_cd::text
                      AND cs2.calc_cd = ''Syoen''
                      AND cs2.facility_cd = cu.facility_cd
                )
                THEN
                    ''tsk_syoen_grp''

                -- それ以外の非包括薬剤
                ELSE
                    ''tsk_shink_grp'' || LPAD(cu.section_type::text, 2, ''0'')
            END AS map_calc_cd
    ) grp ON true
    -- ② map_calc_cd → group_cd
    LEFT JOIN mst_zai_output_map zom
      ON zom.facility_cd = cu.facility_cd
     AND zom.map_calc_cd = grp.map_calc_cd
     AND zom.is_del = ''0''
    -- ③ 包括で算定しない薬はここで落とす
    WHERE NOT (
        EXISTS (
            SELECT 1
            FROM mst_calc_setting_current cs
            WHERE cs.recept_cd::text = cu.recept_cd::text
              AND cs.calc_cd LIKE ''Hk_Yakuzai_%''
              AND cs.facility_cd = cu.facility_cd
        )
        AND cu.is_final_calc = FALSE
    )
),
-- =========================================
-- 材料：STANDARD用とSPECIAL用を別々に定義
-- =========================================
calc_standard_unit_material AS (
    SELECT ''CALC_'' || v.master_version || ''_STANDARD'' AS calc_route,
        mu.* 
    FROM mapped_group_material mu
    JOIN target_version v 
      ON mu.ord_no = v.ord_no
     AND mu.facility_cd = v.facility_cd
),
-- =========================================
-- 材料：STANDARD用とSPECIAL用を別々に定義
-- =========================================
calc_special_unit_material AS (
    SELECT ''CALC_'' || v.master_version || ''_SPECIAL'' AS calc_route,
        mu.*
    FROM mapped_group_material mu
    JOIN target_version v 
      ON mu.ord_no = v.ord_no
     AND mu.facility_cd = v.facility_cd
),
-- =========================================
-- 薬剤：STANDARD用とSPECIAL用を別々に定義
-- =========================================
calc_standard_unit_drug AS (
    SELECT ''CALC_'' || v.master_version || ''_STANDARD'' AS calc_route,
        mu.*
    FROM mapped_group_drug mu
    JOIN target_version v
      ON mu.ord_no = v.ord_no
     AND mu.facility_cd = v.facility_cd
),
-- =========================================
-- 薬剤：STANDARD用とSPECIAL用を別々に定義
-- =========================================
calc_special_unit_drug AS (
    SELECT ''CALC_'' || v.master_version || ''_SPECIAL'' AS calc_route,
        mu.*
    FROM mapped_group_drug mu
    JOIN target_version v
      ON mu.ord_no = v.ord_no
     AND mu.facility_cd = v.facility_cd
),
-- =========================================
-- 33. 表示順制御（UNIT設計）
-- =========================================
ordered_calc AS (
    SELECT
        ac.*,
        -- ① unit（ブロック）の並び
        CASE ac.unit_kind
            WHEN ''MANAGEMENT'' THEN 1        
            WHEN ''BASE''       THEN 2
            WHEN ''DISABILITY'' THEN 3
            WHEN ''INDUCTION''  THEN 4
            WHEN ''OTHER''      THEN 5
            WHEN ''INJECTION''  THEN 6
            WHEN ''OXYGEN''     THEN 13
            WHEN ''DIALYZER''   THEN 8
            WHEN ''COAG''       THEN 9
            WHEN ''DIALYSATE''  THEN 10
            WHEN ''DRUG''       THEN 12
            WHEN ''MATERIAL''   THEN 11
            ELSE 99
        END AS unit_order,
        -- ② unit内の行順（ADD → COMMENT のペアを保証）
        CASE ac.row_kind
            WHEN ''OTHER''    THEN 1
            WHEN ''DIALY''    THEN 1
            WHEN ''BASE''     THEN 1
            WHEN ''ADDITION'' THEN 2
            WHEN ''COMMENT''  THEN 2
            WHEN ''DATA''     THEN 9
            ELSE 99
        END AS unit_row_order
    FROM all_calc AS ac
    INNER JOIN dialyze_route dr 
       ON dr.ord_no = ac.ord_no
      AND dr.calc_route = ac.calc_route
    
    UNION ALL 
    
    SELECT
        mm.*,
        CASE mm.unit_kind
            WHEN ''MATERIAL'' THEN 11
            ELSE 99
        END AS unit_order,
        CASE mm.row_kind
            WHEN ''BASE''     THEN 1
            WHEN ''COMMENT''  THEN 2
            WHEN ''DATA''     THEN 9
            ELSE 99
        END AS unit_row_order
    FROM calc_standard_unit_material AS mm
    INNER JOIN dialyze_route dr 
       ON dr.ord_no = mm.ord_no
      AND dr.calc_route = mm.calc_route
    
    UNION ALL 

    SELECT
        mm.*,
        CASE mm.unit_kind
            WHEN ''MATERIAL'' THEN 11
            ELSE 99
        END AS unit_order,
        CASE mm.row_kind
            WHEN ''BASE''     THEN 1
            WHEN ''COMMENT''  THEN 2
            WHEN ''DATA''     THEN 9
            ELSE 99
        END AS unit_row_order
    FROM calc_special_unit_material AS mm
    INNER JOIN dialyze_route dr 
       ON dr.ord_no = mm.ord_no
      AND dr.calc_route = mm.calc_route
    
    UNION ALL 
    
    SELECT
        mg.*,
        CASE mg.unit_kind
            WHEN ''DRUG''     THEN 12
            ELSE 99
        END AS unit_order,
        CASE mg.row_kind
            WHEN ''BASE''     THEN 1
            WHEN ''COMMENT''  THEN 2
            WHEN ''DATA''     THEN 9
            ELSE 99
        END AS unit_row_order
    FROM calc_standard_unit_drug AS mg
    INNER JOIN dialyze_route dr 
       ON dr.ord_no = mg.ord_no
      AND dr.calc_route = mg.calc_route
    UNION ALL 
    SELECT
        mg.*,
        CASE mg.unit_kind
            WHEN ''DRUG''     THEN 12
            ELSE 99
        END AS unit_order,
        CASE mg.row_kind
            WHEN ''BASE''     THEN 1
            WHEN ''COMMENT''  THEN 2
            WHEN ''DATA''     THEN 9
            ELSE 99
        END AS unit_row_order
    FROM calc_special_unit_drug AS mg
    INNER JOIN dialyze_route dr 
       ON dr.ord_no = mg.ord_no
      AND dr.calc_route = mg.calc_route
),
-- =========================================
-- numbered_unit（ユニット内順序付け）
-- =========================================
numbered_unit AS (
    SELECT
        ac.*,
        ROW_NUMBER() OVER (
            PARTITION BY ac.ord_no, ac.unit_kind, ac.group_cd
            ORDER BY ac.unit_row_order, ac.recept_cd
        ) AS unit_no_new
    FROM ordered_calc ac
    INNER JOIN dialyze_route dr
       ON dr.ord_no = ac.ord_no
      AND dr.facility_cd = ac.facility_cd
      AND dr.calc_route = ac.calc_route
    WHERE ac.recept_cd IS NOT NULL
    AND ac.is_final_calc IS TRUE
),
zai_ordered_base AS (
    SELECT
        nu.*,
        zop.is_individual,
        zop.is_close,
        zop.start_recept_cd,
        zop.start_comment,
        zop.end_recept_cd,
        zop.end_comment
    FROM numbered_unit nu
    LEFT JOIN ntss.mst_zai_output_pattern zop
      ON nu.group_cd::int = zop.pattern_cd
     AND nu.facility_cd = zop.facility_cd
     AND zop.is_del = ''0''
),
account_base AS (
    SELECT
        *,
        CASE WHEN is_individual = ''1'' THEN ''INDIVIDUAL''
             ELSE ''BASE''
        END AS indiv_flag
    FROM zai_ordered_base
),
split_comment AS (
    SELECT
        *,
        CASE
            WHEN CHAR_LENGTH(comment_text) <= 34 THEN comment_text
            ELSE SUBSTRING(comment_text FROM 1 FOR 34)
        END AS comment_line1,
        CASE
            WHEN CHAR_LENGTH(comment_text) <= 34 THEN NULL
            WHEN CHAR_LENGTH(comment_text) <= 41 THEN SUBSTRING(comment_text FROM 35)
            ELSE SUBSTRING(comment_text FROM 35 FOR 7)
        END AS comment_line2
    FROM account_base
),
-- group_cd × unit_kind 単位で最後の行番号（ZAI_END用）
last_unit AS (
    SELECT
        facility_cd,
        ord_no,
        group_cd,
        MAX(unit_no_new) + 1 AS last_unit_no  -- group_cd 全体の最後
    FROM split_comment
    --WHERE group_cd IS NOT NULL
    GROUP BY facility_cd, ord_no, group_cd
),
-- group_cd 単位で先頭行番号（ZAI_HEAD用、BASE がない場合のみ）
first_unit AS (
    SELECT
        s.facility_cd,
        s.ord_no,
        s.unit_kind,
        s.group_cd,
        MIN(s.unit_no_new) AS first_unit_no
    FROM split_comment s
    WHERE s.group_cd IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM split_comment sc2
          WHERE sc2.facility_cd = s.facility_cd
            AND sc2.ord_no = s.ord_no
            AND sc2.unit_kind = s.unit_kind
            AND sc2.group_cd = s.group_cd
            AND sc2.row_kind = ''BASE''
      )
    GROUP BY s.facility_cd, s.ord_no, s.unit_kind, s.group_cd
),
final_account AS (
    -- 通常行（コメント1行目含む）
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind, recept_cd, quantity, unit,
        NULL::text AS comment_flag,
        comment_line1 AS comment_out,
        is_final_calc,
        0 AS close_phase
    FROM split_comment

    UNION ALL

    -- コメント2行目
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind, recept_cd, quantity, unit,
        NULL::text,
        comment_line2,
        is_final_calc,
        0
    FROM split_comment
    WHERE comment_line2 IS NOT NULL

    UNION ALL

    -- Start コメント
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind,
        CASE WHEN start_comment IS NOT NULL THEN NULL ELSE recept_cd END,
        quantity, unit,
        ''2'',
        start_comment,
        is_final_calc,
        0
    FROM split_comment
    WHERE start_comment IS NOT NULL

    UNION ALL

    -- End コメント
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind,
        CASE WHEN end_comment IS NOT NULL THEN NULL ELSE recept_cd END,
        quantity, unit,
        ''2'',
        end_comment,
        is_final_calc,
        0
    FROM split_comment
    WHERE end_comment IS NOT NULL

    UNION ALL

    -- Start_recept_cd 行（コメントと同様に追加）
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind,
        start_recept_cd AS recept_cd,
        quantity, unit,
        NULL::text AS comment_flag,
        NULL::text AS comment_out,
        is_final_calc,
        0 AS close_phase
    FROM split_comment
    WHERE start_recept_cd IS NOT NULL

    UNION ALL

    -- End_recept_cd 行（コメントと同様に追加）
    SELECT
        facility_cd, ord_no, group_cd, unit_no_new,
        unit_kind, row_kind,
        end_recept_cd AS recept_cd,
        quantity, unit,
        NULL::text AS comment_flag,
        NULL::text AS comment_out,
        is_final_calc,
        0 AS close_phase
    FROM split_comment
    WHERE end_recept_cd IS NOT NULL

    UNION ALL

    -- ZAI_HEAD（先頭が BASE がない group_cd のみ）
    SELECT
        s.facility_cd,
        s.ord_no,
        s.group_cd,
        f.first_unit_no AS unit_no_new,
        s.unit_kind,
        ''ZAI_HEAD'' AS row_kind,
        zop.recept_cd,
        NULL::numeric,
        NULL::text,
        NULL::text,
        NULL::text,
        CASE
            WHEN MAX(CASE WHEN s.is_final_calc THEN 1 ELSE 0 END) = 1 THEN TRUE
            ELSE FALSE
        END AS is_final_calc,
        0 AS close_phase
    FROM split_comment s
    JOIN first_unit f
      ON f.facility_cd = s.facility_cd
     AND f.ord_no = s.ord_no
     AND f.unit_kind = s.unit_kind
     AND f.group_cd = s.group_cd
    JOIN ntss.mst_zai_output_pattern zop
      ON zop.pattern_cd = s.group_cd
     AND zop.facility_cd = s.facility_cd
     AND zop.is_del = ''0''
    WHERE zop.recept_cd IS NOT NULL
    GROUP BY s.facility_cd, s.ord_no, s.unit_kind, s.group_cd, f.first_unit_no, zop.recept_cd

    UNION ALL

    -- ZAI_END（unit_kind 単位で最後の行）
    SELECT
        l.facility_cd,
        l.ord_no,
        l.group_cd,
        l.last_unit_no AS unit_no_new,
        NULL::text AS unit_kind,      -- ここを NULL にして group_cd 全体の最後
        ''ZAI_END'' AS row_kind,
        NULL::text AS recept_cd,
        NULL::numeric AS quantity,
        NULL::text AS unit,
        NULL::text AS comment_flag,
        NULL::text AS comment_out,
        CASE
            WHEN MAX(s.is_final_calc::int) = 1 THEN TRUE
            ELSE FALSE
        END AS is_final_calc,
        1 AS close_phase
    FROM last_unit l
    LEFT JOIN split_comment s
      ON s.facility_cd = l.facility_cd
     AND s.ord_no = l.ord_no
     AND s.group_cd = l.group_cd
    GROUP BY l.facility_cd, l.ord_no, l.group_cd, l.last_unit_no


),
-- =========================================
-- 剤内並び替えマスタ（mst_section_order）
-- ・同一剤内での正規の並び順を定義するマスタ
-- =========================================
section_priority AS (
    -- マスタの並び順
    SELECT facility_cd, section_type, COALESCE(sort_order, 9999) AS score
    FROM mst_section_order WHERE is_del = ''0''
),
-- =========================================
-- final_account に「剤内区分」と「従来の並び順」を付与
-- =========================================
final_account2_with_scores AS (
    -- 1. 元の並び替えロジックを優先度(priority)として数値化して保持
    SELECT
        f.*,
        r.formal_name,
        r.section_type,
        CASE f.unit_kind
             WHEN ''MANAGEMENT'' THEN 1 
             WHEN ''BASE'' THEN 2 
             WHEN ''DISABILITY'' THEN 3
             WHEN ''INDUCTION'' THEN 4 
             WHEN ''OTHER'' THEN 5 
             WHEN ''INJECTION'' THEN 6
             WHEN ''DIALYZER'' THEN 8 
             WHEN ''COAG'' THEN 9 
             WHEN ''DIALYSATE'' THEN 10
             WHEN ''MATERIAL'' THEN 11 
             WHEN ''DRUG'' THEN 12 
             WHEN ''OXYGEN'' THEN 13 
        ELSE 99
        END AS unit_priority,
        CASE f.row_kind
             WHEN ''ZAI_HEAD'' THEN 1
             WHEN ''BASE'' THEN 2
             WHEN ''DIALY''    THEN 3
             WHEN ''OTHER'' THEN 4
             WHEN ''ADDITION'' THEN 5
             WHEN ''DATA'' THEN 6
             WHEN ''COMMENT'' THEN 7
             WHEN ''ZAI_END'' THEN 98
        ELSE 99
        END AS row_priority
    FROM final_account f
    LEFT JOIN mst_recept_current r ON r.recept_cd = f.recept_cd AND r.facility_cd = f.facility_cd
),
-- =========================================
-- 剤内マスタの順位を付与（コメントは後で親に従う）
-- =========================================
calculated_mst_priority AS (
    -- 2. コメント以外の行にマスタの順位を付与
    SELECT
        f.*,
        CASE WHEN f.row_kind = ''COMMENT'' THEN NULL 
             ELSE COALESCE(s.score, 9999) END AS mst_score
    FROM final_account2_with_scores f
    LEFT JOIN section_priority s ON f.facility_cd = s.facility_cd AND f.section_type = s.section_type
),
-- =========================================
-- コメントを直前の実体行に紐付けるための連番
-- =========================================
fixed_comment_order AS (
    -- 3. LAST_VALUE ... IGNORE NULLS の代わりに MAX() OVER を使用
    -- コメント行に対し、それより前にある最大の項目ID(連番)を振ることでグループ化
    SELECT
        *,
        -- コメント以外の行にだけ一意の連番(base_id)を振る
        CASE WHEN row_kind <> ''COMMENT'' THEN 
            ROW_NUMBER() OVER (PARTITION BY facility_cd, ord_no, group_cd ORDER BY unit_priority, unit_no_new, row_priority)
        END AS base_id
    FROM calculated_mst_priority
),
-- =========================================
-- 各行に「属する実体(base_id)」を設定
-- =========================================
comment_linked AS (
    -- 4. コメント行に「直前の base_id」をコピーし、その base_id が持つ mst_score を結合する
    SELECT
        *,
        MAX(base_id) OVER (
            PARTITION BY facility_cd, ord_no, group_cd 
            ORDER BY unit_priority, unit_no_new, row_priority
        ) AS sort_group_id
    FROM fixed_comment_order
),
-- =========================================
-- 実体＋コメント単位で剤内マスタ順位を確定
-- =========================================
final_mst_map AS (
    -- 5. 各グループ(sort_group_id)がどのマスタ順位(mst_score)を持つべきか確定させる
    SELECT
        *,
        MAX(mst_score) OVER (
            PARTITION BY facility_cd, ord_no, group_cd, sort_group_id
        ) AS final_section_score
    FROM comment_linked
),
final_mst_map2 AS (
    SELECT
        convert_from(
            CASE
                WHEN t.data_type = ''04'' THEN
                    convert_to(''04000100'', ''UTF8'') ||
                    repeat(E'' '', 56)::bytea
                ELSE
                    convert_to(t.data_type, ''UTF8'') ||
                    convert_to(lpad(t.recept_cd, 6, ''0''), ''UTF8'') ||
                    convert_to(t.quantity_str, ''UTF8'') ||
                    convert_to(rpad(t.unit_code, 2, '' ''), ''UTF8'') ||
                    convert_to(''  '', ''UTF8'') ||
                    convert_to(t.comment_type, ''UTF8'') ||
                    convert_to(t.comment, ''UTF8'') ||
                    repeat(E'' '', GREATEST(0, 40 - octet_length(convert_to(t.comment, ''SJIS''))))::bytea ||
                    convert_to(''  '', ''UTF8'')
            END,
            ''UTF8''
        ) AS data_rec
    FROM (
        SELECT
            CASE WHEN row_kind = ''ZAI_END'' THEN ''04'' ELSE ''01'' END AS data_type,
            CASE WHEN recept_cd = ''WP'' THEN ''000000'' ELSE LPAD(recept_cd, 6, ''0'') END AS recept_cd,
            LPAD(REPLACE(TO_CHAR(TRUNC(COALESCE(quantity, 0), 3), ''FM999990.000''), ''.'', ''''), 9, ''0'') AS quantity_str,
            COALESCE(unit, '''') AS unit_code,
            CAST(
                CASE
                    WHEN comment_out IS NOT NULL AND recept_cd = ''WP'' AND row_kind = ''COMMENT'' THEN 2
                    ELSE 0
                END AS CHAR(1)
            ) AS comment_type,
            COALESCE(comment_out, '''') AS comment
        FROM final_mst_map
    ) t
)
SELECT
    ''医事'' AS detail_id,
    -- ★1電文（10行）ごとの明細数
    -- 最終ページなら「全件数 % 10 (0なら10)」、それ以外は常に「10」
    LPAD(CAST(
        CASE 
            WHEN ((ROW_NUMBER() OVER() - 1) / 10) < (COUNT(*) OVER() / 10) 
            THEN 10
            ELSE (CASE WHEN COUNT(*) OVER() % 10 = 0 THEN 10 ELSE COUNT(*) OVER() % 10 END)
        END AS text), 2, ''0'') AS current_page_count,
    ROW_NUMBER() OVER() AS no,
    f.data_rec 
FROM final_mst_map2 AS f
ORDER BY no ASC',2,'[{}]','0','{"applications": [4]}',NULL,'SX_医事連携（明細情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": -1202021, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202023, '-- 【SQL_CD=-1202023】
SELECT
  ''DIAIJI-'' || 
  coalesce(journal.coop_ord_no, '''')  ||
  ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo',2,'[{}]','0','{"applications": [4]}',NULL,'SX_医事連携[送信]ファイル名取得',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
