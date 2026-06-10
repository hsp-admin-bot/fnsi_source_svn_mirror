DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-102, -13, -201, -202, -204, -600016, -600202, -600304, -600511, 9402, 9406, 9409);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600511, 'SELECT 
    1
FROM
    mst_coop_ini AS ini
WHERE
	(
        NOT (@endDateAfter ~ ''^\\d{8}$'') 
        OR TO_DATE(@endDateAfter, ''YYYYMMDD'') IS NULL
    )
    AND @endDateAfter NOT IN (''00000000'', ''99999999'')
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
FROM ord_main AS ord
LEFT JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
WHERE ord.ord_no =  @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)実績) 治療方法連携コード', '2025-01-21 16:03:27.853', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600202, 'WITH 
ord_main_switch AS(
(
      SELECT
        ord.pat_id as pat_id,
        ord.ord_no as ord_no,
        ord.ind_bed_cd as ind_bed_cd,
        ord.treat_date as treat_date,
        ord.up_date as up_date,
        ord.rst_cond_info as rst_cond_info,
        ord.facility_cd as facility_cd,
        ord.ind_treatment_cd as ind_treatment_cd,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.pat_id as pat_id,
        ord.ord_no as ord_no,
        ord.ind_bed_cd as ind_bed_cd,
        ord.treat_date as treat_date,
        ord.up_date as up_date,
        ord.rst_cond_info as rst_cond_info,
        ord.facility_cd as facility_cd,
        ord.ind_treatment_cd as ind_treatment_cd,
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
),

select_dw as(
SELECT physical ->> ''dw'' as dw
FROM pat_unique AS puq
cross join lateral json_array_elements(puq.physical_info ::json) physical
    where
      physical ->> ''exam_date'' = (
        select
          max(physical2 ->> ''exam_date'')
        from
          ord_main_switch ord
          , pat_unique puq2
          cross join lateral json_array_elements(puq2.physical_info ::json) physical2
        where
          TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date
          and COALESCE(physical2 ->> ''dw'', ''ZERO'') <> ''ZERO''
          and ord.pat_id = puq2.pat_id
      )
    and puq.pat_id = @patId
),treatment_coop_cd_no AS (
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''TREATMENT_COOP_CD_NO''
)
SELECT ord.treat_date                                               AS dialysis_date,
       COALESCE(mbd.in_hospital_cd_1, '''')                           AS bed_cd1,
       TO_CHAR(COALESCE((SELECT dw::NUMERIC FROM select_dw), 0),''FM000V9'') AS dw,
       COALESCE(to_char(ord.up_date, ''YYYYMMDD''), '''')               AS update_ymd,
       COALESCE(to_char(ord.up_date, ''HH24MISS''), '''')               AS update_hms,
       COALESCE(pm.medical_care_info ->> ''dialysis_start_date'', '''') AS dialysis_start_date,
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
FROM pat_main AS pm,
     ord_main_switch AS ord
LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
WHERE ord.ord_no = @ordNo
  and pm.pat_id = ord.pat_id', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)指示) 透析条件', '2025-01-21 16:00:58.768', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600016, 'WITH take_cource_info AS (
  SELECT
    1 AS order_no,
    CASE
      TRIM(ini_info ->> ''value'')
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'')
      ELSE TRIM(ini_info ->> ''value'')
    END AS take_cource_flg
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) AS ini_info
  WHERE
    ini.is_del = ''0''
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd''
    AND COALESCE(ini_info ->> ''key0'', '''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND''
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG''
  UNION
  SELECT
    2 AS order_no,
    ''1'' AS take_cource_flg
  ORDER BY
    order_no ASC
  LIMIT
    1
), mst_ward_cd AS (
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
        WHEN (
          SELECT
            take_cource_flg
          FROM
            take_cource_info
        ) = ''1''
        AND (''@inOutClass'') = ''1'' -- ''1''：入院
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-204, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
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
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
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
, func_koucoagulant AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
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
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
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
    t.values ->> ''item_code'' AS item_code
    , t.values ->> ''function_code'' AS function_code
    , t.values ->> ''item_generation'' AS item_generation
    , t.idx AS idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) WITH ORDINALITY AS t(values, idx)
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
          ''指示詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03
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
        UNION

        SELECT
          --VA情報
          ''指示詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION 

        SELECT --治療項目情報
          ''指示詳細'' AS detail_id
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
            END AS e1 --治療コード
          , (SELECT value FROM sendmsg_gen) AS e02
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
          , ''03'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.ind_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION 

        SELECT --ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS  e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --医材内ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
          
        UNION 
        SELECT --抗凝固剤
        ''指示詳細'' AS detail_id
        , ''抗凝固剤'' AS sbt_key
        , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03
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
            1 AS temp_no
            , 1 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , info.value ->> ''value'' AS medi_cd
            , to_char(
                (
                  CASE
                    WHEN ord.ind_cond_info -> ''26'' ->> ''value'' ~ ''^\\d+(\\.\\d+)?$''
                      AND ord.ind_cond_info -> ''28'' ->> ''value'' ~ ''^\\d+(\\.\\d+)?$''
                    THEN
                      (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM99999.9999'')
                      + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM99999.9999''))
                    ELSE
                      0
                  END
                ),
                ''FM00000V9999''
              ) AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no
            , 2 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text

          UNION
          SELECT --透析液情報
          ''指示詳細'' AS detail_id
          , ''透析液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
            TO_NUMBER(
              COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', ''0'')
              , ''FM00000.0000''
            )
            , ''FM00000V9999''
          ) AS e4
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 1 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --補液情報
          ''指示詳細'' AS detail_id
          , ''補液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
              TO_NUMBER(
                COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', ''0'')
                , ''FM00000.0000''
              )
              , ''FM00000V9999''
            ) AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 2 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo

        UNION
        SELECT --投与薬剤情報
        ''指示詳細'' AS detail_id
        , ind_medi.sbt_key AS sbt_key
        , ind_medi.e01 AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , COALESCE(ind_medi.e03, (SELECT value FROM func_medicine)) AS e03
        , ind_medi.e04 AS e04
        , ind_medi.e05 AS e05
        , ''000000000'' AS e06
        , ''  '' AS e07
        , ind_medi.e07 AS e08
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
            , ''投与薬剤情報(通常)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , to_char(
                to_number(t.medi ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
              ) AS e04
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
            , ''投与薬剤'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
          UNION
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , CASE mmxd ->> ''solvent''
              WHEN ''1'' THEN to_char(
                  to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              ELSE to_char(
                  to_number(t.medi ->> ''amount'', ''FM99999.9999'') * to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              END AS e04
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
          , ''調製'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) mmxd
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
        ) AS ind_medi
        LEFT JOIN mst_medi mmd
        ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order
        ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order
        ON ind_medi.procedure_cd = procedure_order.procedure_code
        UNION

        SELECT
          --穿刺針情報
          ''指示詳細'' AS detail_id
          , ''穿刺針'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
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
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.ind_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            LEFT JOIN mst_equip
              ON t.equip ->> ''cd'' = mst_equip.equipment_cd ::text
            LEFT JOIN mst_equipment_class
              ON mst_equip.class_cd = mst_equipment_class.class_cd
            WHERE
              ord.ord_no = @ordNo
              AND mst_equipment_class.class_type IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION

        SELECT --医材情報
          ''指示詳細'' AS detail_id
          , ''医材'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , CASE
            WHEN mst_equipment_class.class_type = ''4'' THEN ''000010000''
            ELSE to_char(
              to_number(equip ->> ''amount'', ''99999.9999'')
              , ''FM00000V9999''
            )
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
          LEFT JOIN mst_equip meq
              ON meq.equipment_cd = TO_NUMBER(t.equip ->> ''cd'', ''FM999999999999'')
            LEFT JOIN mst_equipment_class
              ON meq.class_cd = mst_equipment_class.class_cd
        WHERE
          t.equip ->> ''equip_type'' = ''0''
          AND mst_equipment_class.class_type NOT IN (''2'', ''3'')
          AND ord.ord_no = @ordNo

        --特殊血液浄化
        UNION
        SELECT --1次膜情報
          ''指示詳細'' AS detail_id
          , ''1次膜'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''11'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equip AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --2次膜情報
          ''指示詳細'' AS detail_id
          , ''2次膜'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --血液回路
          ''指示詳細'' AS detail_id
          , ''血液回路'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --吸着カラム
          ''指示詳細'' AS detail_id
          , ''吸着カラム'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''14'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT
          --加算(その他)Ver1
          ''指示詳細'' AS detail_id
          , ''加算(その他)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
                --
        SELECT
          --加算(患者)、加算(その他)その2、項目コメント、透析コメント1~3Ver2
          ''指示詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e03 --機能コード
          , ind_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
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
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
          UNION
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
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
        ) AS ind_medi
        LEFT JOIN mst_medi mmd ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON ind_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        --
        UNION

        SELECT --加算(透析困難理由)
          ''指示詳細'' AS detail_id
          , ''透析困難'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION

        SELECT --その他項目(透析時間)
          ''指示詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , (SELECT value FROM func_other_item) AS e03 --項目名
          , to_char(
            TO_NUMBER(
              ord.ind_cond_info -> ''1'' ->> ''value''
              , ''FM999999999999''
            )
            , ''FM00000V9999''
          ) AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT
        --項目コメント Ver.1
        ''指示詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント1 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント2 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''21'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント3 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''22'' AS e08
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
  ) cost_fin', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)詳細指示繰り返し部', '2025-01-09 10:16:16.678', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);
INSERT INTO sys_data_set
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
        CASE WHEN split_part(value, '':'', 1) ~ ''^\\d+(\\.\\d+)?$''
        THEN NULLIF(split_part(value, '':'', 1), '''')
        ELSE NULL
        END AS lower_bound,
        CASE WHEN split_part(value, '':'', 2) ~ ''^\\d+(\\.\\d+)?$''
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
    SELECT FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60) as minutes
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
          , TO_CHAR(TO_NUMBER(rst_weight_info ->> ''water_removal_rst'', ''FM99999.9999''), ''FM00000V9999'') AS e04
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-201, 'WITH trend_interval_value AS (
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
            WHEN info->>''key2'' = ''BLOOD_FLOW_VAITAL_CD'' THEN ''36''
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
        occur_time_with_sec,
        FIRST_VALUE(vital_data) OVER (
			PARTITION BY vital_cd, occur_time_with_sec 
            ORDER BY occur_time_with_sec DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS vital_data
    FROM query_1_ranked
    WHERE rank_within_time = 1
    ORDER BY occur_date ASC , vital_cd ASC
)
,query_1_final AS (
    SELECT
        occur_date,
        detail_id,
        vital_cd,
        vital_data,
        occur_time_with_sec
    FROM query_1_filled
    ORDER BY occur_date, vital_cd
)
, query_2 AS (
    SELECT
    	to_char((ord.rst_weight_info->>''weight_before_date'')::timestamp, ''YYYYMMDDHH24MI'') AS bw_date,
        (ord.rst_weight_info->>''weight_before_date'')::timestamp(3) AS bw_date_with_sec,
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS bw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_before'' AS NUMERIC), ''FM999999990.00'') AS bw_w,
        ord.rst_weight_info->>''weight_before'' AS aaa
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
    	to_char((ord.rst_weight_info->>''weight_after_date'')::timestamp, ''YYYYMMDDHH24MI'') AS aw_date,
        (ord.rst_weight_info->>''weight_after_date'')::timestamp(3) AS aw_date_with_sec,
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS aw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_after'' AS NUMERIC), ''FM999999990.00'') AS aw_w        
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
, query_4_base AS (
    SELECT
        to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
        occur_date AS occur_time_with_sec, 
        monitor_data,
        MAX(occur_date) OVER () AS max_occur_time_with_sec
    FROM
        mni_monitor
    WHERE
        ord_no = @ordNo
        AND data_type = 1
        AND is_del = ''0''
)

