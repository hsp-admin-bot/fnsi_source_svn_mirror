DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1107000,-1107008);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107000, 'WITH
journal_base AS (
  SELECT
    scj.ctl_no,
    scj.ord_no
  FROM sys_coop_journal AS scj
  WHERE scj.ctl_no = @ctlNo::INT
  LIMIT 1
),
datetime_params AS (
  SELECT
    j.ord_no
  FROM journal_base AS j
),
coop_settings_common AS (
  SELECT
    MAX(CASE WHEN info ->> ''key2'' = ''HOSPITAL_ID''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS hospital_id,
    MAX(CASE WHEN info ->> ''key2'' = ''PATID_LEN''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS patient_id_digits
  FROM mst_coop_ini AS ini
       ,LATERAL json_array_elements(ini.coop_ini_info::JSON) AS info
  WHERE ini.facility_cd = @facilityCd
    AND ini.is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''is_effect'' = ''1''
),
content_raw AS (
  SELECT  e ->> ''treatment_start_date''  AS treatment_start_date,
          e ->> ''created_user_id''    AS created_user_id
  FROM    jsonb_array_elements(@content::jsonb) e
),
coop_settings_ind_change_log AS (
  SELECT
    MAX(CASE WHEN info ->> ''key2'' = ''USER_ID_FLAG''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS user_id_flag,
    MAX(CASE WHEN info ->> ''key2'' = ''DEFAULT_DOCTOR''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS default_doctor_id,
    MAX(CASE WHEN info ->> ''key2'' = ''XX_TYPE_CODE''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS xx_class,
    MAX(CASE WHEN info ->> ''key2'' = ''COURSE_CD1''
             THEN COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'') END) AS dept_code
  FROM mst_coop_ini AS ini
       ,LATERAL json_array_elements(ini.coop_ini_info::JSON) AS info
  WHERE ini.facility_cd = @facilityCd
    AND ini.is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SCM_IND_CHANGE_LOG''
    AND info ->> ''is_effect'' = ''1''
),
base_data AS (
  SELECT
    pm.charge_staff_info,
    pm.pat_id,
    cr.created_user_id AS up_ind_user_id,
    cr.treatment_start_date AS treat_date
  FROM pat_main AS pm
       CROSS JOIN datetime_params AS dt
       CROSS JOIN content_raw AS cr
  WHERE pm.pat_id = @patId
    AND pm.is_del = ''0''
  LIMIT 1
),
main_doctors AS (
  SELECT
    b.pat_id,
    ROW_NUMBER() OVER (PARTITION BY b.pat_id ORDER BY (elem ->> ''ctl_no'')::INT) AS rn,
    elem ->> ''staff_cd'' AS staff_cd
  FROM base_data AS b
       ,jsonb_array_elements(b.charge_staff_info) AS elem
  WHERE b.charge_staff_info IS NOT NULL
    AND jsonb_typeof(b.charge_staff_info) = ''array''
    AND elem ->> ''is_main'' = ''1''
),

doctor_ids AS (
  SELECT
    pat_id,
    MAX(CASE WHEN rn = 1 THEN staff_cd END) AS doctor1_staff_cd,
    MAX(CASE WHEN rn = 2 THEN staff_cd END) AS doctor2_staff_cd
  FROM main_doctors
  GROUP BY pat_id
),
user_id_calc AS (
  SELECT
    calc.raw_user_id       AS user_id,
    calc.default_doctor_fl AS default_doctor_flag
  FROM (
    SELECT
      CASE
        WHEN s_log.user_id_flag = ''1'' THEN
             COALESCE(d.doctor1_staff_cd,
                      d.doctor2_staff_cd,
                      s_log.default_doctor_id)
        WHEN s_log.user_id_flag = ''0'' THEN
             b.up_ind_user_id::TEXT
        ELSE NULL
      END AS raw_user_id,
      CASE
        WHEN s_log.user_id_flag = ''1''
             AND d.doctor1_staff_cd IS NULL
             AND d.doctor2_staff_cd IS NULL
        THEN ''1''
        ELSE ''0''
      END AS default_doctor_fl
    FROM base_data                      AS b
         INNER JOIN coop_settings_ind_change_log AS s_log ON TRUE
         LEFT  JOIN doctor_ids          AS d ON b.pat_id = d.pat_id
  ) AS calc
)
SELECT
  LPAD(s_common.hospital_id, 6, ''0'')                                                     AS hospital_id,
  LPAD(@hosp_pat_id,
       COALESCE(s_common.patient_id_digits::INT, 12),
       ''0'')                                                                               AS patient_id,
  u.user_id                                                                              AS user_id,
  u.default_doctor_flag::CHAR(1)                                                         AS default_doctor_flag,
  ''5''::CHAR(1)                                                                           AS index_class,
  LPAD(s_log.xx_class, 2, ''0'')                                                           AS xx_class,
  NULL::VARCHAR(60)                                                                      AS title,
  LPAD(s_log.dept_code, 2, ''0'')                                                          AS dept_code,
  ''000''::CHAR(3)                                                                         AS office_code,
  CASE CAST(@in_out_class AS INTEGER)
       WHEN 0 THEN ''1''
       WHEN 1 THEN ''2''
       ELSE ''1''
  END::CHAR(1)                                                                           AS in_out_class,
  TO_DATE(b.treat_date, ''YYYYMMDD'')                                                      AS execution_date,
  NULL AS unused_13,
  NULL AS unused_14,
  ''0''::CHAR(1)                                                                           AS cancel_flag,
  NULL::DATE                                                                             AS cancel_date,
  NULL::CHAR(8)                                                                          AS cancel_time,
  NULL::CHAR(6)                                                                          AS cancel_user,
  ''0''::CHAR(1)                                                                           AS post_entry_flag,
  ''@karte_record_text''::TEXT                                                             AS karte_record_text
FROM base_data                           AS b
     CROSS JOIN datetime_params          AS dt
     CROSS JOIN coop_settings_common     AS s_common
     CROSS JOIN coop_settings_ind_change_log AS s_log
     LEFT JOIN user_id_calc              AS u ON TRUE;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコム　指示変更履歴連携', current_timestamp, current_timestamp, '[{"sql_cd": -1107001, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}, {"sql_cd": -1107001, "field_name": "in_out_class", "replace_var": "@in_out_class"}, {"sql_cd": -1107008, "field_name": ["treatment_start_date", "created_user_id"], "replace_var": "content"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107008, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd",
    "log_date": "@ordNo"
  },
  "sort": {
    "log_date": "asc"
  },
  "slice": {
    "log_date": 0
  }
}', 4, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　指示変更履歴　カルテ記録 ヘッダ用データ取得', current_timestamp, current_timestamp, NULL);
