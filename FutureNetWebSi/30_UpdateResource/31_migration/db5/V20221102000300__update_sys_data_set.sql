delete from ntss.sys_data_set where sql_cd = '3204';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (3204, 'WITH up_disease_date_flg_info AS (
    -- 原疾患発症日の取り込み有無(0：発症日を取り込む(デフォルト)、1：発症日を取り込まない)
    SELECT 1 AS order_no
         , CASE TRIM(ini_info ->> ''value'')
               WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
               ELSE TRIM(ini_info ->> ''value'')
        END  AS up_disease_date_flg
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
    WHERE ini.is_del = ''0''
      AND ini.facility_cd = ''@facilityCd''
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV''
      AND TRIM(ini_info ->> ''key2'') = ''UP_DISEASE_DATE_FLG''
    UNION
    SELECT 2   AS order_no
         , ''0'' AS up_disease_date_flg
    ORDER BY order_no ASC
    LIMIT 1)
   , up_base_disease_flg_info as (
    -- 原疾患が電文に存在しない場合に「原疾患として扱う」チェックをOFFに更新するかどうかを設定 0：更新する(デフォルト) 1：更新しない
    SELECT 1 AS order_no
         , CASE TRIM(ini_info ->> ''value'')
               WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
               ELSE TRIM(ini_info ->> ''value'')
        END  AS up_base_disease_flg
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
    WHERE ini.is_del = ''0''
      AND ini.facility_cd = ''@facilityCd''
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV''
      AND TRIM(ini_info ->> ''key2'') = ''UP_BASE_DISEASE_FLG''
    UNION
    SELECT 2   AS order_no
         , ''0'' AS up_disease_date_flg
    ORDER BY order_no ASC
    LIMIT 1)
   , disease_date_info_tmp AS (SELECT COALESCE(NULLIF(''@medicalHstInfo.diseaseDate'', ''''),
                                               TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')) AS disease_date)
   , disease_date_info AS (SELECT SUBSTR(disease_date, 1, 8) AS disease_date
                                , SUBSTR(disease_date, 1, 4) AS disease_year
                                , SUBSTR(disease_date, 5, 2) AS disease_month
                                , SUBSTR(disease_date, 7, 2) AS disease_day
                           FROM disease_date_info_tmp
                           WHERE (SELECT up_disease_date_flg FROM up_disease_date_flg_info) = ''0''
                           UNION
                           SELECT null AS disease_date
                                , null AS disease_year
                                , null AS disease_month
                                , null AS disease_day
                           WHERE (SELECT up_disease_date_flg FROM up_disease_date_flg_info) != ''0'')
   , data_exists_info AS (SELECT 1   AS order_no
                               , ''1'' AS exists_flag
                          FROM pat_unique patu
                                   CROSS JOIN LATERAL json_array_elements(patu.medical_hst_info :: json) AS info
                          WHERE pat_id = @patId
                            AND facility_cd = ''@facilityCd''
                            AND is_del = ''0''
                            AND (info ->> ''disease_cd'' ::TEXT) = (''@medicalHstInfo.diseaseCd'' ::TEXT)
                            AND (''@medicalHstInfo.diseaseCd'' ::TEXT) != ''''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS exists_flag
                          ORDER BY order_no ASC
                          LIMIT 1)
   , data_info AS (SELECT 0                           AS order_no,
                          null                        AS memo,
                          null                        AS ctl_no,
                          null                        AS die_date,
                          null                        AS out_come,
                          null                        AS course_cd,
                          ''0''                         AS is_notice,
                          ''@medicalHstInfo.diseaseCd'' AS disease_cd,
                          ''0''                         AS disp_order,
                          disease_day,
                          NULLIF(''@facilityCd'', '''')   AS facility_cd,
                          disease_date,
                          disease_year,
                          ''0''                         AS is_diagnosed,
                          null                        AS diagnosis_day,
                          disease_month,
                          null                        AS out_come_date,
                          ''0''                         AS course_is_free,
                          null                        AS diagnosis_date,
                          null                        AS diagnosis_year,
                          null                        AS diagnosis_month,
                          ''0''                         AS is_main_disease,
                          null                        AS diagnostician_cd,
                          null                        AS diagnosis_facility_cd,
                          ''0''                         AS diagnostician_is_free,
                          ''0''                         AS is_confirmation_biopsy,
                          ''0''                         AS diagnosis_facility_is_free,
                          ''1''                         AS is_dialysis_underlying_disease
                   FROM disease_date_info
                   WHERE (SELECT exists_flag FROM data_exists_info) = ''0''
                     AND (''@medicalHstInfo.diseaseCd'' ::TEXT) != ''''
                   UNION
                   SELECT 1                                     AS order_no,
                          info ->> ''memo''                       AS memo,
                          info ->> ''ctl_no''                     AS ctl_no,
                          info ->> ''die_date''                   AS die_date,
                          info ->> ''out_come''                   AS out_come,
                          info ->> ''course_cd''                  AS course_cd,
                          info ->> ''is_notice''                  AS is_notice,
                          info ->> ''disease_cd''                 AS disease_cd,
                          info ->> ''disp_order''                 AS disp_order,
                          info ->> ''disease_day''                AS disease_day,
                          info ->> ''facility_cd''                AS facility_cd,
                          info ->> ''disease_date''               AS disease_date,
                          info ->> ''disease_year''               AS disease_year,
                          info ->> ''is_diagnosed''               AS is_diagnosed,
                          info ->> ''diagnosis_day''              AS diagnosis_day,
                          info ->> ''disease_month''              AS disease_month,
                          info ->> ''out_come_date''              AS out_come_date,
                          info ->> ''course_is_free''             AS course_is_free,
                          info ->> ''diagnosis_date''             AS diagnosis_date,
                          info ->> ''diagnosis_year''             AS diagnosis_year,
                          info ->> ''diagnosis_month''            AS diagnosis_month,
                          info ->> ''is_main_disease''            AS is_main_disease,
                          info ->> ''diagnostician_cd''           AS diagnostician_cd,
                          info ->> ''diagnosis_facility_cd''      AS diagnosis_facility_cd,
                          info ->> ''diagnostician_is_free''      AS diagnostician_is_free,
                          info ->> ''is_confirmation_biopsy''     AS is_confirmation_biopsy,
                          info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free,
                          CASE
                              WHEN new_data.disease_cd IS NULL
                                  THEN ''0''
                              ELSE ''1''
                              END                               AS is_dialysis_underlying_disease
                   FROM pat_unique patu
                            CROSS JOIN LATERAL json_array_elements(patu.medical_hst_info :: json) AS info
                            LEFT JOIN (SELECT ''@medicalHstInfo.diseaseCd'' ::TEXT AS disease_cd) AS new_data
                                      ON new_data.disease_cd = (info ->> ''disease_cd''::TEXT) AND
                                         (''@medicalHstInfo.diseaseCd'' ::TEXT) != ''''
                   WHERE pat_id = @patId
                     AND facility_cd = ''@facilityCd''
                     AND is_del = ''0''
                   ORDER BY order_no DESC, ctl_no ASC)
   , json_data AS (SELECT json_build_object(
                                  ''memo'', memo,
                                  ''ctl_no'', row_number() over (order by order_no DESC, ctl_no ASC),
                                  ''die_date'', die_date,
                                  ''out_come'', out_come,
                                  ''course_cd'', (course_cd :: INTEGER),
                                  ''is_notice'', is_notice,
                                  ''disease_cd'', (disease_cd :: INTEGER),
                                  ''disp_order'', row_number() over (order by order_no DESC, ctl_no ASC),
                                  ''disease_day'', disease_day,
                                  ''facility_cd'', facility_cd,
                                  ''disease_date'', disease_date,
                                  ''disease_year'', disease_year,
                                  ''is_diagnosed'', is_diagnosed,
                                  ''diagnosis_day'', diagnosis_day,
                                  ''disease_month'', disease_month,
                                  ''out_come_date'', out_come_date,
                                  ''course_is_free'', course_is_free,
                                  ''diagnosis_date'', diagnosis_date,
                                  ''diagnosis_year'', diagnosis_year,
                                  ''diagnosis_month'', diagnosis_month,
                                  ''is_main_disease'', is_main_disease,
                                  ''diagnostician_cd'', (diagnostician_cd :: INTEGER),
                                  ''diagnosis_facility_cd'', diagnosis_facility_cd,
                                  ''diagnostician_is_free'', diagnostician_is_free,
                                  ''is_confirmation_biopsy'', is_confirmation_biopsy,
                                  ''diagnosis_facility_is_free'', diagnosis_facility_is_free,
                                  ''is_dialysis_underlying_disease'', is_dialysis_underlying_disease) AS new_data
                   FROM data_info)
UPDATE pat_unique
SET medical_hst_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date          = CURRENT_TIMESTAMP
WHERE pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND (select (case when up_base_disease_flg = ''0'' then true else false end) from up_base_disease_flg_info)', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の初回申し込み→既往歴情報(原疾患登録)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