, query_4_filtered AS (
    SELECT
        occur_date,
        occur_time_with_sec,
        monitor_data
    FROM
        query_4_base
    WHERE
        occur_time_with_sec <> max_occur_time_with_sec
)

, query_4_deduplicated AS (
    SELECT
        occur_date,
        occur_time_with_sec,
        monitor_data
    FROM (
        SELECT
            occur_date,
            occur_time_with_sec,
            monitor_data,
            ROW_NUMBER() OVER (
                PARTITION BY to_number(monitor_data->>''1'', ''999'')
                ORDER BY occur_time_with_sec ASC
            ) AS rank_within_value
        FROM query_4_filtered
    ) AS ranked
    WHERE rank_within_value = 1
)

, query_4_interval AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        CASE
            WHEN to_number(vit_ini.target_key, ''999'') IN (5, 32, 33, 72, 73) 
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999990.00'')
            WHEN to_number(vit_ini.target_key, ''999'') IN (9, 17, 21, 37, 74, 80) 
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999990.0'')
            WHEN vit_ini.target_key = ''31'' 
                THEN CASE
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
        occur_date,
        occur_time_with_sec
    FROM
        query_4_deduplicated
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            target_key IS NOT NULL
    ) AS vit_ini
    JOIN trend_interval_value ON TRUE
    WHERE
        to_number(monitor_data->>''1'', ''999'') >= 0
        AND (to_number(monitor_data->>''1'', ''999'') % trend_interval_value.trend_value::numeric = 0)
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
)

,query_4_sorted AS (
    SELECT
        detail_id, 
        vital_cd, 
        vital_data, 
        occur_date, 
        monitor_data,
        occur_time_with_sec
    FROM (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY monitor_data->>''1'' ORDER BY occur_time_with_sec ASC) AS rank_within_value
        FROM query_4_interval
    ) AS ranked
    WHERE rank_within_value = 1
    ORDER BY occur_date, vital_cd
)
,all_queries_combined AS (
    SELECT occur_time_with_sec, ''query_1'' AS query_type FROM query_1_final
    UNION ALL
    SELECT bw_date_with_sec AS occur_time_with_sec, ''query_2'' AS query_type FROM query_2
    UNION ALL
    SELECT aw_date_with_sec AS occur_time_with_sec, ''query_3'' AS query_type FROM query_3
    UNION ALL
    SELECT occur_time_with_sec, ''query_4'' AS query_type FROM query_4_sorted
)

,all_queries_combined_with_id AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY query_type ASC, occur_time_with_sec ASC) AS event_id
    FROM all_queries_combined
    ORDER BY event_id ASC
)

,excluded_occur_times AS (
    SELECT DISTINCT occur_time_with_sec
    FROM all_queries_combined_with_id
    WHERE event_id > 999
)
SELECT occur_date, detail_id, vital_cd, vital_data 
FROM query_1_final 
WHERE occur_time_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT bw_date, detail_id, bw_cd, bw_w 
FROM query_2
WHERE bw_date_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT aw_date, detail_id, aw_cd, aw_w 
FROM query_3
WHERE aw_date_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT occur_date, detail_id, vital_cd, vital_data 
FROM query_4_sorted
WHERE occur_time_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)バイタル繰り返し部', '2024-11-26 14:03:54.146', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM pat_coop_detail pcd
WHERE pcd.pat_id = @patId
    AND is_del = ''0''
    AND coop_version = @coopVersion
    AND ''2'' = @messageType
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者補完情報20個', '2024-12-09 16:44:42.537', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-13, 'SELECT ord.treat_date                                               AS dialysis_date,
       ord.facility_cd                                              AS facility_cd,
       COALESCE(concat(ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '',
                       ord.ind_schedule_user_info ->> ''ind_user_first_name''),
                '''')                                                 AS ind_name,
       COALESCE(LEFT(concat(ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '',
                            ord.ind_schedule_user_info ->> ''ind_user_first_name''), 5),
                '''')                                                 AS ind_name10,
       COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''')   AS staff_cd_comm,
       COALESCE(ord.ind_treat_start_time, '''')                       AS start_time,
       COALESCE(mkr.in_hospital_cd_1, '''')                           AS kur_cd1,
       COALESCE(mkr.kur_name, '''')                                   AS kur_name,
       COALESCE(mbd.bed_cd, 0)                                      AS bed_cd,
       COALESCE(mbd.in_hospital_cd_1, '''')                           AS bed_cd1,
       COALESCE(mbd.bed_name, '''')                                   AS bed_name,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = '''' or mtt.in_hospital_cd_a1 is NULL THEN ''不明''
                    ELSE mtt.treatment_name END,
                '''')                                                 AS treatment_name,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = '''' or mtt.in_hospital_cd_a1 is NULL THEN ''-''
                    ELSE mtt.in_hospital_cd_a1 END,
                '''')                                                 AS treatment_cd,
       COALESCE(ord.ind_dw, 0)                                      AS dw,
       ord.ind_cond_info -> ''1'' ->> ''value''                         AS dialysis_time_m,
       case
           when RIGHT((COALESCE(
                               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                     2) ||
                               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                               ''0''
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER)::TEXT, 2)::INTEGER >= 60
               then ((COALESCE(
                              RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                    2) ||
                              RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                              ''0''
                      )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER) + 100 - 60) ::TEXT

           else
               CASE
                   WHEN
                       COALESCE(
                               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                     2) ||
                               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                               ''0''
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER >= 2400
                       THEN
                       LPAD((COALESCE(
                                     RIGHT(''00'' ||
                                           TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                           2) ||
                                     RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60),
                                           2),
                                     ''0''
                             )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER - 2400) ::TEXT, 4, ''0'')
                   ELSE
                       (COALESCE(
                                RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                      2) ||
                                RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                                ''0''
                        )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER) ::TEXT
                   END
           END                                                      as end_time,
       COALESCE(
               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0), 2) || '':'' ||
               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
               ''0''
       )                                                            AS treatment_time,
       COALESCE(
               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0), 2) ||
               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
               ''''
       )                                                            AS treatment_time4,
       COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''')           AS treatment_time_m,--追加
       COALESCE(ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''')    AS va,
       COALESCE(SUBSTRING(ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3),
                '''')                                                 AS va3,
       COALESCE(mva.in_hospital_cd_1, '''')                           AS va_cd1,
       COALESCE(
               (CASE mva.va_direct
                    WHEN ''0'' THEN ''右''
                    WHEN ''1'' THEN ''左''
                    WHEN ''2'' THEN ''両方''
                    WHEN ''3'' THEN ''無''
                    ELSE ''不明'' END),
               ''''
       )                                                            AS va_direct,
       COALESCE(ord.ind_cond_info -> ''3'' ->> ''value'', '''')           AS target_weight,
       COALESCE(ord.ind_cond_info -> ''4'' ->> ''value'', '''')           AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
       COALESCE(mdr.model_number, '''')                               AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
       COALESCE(mdr.in_hospital_cd_1, '''')                           AS dialyzer_cd1,
       COALESCE(ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''')    AS adsorption_column,
       COALESCE(meqad.in_hospital_cd_1, '''')                         AS ad_cd1,
       COALESCE(ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''')    AS primary_film,
       COALESCE(meqpr.in_hospital_cd_1, '''')                         AS pr_cd1,
       COALESCE(ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''')    AS secondary_film,
       COALESCE(meqse.in_hospital_cd_1, '''')                         AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
       COALESCE(meqa.equipment_name, '''')                            AS puncture_needle_a,
       COALESCE(meqa.in_hospital_cd_1, '''')                          AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
       COALESCE(meqv.equipment_name, '''')                            AS puncture_needle_v,
       COALESCE(meqv.in_hospital_cd_1, '''')                          AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
       COALESCE(meqsn.equipment_name, '''')                           AS puncture_needle_sn,
       COALESCE(meqsn.in_hospital_cd_1, '''')                         AS sn_cd1,
       COALESCE((CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END),
                '''')                                                 AS single_needle,
       COALESCE(ord.ind_cond_info -> ''13'' ->> ''value'', '''')          AS blood_circuit,
       COALESCE(meqbc.in_hospital_cd_1, '''')                         AS bc_cd1,
       COALESCE(ord.ind_cond_info -> ''14'' ->> ''value'', '''')          AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
       COALESCE(med15.medicine_name, '''')                            AS dialysate,
       COALESCE(med15.in_hospital_cd_1, '''')                         AS dialysate_cd1,
       COALESCE(ord.ind_cond_info -> ''16'' ->> ''value'', '''')          AS dialysate_flow_rate,
       COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', '''')          AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
       COALESCE(med15.unit_second, '''')                              AS dialysate_amount_unit,
       COALESCE(ord.ind_cond_info -> ''18'' ->> ''value'', '''')          AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
       COALESCE(med25.medicine_name, '''')                            AS fluid_replacement,
       COALESCE(med25.in_hospital_cd_1, '''')                         AS ds_cd1,
       COALESCE(ord.ind_cond_info -> ''20'' ->> ''value'', '''')          AS fluid_replacement_amount,
       COALESCE(
               (CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END),
               '''')                                                  AS fluid_replacement_timing,
       COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', '''')          AS fluid_replacement_use_count,
       COALESCE(ord.ind_cond_info -> ''22'' ->> ''unit'', '''')           AS fluid_replacement_use_count_unit,
       COALESCE(ord.ind_cond_info -> ''23'' ->> ''value'', '''')          AS fluid_replacement_temperature,
       COALESCE(ord.ind_cond_info -> ''24'' ->> ''value'', '''')          AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
       COALESCE(med25.medicine_name, '''')                            AS anti_coagulant,
       COALESCE(med25.in_hospital_cd_1, '''')                         AS anti_coagulant_cd1,
       COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', '''')          AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
       COALESCE(med25.unit, '''')                                     AS anti_coagulant_one_shot_amount_unit,
       COALESCE(ord.ind_cond_info -> ''27'' ->> ''value'', '''')          AS anti_coagulant_sustained_speed,
       COALESCE(ord.ind_cond_info -> ''27'' ->> ''unit'', '''')           AS anti_coagulant_sustained_speed_unit,
       COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', '''')          AS anti_coagulant_sustained_amount,
       COALESCE(ord.ind_cond_info -> ''28'' ->> ''unit'', '''')           AS anti_coagulant_sustained_amount_unit,
       COALESCE(
               TO_NUMBER(ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'') +
               TO_NUMBER(ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999''),
               0
       )                                                            AS anti_coagulant_total_amount,--抗凝固剤総量
       COALESCE((CASE ord.ind_cond_info -> ''29'' ->> ''value''
                     WHEN ''1'' THEN ''使用する''
                     WHEN ''0'' THEN ''使用しない''
                     ELSE NULL END),
                '''')                                                 AS ip,
       COALESCE((CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END),
                '''')                                                 AS ip_start,
       COALESCE(ord.ind_cond_info -> ''31'' ->> ''value'', '''')          AS ip_one_short_amount,
       COALESCE(ord.ind_cond_info -> ''32'' ->> ''value'', '''')          AS ip_speed,
       COALESCE(ord.ind_cond_info -> ''33'' ->> ''value'', '''')          AS ip_speed_max,
       COALESCE((CASE ord.ind_cond_info -> ''34'' ->> ''value''
                     WHEN ''1'' THEN ''使用する''
                     WHEN ''0'' THEN ''使用しない''
                     ELSE NULL END),
                '''')                                                 AS auto_one_shot,
       COALESCE((CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END),
                '''')                                                 AS ip_auto_off,
       COALESCE(ord.ind_cond_info -> ''36'' ->> ''value'', '''')          AS ip_auto_off_time,
       COALESCE((CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END),
                '''')                                                 AS ip_monitor_auto_off,
       COALESCE(ord.ind_cond_info -> ''38'' ->> ''value'', '''')          AS ip_monitor_auto_off_time,
       COALESCE(pm.medical_care_info ->> ''dialysis_start_date'', '''') AS dialysis_start_date,
       COALESCE(to_char(ord.up_date, ''YYYYMMDD''), '''')               AS update_ymd,
       COALESCE(to_char(ord.up_date, ''HH24MISS''), '''')               AS update_hms
FROM pat_main AS pm,
     ord_main AS ord
         LEFT OUTER JOIN mst_equipment AS meqa
                         ON meqa.equipment_cd = cast(ord.ind_cond_info -> ''9'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqv
                         ON meqv.equipment_cd = cast(ord.ind_cond_info -> ''10'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqsn
                         ON meqsn.equipment_cd = cast(ord.ind_cond_info -> ''11'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqad
                         ON meqad.equipment_cd = cast(ord.ind_cond_info -> ''6'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqpr
                         ON meqpr.equipment_cd = cast(ord.ind_cond_info -> ''7'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqbc
                         ON meqbc.equipment_cd = cast(ord.ind_cond_info -> ''13'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqse
                         ON meqse.equipment_cd = cast(ord.ind_cond_info -> ''8'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med15
                         ON med15.medicine_cd = cast(ord.ind_cond_info -> ''15'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med19
                         ON med19.medicine_cd = cast(ord.ind_cond_info -> ''19'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med25
                         ON med25.medicine_cd = cast(ord.ind_cond_info -> ''25'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
         LEFT OUTER JOIN mst_dialyzer AS mdr
                         ON mdr.dialyzer_cd = cast(ord.ind_cond_info -> ''5'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = cast(ord.ind_cond_info -> ''2'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
         LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
WHERE ord.ord_no = @ordNo
  and pm.pat_id = ord.pat_id', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）指示）透析条件', '2022-08-05 10:58:32.885', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9402, 'INSERT INTO mst_personal_user( 
  facility_cd
  , user_type
  , user_last_name
  , user_first_name
  , user_last_name_kana
  , user_first_name_kana
  , user_last_name_alpha
  , user_first_name_alpha
  , user_email_address_1
  , user_email_address_2
  , extension_no
  , home_no
  , mobile_phone_no
  , fax_no
  , zipcd_3
  , zipcd_4
  , address
  , address_kana
  , job_cd
  , reg_date
  , up_date
  , administrator
  , is_disp
  , is_del
  , in_hospital_cd_1
  , in_hospital_cd_2
  , info_disp_to_admin
  , anesthesiologist_license_no
  , signin_date
  , patient_shared
  , fn_staff_cd
) 
SELECT
  ''@facilityCd''
  , TO_NUMBER(COALESCE(NULLIF(''@userType'', ''''), ''0''), ''FM9'')
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 1)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 1)) 
    END
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 2)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 2)) 
    END
  , personal_info_encrypt(NULLIF(''@userLastNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userFirstNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress1'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress2'', ''''))
  , personal_info_encrypt(NULLIF(''@extensionNo'', ''''))
  , personal_info_encrypt(NULLIF(''@homeNo'', ''''))
  , personal_info_encrypt(NULLIF(''@mobilePhoneNo'', ''''))
  , personal_info_encrypt(NULLIF(''@faxNo'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd3'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd4'', ''''))
  , personal_info_encrypt(NULLIF(''@address'', ''''))
  , personal_info_encrypt(NULLIF(''@addressKana'', ''''))
  , personal_info_encrypt(NULLIF(''@fnwJobCd'', ''''))
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , TO_NUMBER( COALESCE(NULLIF(''@administrator'', ''''), ''0''), ''FM9'') 
  , ''1''
  , ''0''
  , NULLIF(''@inHospitalCd1'', '''')
  , NULLIF(''@inHospitalCd2'', '''')
  , ''0''
  , personal_info_encrypt(NULLIF(''@anesthesiologistLicenseNo'', ''''))
  , NULL
  , CASE ''@patientShared'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patientShared'', ''FM9999999999'') 
    END
  , NULLIF(''@fnStaffCd'', '''')
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9406, 'WITH validated_user_id AS (
 select 
case 
	when 
	    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter'' then ''@userId''
    else ''0''
end AS converted_user_id
)
INSERT INTO mst_user_authentication(
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history
)
SELECT
  (select converted_user_id from validated_user_id) :: bigint
  , ''@facilityCd''
  , NULLIF(''@dispUserId'', '''')
  , COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , 0
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9409, 'WITH staff_job_cd AS (
      SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd'' 
        AND is_del = ''0''
        AND info ->> ''key0'' = ''HR''
        AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
        AND info ->> ''key2'' = ''DEFAULT_STAFF_JOB_CD''
 )
 , mst_jobs as (
  SELECT
  mst_job.in_hospital_cd_1 job_cd,
  ROW_NUMBER() OVER (ORDER BY 1) AS priority
  FROM
  	mst_job 	
  WHERE 
  	mst_job.in_hospital_cd_1 = ''@jobCd''
  	AND mst_job.facility_cd = ''@facilityCd'' 
  UNION 
  SELECT
  	value job_cd,
  	ROW_NUMBER() OVER (ORDER BY 2) AS priority
  FROM
  	staff_job_cd
  ORDER BY priority ASC
  LIMIT 1
  )
, job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.up_date
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
        , CAST(mst_jobs.job_cd AS TEXT) AS select_job_cd
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        CROSS JOIN mst_jobs AS mst_jobs
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_job''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.job_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.in_hospital_cd_1 = select_job_cd
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , CURRENT_TIMESTAMP AS up_date
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC , up_date DESC  LIMIT 1
) 
, job_user_settings AS ( 
  SELECT
    job_cd
    , ''{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ''
		  || job.default_menu_functions
      || '', "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "''
			|| job.initial_menu_function
      || ''", "personal_settings": [], "authorized_functions": ''
			|| job.default_menu_functions
      || '', "authorized_authorities": ''
			|| job.default_authorized_authorities
      || ''}'' AS user_settings 
  FROM
    job_settings AS job
) 
, validated_user_id AS (
 select 
case 
	when 
	    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfte'' then ''@userId''
    else ''0''
end AS converted_user_id
)
INSERT INTO mst_user( 
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
  , tmp_log_search_condition
  , secret_key
  , is_set_qr_code
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
) 
SELECT
  (select converted_user_id from validated_user_id) :: bigint
  , CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , CASE ''@isProvisional'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@isProvisional'', ''FM9'') 
    END
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''1''
  , ''0''
  , CASE ''@patId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patId'', ''FM9999999999999999999'') 
    END
  , NULL
  , NULLIF(''@secretKey'', '''')
  , CASE ''@isSetQrCode'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isSetQrCode'', ''FM9'') 
    END
  , CASE ''@isConsent'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isConsent'', ''FM9'') 
    END
  , NULL
  , NULL
  , ''@facilityCd''
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);