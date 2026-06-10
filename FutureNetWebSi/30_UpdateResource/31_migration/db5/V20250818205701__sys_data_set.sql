DELETE FROM sys_data_set WHERE sql_cd IN (-1108000,-1107007,-1107006,-1107004,-1107003,-1107002,-1107001,-1107000,-1106008,-1106007,-1106006,-1106000,-1105005,-1105004,-1105001,-1105000,-1104004,-1104001,-1104000,-1103022,-1103020,-1103016,-1103000,-1102031,-1102029,-1102012,-1102010,-1102004,-1102002,-1102001,-1102000,-1101508,-1101507,-1101506,-1101505,-1101504,-1101503,-1101502,-1101501,-1101008,-1101005,-1101004,-1101003,-1101002,-1101001,-1101000,-1100014,-1100006,-1100005,-1100003,-1100000);

INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1108000, E'WITH
journal_base AS (
    SELECT
        scj.crud
    FROM
        sys_coop_journal AS scj
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
    LIMIT 1
),
ord AS (
    SELECT
            ord.rst_in_out_class,
            ord.treat_date
    FROM
            ord_main AS ord
    WHERE
            ord.ord_no = @ordNo
        AND ord.facility_cd = @facilityCd
),
get_coop_ini AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''is_effect'' = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
            AND info ->> ''key1'' = ''SCM_REPORT_SEND''
            AND info ->> ''key2'' IN (
                ''COURSE_CODE'', ''DOCUMENT_CATEGORY'', ''DOCUMENT_TITLE'', ''DISPLAY_SIZE_CLASS''
            )
),
memo AS(
SELECT 
  COALESCE(save_2 ->> ''memo'', '''') AS file_name
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo::text
  AND save_2 ->> ''coop_cd'' = ''rep_dial''
  AND facility_cd = @facilityCd
  AND pat_id = @patId
  ORDER BY pat_coop_detail.up_date DESC
  LIMIT 1
)
SELECT
    CASE
        crud
WHEN ''D'' THEN regexp_replace((SELECT file_name FROM memo), ''\\.pdf$'', ''.delete'')
        WHEN ''C'' THEN
CONCAT(
    LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text,
    (SELECT TO_CHAR(treat_date::DATE, ''yymmdd'') FROM ord),
    RPAD(COALESCE(LEFT((SELECT value FROM get_coop_ini WHERE key2 = ''COURSE_CODE''), 2), ''''), 2, '' ''),
    RPAD(COALESCE(LEFT((SELECT value FROM get_coop_ini WHERE key2 = ''DOCUMENT_CATEGORY''), 2), ''''), 2, '' ''),
    RPAD(COALESCE(LEFT((SELECT value FROM get_coop_ini WHERE key2 = ''DOCUMENT_TITLE''), 3), ''''), 3, '' ''),
    ''0'',
    (SELECT value FROM get_coop_ini WHERE key2 = ''DISPLAY_SIZE_CLASS''),
    CASE (SELECT rst_in_out_class FROM ord)
    WHEN ''1'' THEN ''2'' -- 入院
    ELSE ''1'' -- 外来
    END,
    TO_CHAR(CURRENT_TIMESTAMP, ''yyyyMMddHHmmssMS''),
''.pdf''
)
    END AS filename
FROM
    journal_base', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコム　レポート連携 PDFファイル名取得', '2025-07-30 01:19:21.728', CURRENT_TIMESTAMP, '[{"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107007, 'SELECT
  RIGHT(
    CASE
      WHEN COALESCE(@defaultDoctorFlag, ''0'') = ''1''
        THEN NULLIF(@staffCd, '''')
      ELSE COALESCE(
             (
               SELECT disp_user_id
               FROM   mst_user_authentication
               WHERE  user_id     = NULLIF(@staffCd, '''')::INT
                 AND  facility_cd = @facilityCd
               LIMIT 1
             ),
             ''''
           )
    END,
    6
  ) AS disp_user_id;
', '1', '[]', '0', '{"applications": [4]}', NULL, 'セコム　指示変更履歴　ユーザID取得', '2025-06-22 20:19:53.113', CURRENT_TIMESTAMP, '[{"sql_cd": -1107000, "field_name": "user_id", "replace_var": "@staffCd"}, {"sql_cd": -1107000, "field_name": "default_doctor_flag", "replace_var": "@defaultDoctorFlag"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107006, 'SELECT
  TO_CHAR(reg_date, ''YYYYMMDDHH24MISSMS'') AS reg_date
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo;', '2', '[]', '0', '{"applications": [4]}', NULL, 'セコム　指示変更履歴 reg_date取得', '2025-06-16 02:18:28.215', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107004, E'WITH not_send_items AS (
  SELECT COALESCE(
           string_to_array(
             (SELECT COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'')
              FROM   mst_coop_ini ini
                     CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
              WHERE  facility_cd      = @facilityCd
                AND  ini.is_del       = ''0''
                AND  info ->> ''key0''  = @key0
                AND  info ->> ''key1''  = ''SCM_IND_CHANGE_LOG''
                AND  info ->> ''key2''  = ''NOT_SEND_ITEM_ID''
                AND  info ->> ''is_effect'' = ''1''
              LIMIT 1),
             '',''), ''{}'')::int[] AS ids
),
content_raw AS (
  SELECT  (e ->> ''sort_no'')::int        AS sort_no,
          e ->> ''log_target''            AS log_target,
          e ->> ''log_date''              AS log_date,
          e ->> ''treatment_weekday''     AS treatment_weekday,
          e ->> ''treatment_method''      AS treatment_method,
          e ->> ''treatment_course''      AS treatment_course,
          e ->> ''log_class''             AS log_class,
          e ->> ''log_content''           AS log_content,
          e ->> ''treatment_start_date''  AS treatment_start_date,
          e ->> ''treatment_end_date''    AS treatment_end_date
  FROM    jsonb_array_elements(@content::jsonb) e
),
sort_map(sort_no, seq, item_id) AS (
  VALUES
    ( 10,  2,  0 ), ( 20,  3, 10 ), ( 30,  4,  1 ), ( 40,  5,  3 ),
    ( 50,  6,  4 ), ( 60,  7,  5 ), ( 70,  8,  2 ), ( 80,  9,  7 ),
    ( 90, 10,  6 ), (100, 11,  9 ), (110, 12,  8 ), (120, 13, 11 ),
    (130, 14, 12 ), (140, 15, 13 ), (150, 16, 14 ), (160, 17, 44 ),
    (170, 18, 45 ), (180, 19, 46 ), (190, 20, 40 ), (200, 21, 47 ),
    (210, 22, 15 ), (220, 23, 30 ), (230, 24, 31 ), (240, 25, 32 ),
    (250, 26, 33 ), (260, 27, 34 ), (270, 28, 35 ), (280, 29, 36 ),
    (290, 30, 37 ), (300, 31, 38 ), (310, 32, 39 ), (320, 33, 16 ),
    (330, 34, 17 ), (340, 35, 18 ), (350, 36, 19 ), (360, 37, 20 ),
    (370, 38, 21 ), (380, 39, 25 ), (390, 40, 22 ), (400, 41, 23 ),
    (410, 42, 24 ), (420, 43, 26 ), (430, 44, 27 ), (440, 45, 28 ),
    (450, 46, 29 ), (460, 47, 42 ), (470, 48, 41 ), (480, 49, 43 )
),
ranked AS (
  SELECT cr.*,
         ROW_NUMBER() OVER (PARTITION BY cr.sort_no ORDER BY cr.log_target) AS rn
  FROM   content_raw cr
),
header_parts AS (
  (
    SELECT 0 AS seq,
           0 AS item_id,
           (
             CASE
               WHEN cr.treatment_weekday IS NULL OR cr.treatment_weekday = ''''
                 THEN ''''
               ELSE ''曜日：'' || cr.treatment_weekday || '' ''
             END
           ) ||
           ''変更対象治療方法：'' || COALESCE(cr.treatment_method, '''') ||
           '' 変更対象クール：''  || COALESCE(cr.treatment_course, '''') || '' ('' ||
           TO_CHAR(
             CASE
               WHEN LENGTH(cr.treatment_start_date) = 8 THEN to_date(cr.treatment_start_date, ''YYYYMMDD'')
               WHEN LENGTH(cr.treatment_start_date) = 10 THEN to_date(cr.treatment_start_date, ''YYYY-MM-DD'')
               WHEN LENGTH(cr.treatment_start_date) >= 19 AND SUBSTR(cr.treatment_start_date, 5, 1) = ''-''
                 THEN to_date(SUBSTR(cr.treatment_start_date, 1, 10), ''YYYY-MM-DD'')
               ELSE NULL
             END,
             ''YYYY/MM/DD''
           ) ||
           CASE
             WHEN cr.treatment_end_date IN ('''', ''99991231'', ''9999-12-31'') OR cr.treatment_end_date IS NULL
               THEN ''''
             ELSE '' '' || U&''\\FF5E'' || '' '' ||
                  TO_CHAR(
                    CASE
                      WHEN LENGTH(cr.treatment_end_date) = 8 THEN to_date(cr.treatment_end_date, ''YYYYMMDD'')
                      WHEN LENGTH(cr.treatment_end_date) = 10 THEN to_date(cr.treatment_end_date, ''YYYY-MM-DD'')
                      WHEN LENGTH(cr.treatment_end_date) >= 19 AND SUBSTR(cr.treatment_end_date, 5, 1) = ''-''
                        THEN to_date(SUBSTR(cr.treatment_end_date, 1, 10), ''YYYY-MM-DD'')
                      ELSE NULL
                    END,
                    ''YYYY/MM/DD''
                  )
           END || '')'' || CHR(10) AS part,
           TRUE AS is_header
    FROM   content_raw cr
    ORDER  BY sort_no
    LIMIT  1
  )
  UNION ALL
  SELECT 1, 0, ''----------------------------------------------------------------'' || CHR(10), TRUE
),
detail_body AS (
  SELECT
    m.seq + r.rn * 0.01                     AS seq_adj,
    m.item_id,
    r.log_target ||
    repeat('' '',
           GREATEST(0, 22 - (
             length(r.log_target) +
             length(regexp_replace(r.log_target,''[\\x01-\\x7E\\｡-ﾟ]'','''',''g''))
           ))) ||
    ''：'' ||
    regexp_replace(
      r.log_content,
      E''\\r?\\n'',
      CHR(10) || repeat('' '',24),
      ''g''
    ) ||
    CHR(10)                                  AS part,
    FALSE                                     AS is_header
  FROM   ranked r
  JOIN   sort_map m USING(sort_no)
  WHERE  COALESCE(r.log_target,'''') <> ''''
),
log_parts_raw AS (
  SELECT seq,     item_id, part, is_header FROM header_parts
  UNION ALL
  SELECT seq_adj, item_id, part, is_header FROM detail_body
),
log_parts AS (
  SELECT p.seq, p.item_id, p.part, p.is_header
  FROM   log_parts_raw p
  JOIN   not_send_items n ON TRUE
  WHERE  p.item_id = 0
     OR  NOT (p.item_id = ANY(n.ids))
),
detail_exists AS (
  SELECT 1
  FROM   log_parts
  WHERE  is_header = FALSE
  LIMIT  1
)
SELECT RTRIM(string_agg(part, '''' ORDER BY seq), CHR(10)) AS karte_text
FROM   log_parts
JOIN   detail_exists ON TRUE;
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコム　指示変更履歴連携_カルテ記録テキスト取得', '2025-06-08 20:39:48.343', CURRENT_TIMESTAMP, '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107003, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd",
    "log_date": "@latest_log_date"
  },
  "sort": {
    "log_date": "desc"
  }
}', '4', '[]', '0', '{"applications": [4]}', NULL, 'セコム　指示変更履歴　カルテ記録 データ取得', '2025-06-10 22:07:37.298', CURRENT_TIMESTAMP, '[{"sql_cd": -1107002, "field_name": "log_date", "replace_var": "latest_log_date"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107002, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd"
  },
  "lt": {
    "log_date": "@reg_date"
  },
  "sort": {
    "log_date": "desc"
  }
}', '4', '[]', '0', '{"applications": [4]}', NULL, 'セコム　指示変更履歴　カルテ記録 最新log_date取得', '2025-06-10 22:07:37.298', CURRENT_TIMESTAMP, '[{"sql_cd": -1107006, "field_name": "reg_date", "replace_var": "reg_date"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107001, 'SELECT
    hosp_pat_id,
    in_out_class
FROM
    ntss.pat_personal_main
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND is_del = ''0'';', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコム　指示変更履歴連携', '2025-06-08 20:39:48.343', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107000, 'WITH
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
ord_main_max AS (
  (
    SELECT
      ord.ord_no,
      ord.pat_id,
      ord.up_ind_user_id,
      ord.treat_date,
      ord.del_date                    AS up_date
    FROM
      ord_main_restore  AS ord
      INNER JOIN datetime_params dt         ON ord.ord_no = dt.ord_no
      INNER JOIN sys_coop_journal journal   ON journal.ctl_no = @ctlNo
                                           AND journal.ord_no = dt.ord_no
    WHERE journal.reg_date >= ord.del_date
    ORDER BY ord.del_date DESC
    LIMIT 1
  )
  UNION
  (
    SELECT
      ord.ord_no,
      ord.pat_id,
      ord.up_ind_user_id,
      ord.treat_date,
      ord.rst_edition_date            AS up_date
    FROM
      ord_main            AS ord
      INNER JOIN datetime_params dt ON ord.ord_no = dt.ord_no
  )
  ORDER BY up_date DESC NULLS LAST
  LIMIT 1
),
base_data AS (
  SELECT
    pm.charge_staff_info,
    pm.pat_id,
    om.up_ind_user_id,
    om.treat_date
  FROM pat_main AS pm
       CROSS JOIN datetime_params AS dt
       INNER JOIN ord_main_max    AS om ON om.ord_no = dt.ord_no
  WHERE pm.pat_id = om.pat_id
    AND pm.pat_id = @patId
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
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコム　指示変更履歴連携', '2025-06-08 20:39:48.343', CURRENT_TIMESTAMP, '[{"sql_cd": -1107001, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}, {"sql_cd": -1107001, "field_name": "in_out_class", "replace_var": "@in_out_class"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106008, E'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
    t.part AS data
    , split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 7) as part_cd
    , split_part(t.part, '','', 8) as mod_cd
    , split_part(t.part, '','', 9) as direction_cd
    , split_part(t.part, '','', 10) as procedure_cd
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 6', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106007, E'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
      split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 4', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106006, E'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = ''rad_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result = ''9''
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
      split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 8) as title
    , split_part(t.part, '','', 9) as course_cd2
    , split_part(t.part, '','', 11) as in_out_class
    , split_part(t.part, '','', 12) as reg_rad_date
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 2', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携_削除', '2025-07-15 20:55:07.818', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106000, 'with coop_ini_info AS (
--連携設定より取得
select
    coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
    info ->> ''key1'' AS key1,
    info ->> ''key2'' AS key2
from
    mst_coop_ini AS ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
    facility_cd = @facilityCd
    and is_del = ''0''
    and coalesce(info ->> ''key0'', '''') = @key0
    and info ->> ''key1'' in (
        ''SCM_COMMON'',
        ''SCM_XRAY_ORDER_SEND''
    )
)
,
user_list AS (
--利用者マスタ取得(pre_sqlにて取得)
select
    auth_info ->> ''user_id'' AS user_id,
    auth_info ->> ''disp_user_id'' AS disp_user_id
from
    json_array_elements(@userList::json) auth_info
)
,
staff_cd_list AS (
--患者基本情報
select
    user_list.disp_user_id AS disp_user_id,
    row_number() over(order by staff_info ->> ''disp_order'') AS row_no
from
    pat_main pm
cross join jsonb_array_elements(pm.charge_staff_info) AS staff_info
left join user_list on
    staff_info ->> ''staff_cd'' = user_list.user_id
where
    pm.facility_cd = @facilityCd
    and pm.pat_id = @patId
    and pm.is_del = ''0''
    and staff_info ->> ''is_main'' = ''1''
)
, rad_set_info AS (
-- 患者放射線検査DB
select
    info ->> ''rad_set_cd'' AS rad_set_cd,
    to_char(prm.reg_rad_date, ''YYYY-MM-DD'') AS reg_rad_date,
    prm.ind_user_id
from 
    pat_rad_main prm
cross join lateral json_array_elements(prm.order_rad_set_info::json) info
where
    prm.pat_id = @patId
    and prm.facility_cd = @facilityCd
    and prm.is_del = ''0''
    and prm.rad_result_cd = @ordNo
)
,
rad_item_info AS (
--放射線検査セットマスタ
select
    CASE item_info ->> ''item_class''
      WHEN ''部位'' THEN RIGHT(item_info ->> ''item_cd'', 4)
      ELSE RPAD(
             RIGHT(item_info ->> ''item_cd'', 3)
           , 3, '' '')
    END AS item_cd,
    item_info ->> ''item_class'' AS item_class,
    rad_set_info.reg_rad_date,
    rad_set_info.ind_user_id,
    ROW_NUMBER() OVER (PARTITION BY item_info ->> ''item_class'' ORDER BY (item_info ->> ''ctl_no'')::INT ASC) AS rn
from
    mst_rad_set mrs
cross join lateral json_array_elements(mrs.rad_item_info::json) item_info
join rad_set_info on
    (rad_set_info.rad_set_cd)::integer = mrs.rad_set_cd
where
    mrs.facility_cd = @facilityCd
    and mrs.is_del = ''0''
    AND COALESCE(item_info ->> ''item_cd'', '''') <> ''''
    AND item_info ->> ''item_class'' IN (''部位'', ''修飾'', ''方向'', ''手技'')
),
filtered5 AS (
  SELECT item_cd
       , item_class
  FROM rad_item_info
  WHERE rn <= 5
  AND item_class IN (''修飾'', ''方向'', ''手技'')
)
select
    case
        (select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''USER_ID_FLAG'')
        when ''1'' then (
        --担当医の出力条件
            right(coalesce(
                (select disp_user_id from staff_cd_list where row_no = 1),
                (select disp_user_id from staff_cd_list where row_no = 2),
                (select value from coop_ini_info where key1 = ''SCM_COMMON'' and key2 = ''DEFAULT_DOCTOR''),
                ''''), 6)
            )
        when ''0'' then (
            right(coalesce(
                (select user_list.disp_user_id
                 from   user_list
                 where  user_list.user_id = rii.ind_user_id::text
                 limit  1),
                ''''), 6)
        )
    end AS user_id,
    (select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''XRAY_IDX_TITLE'') AS title,
    rii.reg_rad_date AS reg_rad_date,
    (select item_cd from rad_item_info where item_class = ''部位'' AND rn = 1) AS part_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''修飾'') AS mod_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''方向'') AS direction_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''手技'') AS procedure_cd
from
rad_item_info rii
limit 1
;', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携', '2025-06-19 10:57:08.819', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105005, E'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud IN (''C'',''U'')
    AND ord_no = @ordNo
    AND coop_cd = ''exam_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result IN (''9'',''8'',''1'',''0'')
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
    t.part AS data
    , split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 22) as exam_set_cnt
    , split_part(t.part, '','', 23) as item_in_hospital_cd
    , split_part(t.part, '','', 24) as exam_timing_flag
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 4', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携_削除', '2025-08-14 10:44:29.553', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105004, E'WITH dump_text AS (
SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud IN (''C'',''U'')
    AND ord_no = @ordNo
    AND coop_cd = ''exam_ord''
    AND key0 = @key0
    AND ana_result = ''9''
    AND coop_result IN (''9'',''8'',''1'',''0'')
    ORDER BY scj.up_date DESC
LIMIT 1
)
SELECT
    t.part AS data
    , split_part(t.part, '','', 1) as hospital_id
    , split_part(t.part, '','', 2) as hosp_pat_id
    , split_part(t.part, '','', 3) as occur_date
    , split_part(t.part, '','', 4) as occur_time
    , split_part(t.part, '','', 5) as user_id
    , split_part(t.part, '','', 8) as title
    , split_part(t.part, '','', 9) as course_cd2
    , split_part(t.part, '','', 11) as in_out_class
    , split_part(t.part, '','', 12) as reg_exam_date
    , split_part(t.part, '','', 13) as reg_exam_date
FROM dump_text
CROSS JOIN LATERAL regexp_split_to_table(dump_text.dump_text, ''\\n'') WITH ordinality AS t(part, idx)
WHERE t.idx = 2', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携_削除', '2025-08-14 10:44:29.553', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105001, 'WITH in_hosp_code AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_data AS (
    SELECT
        t.set_info ->> ''set_cd'' AS set_cd
        , t.idx AS set_idx
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) WITH ordinality AS t(set_info, idx)
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
)
, item_count AS (
    --検査セットの院内コードがS始まりの場合取得
    SELECT
        1 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
    WHERE
        LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
    UNION ALL
    --検査項目数を取得
    SELECT
        2 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mei.in_hospital_cd1
            WHEN 2 THEN mei.in_hospital_cd2
            WHEN 3 THEN mei.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
)
, limit_item AS (
    SELECT
        item_in_hospital_cd AS item_in_hospital_cd
    FROM
        item_count
    ORDER BY
        set_idx,
        item_sort_no,
        item_in_hospital_cd
    LIMIT 250
)
SELECT string_agg(RPAD(LEFT(item_in_hospital_cd, 8), 8, '' ''), '''') AS item_in_hospital_cd
FROM limit_item', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携', '2025-06-19 11:08:16.281', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105000, 'WITH exam_data AS(
  --登録時検査日時と透析前後フラグの取得
    SELECT
    CASE reg_order_class
        WHEN ''1'' THEN ''1''
        WHEN ''2'' THEN ''2''
        ELSE ''0''
    END AS exam_timing_flag,
    to_char(reg_exam_date, ''YYYY-MM-DD'') as reg_exam_date
    FROM
        ntss.pat_exam_main
    WHERE
        exam_main_cd = @ordNo
        AND facility_cd = @facilityCd
    limit 1
)
, coop_ini_info AS (
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
            ''SCM_EXAM_ORDER_SEND'',
            ''SCM_COMMON''
        ) 
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
, exam_staff_cd AS (
  --指示者の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        pat_exam_main pem
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        pem.ind_user_id = (users ->> ''user_id'')::numeric
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
)
, in_hosp_code AS (
    --検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_set_count AS (
  --項目数の取得（250まで）
    SELECT --検査項目
        1
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) AS set_info
        LEFT JOIN mst_exam_set mes ON set_info ->> ''set_cd'' = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
        AND NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
    UNION ALL
    SELECT --検査セット
        1
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) AS set_info
        LEFT JOIN mst_exam_set mes ON set_info ->> ''set_cd'' = mes.exam_set_cd::text
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
        AND LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
    LIMIT 250
)
, get_title AS (
    SELECT
        value
        , (
            SELECT MAX(i)
            FROM generate_series(1, char_length(value)) AS i
            WHERE octet_length(CONVERT(substring(value FROM 1 FOR i)::bytea, ''UTF8'', ''SJIS'')::bytea) <= 60
            )  AS cut_index
    FROM coop_ini_info
    WHERE
        key1 = ''SCM_EXAM_ORDER_SEND''
        AND key2 = ''EXAM_IDX_TITLE''
)
, title_limited AS (
    SELECT
        substring(value FROM 1 FOR cut_index) AS value
    FROM get_title
)
SELECT
    exam_timing_flag,
    reg_exam_date,
    (SELECT value FROM title_limited) AS title,
    (SELECT COUNT(*) FROM exam_set_count) AS exam_set_cnt,
    RIGHT(
        case (SELECT value::numeric FROM coop_ini_info WHERE key1 = ''SCM_EXAM_ORDER_SEND'' AND key2 = ''USER_ID_FLAG'')
        when 0 then 
            (select disp_user_id from exam_staff_cd)
        when 1 then 
            coalesce(
            (select disp_user_id from staff_cd_list where row_no = 1),
            (select disp_user_id from staff_cd_list where row_no = 2),
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR''),
            ''''
            )
        end
    ,6) as user_id
FROM
    exam_data', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携', '2025-07-17 09:48:31.871', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104004, '-- SQL: -1104004 begin
WITH staff_candidates AS (
  SELECT (elem ->> ''staff_cd'')::int AS staff_cd,
         (elem ->> ''disp_order'')::int AS disp_order
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(charge_staff_info) AS elem
  WHERE pat_id = @patId
    AND elem ->> ''is_main'' = ''1''
  ORDER BY (elem ->> ''disp_order'')::int ASC
  LIMIT 2
)
,ranked_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 0
)
,fallback_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 1
)
,ini AS (
  SELECT COALESCE(NULLIF(info ->> ''value'',''''), NULLIF(info ->> ''default_v'',''''), '''') AS default_staff_cd
  FROM MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
,ini_hosp_cd AS (
  SELECT COALESCE(NULLIF(info ->> ''value'',''''), NULLIF(info ->> ''default_v'',''''), '''') AS hosp_cd_1_2
  FROM MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''key2'' = ''IN_HOSP_CD''
)
,selected_staff AS (
  SELECT COALESCE(
           (SELECT staff_cd::text FROM ranked_staff),
           (SELECT staff_cd::text FROM fallback_staff),
           (SELECT default_staff_cd FROM ini)
         ) AS reserved_by_user_id
)
,user_auth_list AS (
  SELECT (auth_elem ->> ''user_id'')::int AS user_id,
         auth_elem ->> ''disp_user_id''      AS disp_user_id
  FROM jsonb_array_elements(@userList::jsonb) AS auth_elem
)
, ini_user AS (
  SELECT u.user_id::text AS ini_user_id
  FROM ini
  CROSS JOIN user_auth_list u
  WHERE u.disp_user_id = ini.default_staff_cd
  LIMIT 1
),
final AS (
  SELECT
    s.reserved_by_user_id::text AS reserved_by_user_id,
    -- 3つ目に「ini で指定された default_staff_cd を user_id に変換したもの」
    to_jsonb(ARRAY[
      r.staff_cd::text,
      f.staff_cd::text,
      (SELECT ini_user_id FROM ini_user)  -- 見つからなければ NULL
    ])::text AS charge_user_id_json,

    CASE
      WHEN LENGTH(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      '')) >= 7
        THEN RIGHT(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6)
      ELSE LPAD(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6, '' '')
    END AS disp_user_id,
    u.disp_user_id AS raw_disp_user_id,
    hosp_cd_1_2
  FROM selected_staff s
  LEFT JOIN user_auth_list u ON s.reserved_by_user_id::text = u.user_id::text
  LEFT JOIN ranked_staff r ON TRUE
  LEFT JOIN fallback_staff f ON TRUE
  LEFT JOIN ini ON TRUE
  LEFT JOIN ini_hosp_Cd ON TRUE
)
SELECT * FROM final;
-- SQL: -1104004 end', '2', '[]', '0', '{"applications": [4]}', '{"classes": []}', 'セコム連携 予約担当ユーザーID取得', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104001, '-- SQL: -1104001 begin
WITH expanded_candidates AS (
  SELECT value::text AS candidate_user_id, ordinality AS priority
  FROM jsonb_array_elements_text(@chargeUserIdJson::jsonb) WITH ORDINALITY
),
selected_user AS (
  SELECT candidate_user_id FROM expanded_candidates
  WHERE NULLIF(candidate_user_id,'''') IS NOT NULL
  ORDER BY priority ASC LIMIT 1
),
default_user AS (
  SELECT candidate_user_id AS default_user_id FROM expanded_candidates
  WHERE priority = 3 LIMIT 1
)
SELECT
  CONCAT(
    CASE
      WHEN COALESCE(
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
      ) IS NULL THEN repeat('' '',4)
      WHEN OCTET_LENGTH(
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        )
      ) <= 4 THEN
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        ) || repeat('' '', 4 - OCTET_LENGTH(
          COALESCE(
            NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
            NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
          )
        ))
      ELSE convert_from(substring((
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        )
      )::bytea from 1 for 4),''UTF8'')
    END,
    CASE
      WHEN COALESCE(@bedName::text,'''') = '''' THEN repeat('' '',40)
      WHEN OCTET_LENGTH(@bedName::text) > 40 THEN convert_from(substring((@bedName::text)::bytea from 1 for 40),''UTF8'')
      ELSE @bedName::text
    END
  ) AS reservation_code_comment,
  @appointmentDate::text AS appointment_date,
  @sequenceNo::text AS sequence_no
FROM (SELECT 1) dummy
LEFT JOIN selected_user su ON TRUE
LEFT JOIN default_user du ON TRUE
LEFT JOIN mst_personal_user mpu_sel ON mpu_sel.user_id::text = su.candidate_user_id
LEFT JOIN mst_personal_user mpu_def ON mpu_def.user_id::text = du.default_user_id;
-- SQL: -1104001 end', '3', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}, {"sql_cd": -1104004, "field_name": "hosp_cd_1_2", "replace_var": "@hospCd12"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104000, '-- SQL: -1104000 begin
WITH select_ord_main AS(
SELECT 
    CASE 
        WHEN mbe.bed_name IS NULL THEN RPAD('' '', 40, '' '')
        ELSE REPLACE(mbe.bed_name, '','', ''_'')
    END AS bed_name
    ,to_char(
         to_timestamp(ord.treat_date || mkr.kur_standard_start_time , ''YYYYMMDDHH24MISS''),
         ''YYYY/MM/DD HH24:MI:SS''
       ) AS appointment_date
FROM
ord_main AS ord
	LEFT OUTER JOIN mst_bed AS mbe 
		ON mbe.bed_cd = ord.rst_bed_cd 
	LEFT OUTER JOIN mst_kur AS mkr 
		ON mkr.kur_cd = ord.ind_kur_cd 
where 
	ord.ord_no=@ordNo
    AND ord.facility_cd = @facilityCd 
)
,select_sequence_no as(
SELECT 
  COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo
  AND save_2 ->> ''coop_cd'' =''ind_dial''
  AND facility_cd = @facilityCd 
  ORDER BY pat_coop_detail.up_date 
  LIMIT 1
)
SELECT
(SELECT bed_name FROM select_ord_main) AS bed_name,
(SELECT appointment_date FROM select_ord_main) AS appointment_date,
(SELECT sequence_no FROM select_sequence_no) AS sequence_no
-- SQL: -1104000 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103022, '-- SQL: -1103022 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows
where row->>@conditionTargetColNo = @conditionValue::text;
-- SQL: -1103022 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績 項目取得用(削除電文用)', '2025-08-05 10:51:12.178', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103020, '-- SQL: -1103020 begin
-- このSQLは、透析実績連携の最新の新規処理によって生成されたファイルの内容を出力します。
-- 末端のレイアウトで使用する想定です。
-- このSQLで取得したパラメータを直接レイアウト内で参照してください。

WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows;
-- SQL: -1103020 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 項目取得用(削除電文用)', '2025-08-05 10:51:12.178', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103016, E'-- SQL: -1103016 begin
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
            WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\\1'')
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
            WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\\1'')
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
-- SQL: -1103016 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 新規処理dump取得用', '2025-07-24 22:27:41.417', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103000, E'-- SQL: -1103000 begin
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
            ''SCM_DIALYSISSEND_KARTE_NOTE''
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
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''PAT_LIFE'') AS pat_life
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
    string_agg(elem ->> ''content'', E''\\r\\n'')
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
  ord_main om
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
, pat_event_info AS (
--観察記録情報
SELECT
  pe.event_start_date::date AS rec_date,
  pe.category_cd AS category_cd,
  pe.sub_category_cd AS sub_category_cd,
  coalesce(pe.event_start_time, ''0000'') AS event_start_time,
  pe.sub_category_name::text AS label_name,
  STRING_AGG(
    CASE pe.sub_category_name
      WHEN ''SOAP'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\\r\\n'', '''', ''''), E''\\r\\n$'', '''', ''''), E''(\\\\r?\\\\n)+'', E''\\r\\n   '', ''g''),E''\\uFEFF'' ,''''))
      ELSE
        unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\\r\\n'', '''', ''''), E''\\r\\n$'', '''', ''''),E''\\uFEFF'' ,''''))
    END,
    E''\\r\\n''
  ) AS content
FROM
  pat_event pe
CROSS JOIN LATERAL json_array_elements(pe.input_params ::json) WITH ORDINALITY AS input(params, idx)
CROSS JOIN LATERAL json_array_elements(pe.result_params ::json) WITH ORDINALITY AS result(params, idx)
WHERE
  pe.facility_cd = @facilityCd
  AND pe.pat_id = @patId
  AND pe.ord_no = @ordNo
  AND pe.is_del = ''0''
  AND pe.use_type = 2
  AND pe.event_start_date IS NOT NULL
  AND input.idx = result.idx
  AND pe.sub_category_name IS NOT null
GROUP BY
  pe.pat_event_cd
)
, merged_pat_event_category as (
-- サブカテゴリ毎にマージした観察記録情報
  SELECT
    rec_date,
    label_name || '':'' || E''\\r\\n'' ||
      STRING_AGG(
      content,
      E''\\r\\n''
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
      E''\\r\\n''
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
      ini.addition || '':'' || E''\\r\\n'' || om.addition
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
SELECT
  RIGHT(
        CASE (SELECT value::NUMERIC FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN ''0'' THEN 
            (SELECT disp_user_id FROM journal_staff_cd)
        WHEN ''1'' THEN 
            COALESCE(
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1),
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2),
            (SELECT defalut_disp_user_id FROM default_doctor),
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
    E''\\r\\n''
  ) AS medical_record_text
FROM
  ord_main_info omi,
  karute_txt kt,
  coop_detail cd
-- SQL: -1103000 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', '2025-06-03 08:56:02.129', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102031, '-- SQL: -1102031 begin
-- このSQLは、透析指示連携の最新の新規処理によって生成されたファイルの内容を出力します。
-- 処置依頼と注射依頼の各種ファイルのmst_coop_layout_detailを特定するために使用してください。
-- このSQLで取得したパラメータは子レイアウトのSQLで直接参照してください。

WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows;
-- SQL: -1102031 end	
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '透析指示連携 新規処理dump取得用', '2025-07-25 11:29:21.073', CURRENT_TIMESTAMP, '[{"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102029, E'-- SQL: -1102029 begin
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
      WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\\1'')
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
      WHEN l.line LIKE ds.file_split_delimite_format THEN REGEXP_REPLACE(l.line, ''^-+ (.+) -+$'', ''\\1'')
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
-- SQL: -1102029 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 新規処理dump取得用', '2025-07-24 22:27:41.417', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102012, '-- SQL: -1102012 begin
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
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
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
        SUM(medi_amount) AS medi_amount,
        MIN(unit_convert) AS unit_convert
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
-- SQL: -1102012 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', '2025-06-24 17:02:31.955', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102010, 'WITH coop_ini_info AS (
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
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
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
   sort_key = @sortKey', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', '2025-06-25 09:35:04.176', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102004, 'WITH dial_diff_com_info AS (
SELECT
  info ->> ''dial_diff_cd'' AS dial_diff_cd,
  info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  pat_personal_main ppm
CROSS JOIN LATERAL json_array_elements(ppm.dial_diff_com_info::json) info
WHERE
  ppm.pat_id = @patId
  AND ppm.is_del = ''0''
)
SELECT
  COALESCE(json_agg(dial_diff_com_info), ''[{"dial_diff_cd":"","is_dial_diff":""}]''::json)::text AS pat_personal_info
FROM
  dial_diff_com_info', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示_患者個人情報の透析困難コード取得', '2025-06-16 16:16:46.764', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102002, '-- SQL: -1102002 begin
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
, ini_unit_medi AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, ini_unit_equip AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_EQUIP''
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
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
  (t1.info ->> ''cd'')::integer AS medi_cd,
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
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
--施設設定107设置获取
    SELECT
        ROW_NUMBER() OVER () AS no2,
        datt.a1
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
            )
        ) AS val
    ) AS datt
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order,
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
  index_no ::int AS medi_class_code_order,
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
  index_no ::int AS timing_code_order,
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
  index_no ::int AS procedure_code_order,
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
  class_cd,
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
        ROW_NUMBER() OVER () AS no2,
        TO_NUMBER(val, ''999999999999'') AS ora
    FROM UNNEST(
        COALESCE(
            string_to_array(
            (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3006''
                AND mst_f.facility_cd = @facilityCd
            ),
            '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
        )
    ) AS val
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order,
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
  index_no ::int AS meq_class_code_order,
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
  10000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate >= mt.in_hosp_b_startdate THEN
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
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  20000 AS temp_no,
  (om.ind_cond_info->''5''->>''value'')::integer AS mst_cd,
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
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  21000 AS temp_no,
  (om.ind_cond_info->''6''->>''value'')::integer AS mst_cd,
  21000 AS meq_class_code_order,
  21000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 30000
        WHEN ''2'' THEN 30000 + mst_mix.idx
      END
  END AS temp_no,
  CASE om.ind_cond_info -> ''25'' ->>''medicine_type''
    WHEN ''1'' THEN (om.ind_cond_info->''25''->>''value'')::integer
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  30000 AS medi_code_order,
  30000 AS medi_class_code_order,
  30000 AS medicine_type,
  30000 AS timing_code_order,
  30000 AS procedure_code_order,
  30000 AS interval_no,
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
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_touseki AS (
-- 透析液
SELECT
  31000 AS temp_no,
  (om.ind_cond_info->''15''->>''value'')::integer AS mst_cd,
  31000 AS medi_code_order,
  31000 AS medi_class_code_order,
  31000 AS medicine_type,
  31000 AS timing_code_order,
  31000 AS procedure_code_order,
  31000 AS interval_no,
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
      CAST(om.ind_cond_info->''17''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_hoeki AS (
-- 補液
SELECT
  32000 AS temp_no,
  (om.ind_cond_info->''19''->>''value'')::integer AS mst_cd,
  32000 AS medi_code_order,
  32000 AS medi_class_code_order,
  32000 AS medicine_type,
  32000 AS timing_code_order,
  32000 AS procedure_code_order,
  32000 AS interval_no,  
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
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_one_film AS (
-- 1次膜
SELECT
  22000 AS temp_no,
  (om.ind_cond_info->''7''->>''value'')::integer AS mst_cd,
  22000 AS meq_class_code_order,
  22000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_two_film AS (
-- 2次膜
SELECT
  23000 AS temp_no,
  (om.ind_cond_info->''8''->>''value'')::integer AS mst_cd,
  23000 AS meq_class_code_order,
  23000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 33000 + (t1.idx * 100)
        WHEN ''2'' THEN 33000 + (t1.idx * 100) +  mst_mix.idx
      END
  END AS temp_no,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN (t1.medi_info ->> ''cd'')::integer 
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
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
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
         END
      WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
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
        WHEN ''1'' THEN TRUNC((medi_info ->> ''amount'')::NUMERIC, 4)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((medi_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
        WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
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
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
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
    AND mst_medi.facility_cd = @facilityCd
    AND mst_medi.is_del = ''0''
    AND mst_medi.is_disp = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
  CROSS JOIN ini_value
  WHERE
    om.is_del = ''0''
    AND om.ord_no = @ordNo
    AND om.pat_id = @patId
)
, pro_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS pro_hosp_cd,
        MIN(mp.pricedure_name) AS pricedure_name,
        omi.procedure_cd
    FROM
        medi_indo omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN ini_value
    GROUP BY
        omi.procedure_cd
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  24000 + t1.idx AS temp_no,
  (t1.equip_info ->> ''cd'')::integer AS mst_cd,
  24000 + meq.meq_class_code_order AS meq_class_code_order,
  24000 + meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  13000 AS temp_no,
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
  AND mst.facility_cd = @facilityCd
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
    coa.timing_code_order AS timing_code_order,
    coa.procedure_code_order AS procedure_code_order,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.medi_code_order AS medi_code_order,
    coa.medi_class_code_order AS medi_class_code_order,
    coa.hosp_cd AS hosp_cd,
    COALESCE(coa.amount,0) AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_code_order AS timing_code_order,
    tou.procedure_code_order AS procedure_code_order,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.medi_code_order AS medi_code_order,
    tou.medi_class_code_order AS medi_class_code_order,
    tou.hosp_cd AS hosp_cd,
    COALESCE(tou.amount,0) AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_code_order AS timing_code_order,
    hoe.procedure_code_order AS procedure_code_order,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.medi_code_order AS medi_code_order,
    hoe.medi_class_code_order AS medi_class_code_order,
    hoe.hosp_cd AS hosp_cd,
    COALESCE(hoe.amount,0) AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(imi.temp_no) AS temp_no,
    33000 + MIN(imi.medicine_type) AS medicine_type,
    33000 + MIN(t.timing_code_order) AS timing_code_order,
    33000 + MIN(p.procedure_code_order) AS procedure_code_order,
    33000 + MIN(imi.interval_no) AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(imi.mst_cd) AS mst_cd,
    33000 + MIN(mst_medi.medi_code_order) AS medi_code_order,
    33000 + MIN(mst_medi.medi_class_code_order) AS medi_class_code_order,
    imi.hosp_cd AS hosp_cd,
    SUM(imi.amount) AS amount,
    MIN(imi.unit) AS unit
  FROM
    medi_indo imi
    LEFT JOIN pro_code pc ON pc.procedure_cd = imi.procedure_cd
    LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND (imi.procedure_cd IS NULL
    OR pc.pro_hosp_cd IS NULL
    )
  GROUP BY
  imi.hosp_cd
) AS ind_medi_table
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  imi2.temp_no,
  imi2.medicine_type,
  imi2.timing_cd,
  imi2.interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  imi2.amount AS amount,
  imi2.unit AS unit,
  pc.pricedure_name AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot = ''0''
  AND imi2.procedure_cd IS NOT NULL
  AND pc.pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0

UNION ALL
SELECT
  MIN(imi2.temp_no) AS temp_no,
  MIN(imi2.medicine_type) AS medicine_type,
  MIN(imi2.timing_cd) AS timing_cd,
  MIN(imi2.interval_no) AS interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(imi2.mst_cd) AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(pc.pricedure_name) AS pro_title,
  MIN(imi2.procedure_cd) AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot = ''0''
  AND imi2.procedure_cd IS NOT NULL
  AND pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pc.pro_hosp_cd,
  imi2.hosp_cd
)
, medi_union_2_with_sorted as (
    select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    pro_title,
    procedure_cd,
    pro_hosp_cd,
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
    from medi_union_2
    LEFT JOIN mst_medi mmd ON mst_cd = mmd.medicine_cd
    LEFT JOIN timing_order ON timing_cd = timing_order.timing_code
    LEFT JOIN procedure_order ON procedure_cd = procedure_order.procedure_code
    order by sort_num
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
  medi_union_2_with_sorted mu2
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
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
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
  CASE 
  WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
  ELSE substring(
      hosp_cd FROM (
      SELECT MIN(i)
      FROM generate_series(1, char_length(hosp_cd)) AS i
      WHERE octet_length(substring(hosp_cd FROM i)) <= 8
      )
  )
  END AS medi_cd,
  TRUNC(amount, 4)::FLOAT8::TEXT AS medi_amount,
  unit,
  ''01'' AS detail_id
FROM
  final_data
WHERE
  rp < 11
ORDER BY
  RP,
  sort_key;

-- SQL: -1102002 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示_処置項目情報取得', '2025-07-01 17:38:01.233', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102001, 'WITH personal_user AS (
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
    personal_user', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', '2025-06-23 15:08:41.412', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102000, E'WITH RECURSIVE coop_ini_info AS (
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
            SELECT string_agg(elem ->> ''content'', E''\\r\\n'')
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
            mri.addition || ''：'' || E''\\r\\n'' || omi.addition
        ], NULL),
        E''\\r\\n''
    ) AS medical_record_text
FROM
    medical_record_ini mri,
    ord_main_info omi,
    journal_info ji,
    cd_bed_name cbn,
    rp_count rc', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示', '2025-07-16 10:43:50.504', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101508, 'SELECT
    1
WHERE
    @content::numeric BETWEEN @min::numeric AND @max::numeric;', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　身長有効範囲チェック', '2025-08-14 10:41:26.116', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101507, E'WITH params AS (
    SELECT
        @dataType::text AS dt ,
        @content::text  AS val
), violation AS (
    SELECT 1 AS violation
    FROM params
    WHERE
        (dt = ''01''
         AND NOT (val ~ ''^\\s*[+-]?\\d+(\\.\\d+)?\\s*$''))

     OR
        (dt = ''03''
         AND EXISTS (
               SELECT 1
               FROM unnest(
                     regexp_split_to_array(val, ''[;；]'')) AS seg
               WHERE seg <> ''''
                 AND array_length(string_to_array(seg, '':''), 1) <> 2
         ))

     OR
        (dt = ''04''
         AND EXISTS (
               SELECT 1
               FROM unnest(
                     regexp_split_to_array(val, ''[;；]'')) AS seg
               WHERE seg <> ''''
                 AND array_length(string_to_array(seg, '':''), 1) <> 4
         ))

     OR
        (dt NOT IN (''01'',''02'',''03'',''04''))
    LIMIT 1
)
SELECT * FROM violation;
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコム　患者プロファイル　データタイプチェック', '2025-06-08 20:39:48.343', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101506, 'SELECT
    1
FROM
    sys_coop_journal
WHERE
    ctl_no = @ctlNo
    AND OCTET_LENGTH(dump) = @totalByte :: numeric;', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　電文長チェック', '2025-06-07 18:22:20.053', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101505, 'WITH
-- 1) content をセミコロンで分解
raw_entries AS (
  SELECT unnest(string_to_array(trim(both '';'' FROM ''@content''), '';'')) AS entry
),
-- 2) コロンで分割して in_hospital_cd, name, raw_state を取得
split_info AS (
  SELECT
    split_part(entry, '':'', 1) AS in_hospital_cd,
    split_part(entry, '':'', 2) AS name,
    split_part(entry, '':'', 3) AS raw_state
  FROM raw_entries
  WHERE entry <> ''''
),
-- 3) 生データ(key2)→変換後値(value) のマップ
state_map AS (
  SELECT
    info ->> ''key2''   AS raw_key,
    info ->> ''value''  AS state_val
  FROM mst_coop_ini ini
  CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) AS info
  WHERE
    ini.facility_cd = ''@facilityCd''
    AND ini.is_del    = ''0''
    AND ini.is_disp   = ''1''
    AND info ->> ''key1'' = ''CONV_INFECTION_TO_FNW''
),
-- 4) mst_infection から facility_cd／is_del 絞り込み
infection_map AS (
  SELECT
    infection_cd,
    in_hospital_cd_1
  FROM ntss.mst_infection
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del    = ''0''
),
-- 5) 新しい各エントリを組み立て
new_array AS (
  SELECT
    im.infection_cd,
    -- state_map がヒットすれば変換値、なければ ''0''
    COALESCE(sm.state_val, ''0'')       AS infect,
    to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date,
    NULL::text                        AS exam_date
  FROM split_info si
  -- raw_state → state_val
  LEFT JOIN state_map sm
    ON si.raw_state = sm.raw_key
  -- in_hospital_cd で infection_cd を取得
  JOIN infection_map im
    ON im.in_hospital_cd_1 = si.in_hospital_cd
)
-- 6) pat_main を更新
UPDATE pat_main pm
SET infect_info = (
  SELECT jsonb_agg(e.elem)
  FROM (
    SELECT elem
    FROM LATERAL jsonb_array_elements(infect_info) AS elem
    WHERE (elem->>''infection_cd'')::int NOT IN (SELECT infection_cd FROM new_array)
    UNION ALL
    SELECT jsonb_build_object(
      ''infect'',       na.infect,
      ''up_date'',      na.up_date,
      ''exam_date'',    to_jsonb(na.exam_date),
      ''infection_cd'', na.infection_cd
    )
    FROM new_array na
  ) AS e(elem)
),
up_date = CURRENT_TIMESTAMP
WHERE
  pm.pat_id = @patId
  AND pm.facility_cd = ''@facilityCd''
  AND pm.is_del = ''0'';', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　感染症更新', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101504, 'WITH base AS (
  SELECT
    pat_id,
    COALESCE(physical_info, ''[]''::jsonb) AS physical_info
  FROM pat_unique
  WHERE
    pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND is_del = ''0''
),
latest_obj AS (
  SELECT
    b.pat_id,
    ord,
    (elem->>''height'')::numeric AS height,
    (elem->>''exam_date'')::timestamp AS exam_date,
    ROW_NUMBER() OVER (PARTITION BY b.pat_id ORDER BY (elem->>''exam_date'')::timestamp DESC) AS rn
  FROM base b,
       jsonb_array_elements(b.physical_info) WITH ORDINALITY AS elem(elem, ord)
),
max_ctl AS (
  SELECT
    pat_id,
    MAX((e->>''ctl_no'')::int) AS max_ctl
  FROM base,
       jsonb_array_elements(physical_info) AS e
  GROUP BY pat_id
),
target AS (
  SELECT
    b.pat_id,
    COALESCE(lo.ord, 1) - 1 AS idx,
    COALESCE(m.max_ctl, -1) + 1 AS next_ctl_no,
    CASE
      WHEN lo.exam_date::date >= CURRENT_DATE THEN ''update''
      ELSE ''append''
    END AS action
  FROM base b
  LEFT JOIN latest_obj lo ON b.pat_id = lo.pat_id AND lo.rn = 1
  LEFT JOIN max_ctl m ON b.pat_id = m.pat_id
  WHERE lo.height IS DISTINCT FROM ''@content''
     OR lo.height IS NULL
)
UPDATE pat_unique
SET physical_info = CASE
  WHEN action = ''update'' THEN
    jsonb_set(
      jsonb_set(physical_info, ARRAY[idx::text, ''height''], to_jsonb(''@content''::text), false),
      ARRAY[idx::text, ''order_class''], to_jsonb(3), false
    )
  ELSE
     jsonb_build_array(
      jsonb_build_object(
        ''dw'',                   NULL,
        ''ctr'',                  NULL,
        ''memo'',                 NULL,
        ''ctl_no'',               next_ctl_no,
        ''height'',               ''@content'',
        ''chest_dia'',            NULL,
        ''exam_date'',            TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD''),
        ''breast_dia'',           NULL,
        ''ctr_weight'',           NULL,
        ''facility_cd'',          ''@facilityCd'',
        ''order_class'',          3,
        ''indicator_cd'',         NULL,
        ''inspect_date'',         NULL,
        ''target_weight'',        NULL,
        ''pre_scale_lower'',      NULL,
        ''pre_scale_upper'',      NULL,
        ''indicator_start_date'', NULL
      )
    ) || COALESCE(physical_info, ''[]''::jsonb)
END,
  up_date = CURRENT_TIMESTAMP
FROM target
WHERE pat_unique.pat_id = target.pat_id;', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　身長更新', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101503, 'WITH abo_ini_info AS (
SELECT
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_PATPROFILE_RCV''
        AND info ->> ''key2'' IN (''ABO_A'', ''ABO_B'', ''ABO_O'', ''ABO_AB'')
        AND split_part(@content, '':'', 1) = ANY (string_to_array(COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''), '',''))
),
rh_ini_info AS (
SELECT
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_PATPROFILE_RCV''
        AND info ->> ''key2'' IN (''RH_PLUS'', ''RH_MINUS'')
        AND split_part(@content, '':'', 1) = ANY (string_to_array(COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''), '',''))
)
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM abo_ini_info) <> 1 THEN 0
        ELSE CASE (SELECT key2 FROM abo_ini_info)
            WHEN ''ABO_A''  THEN 1
            WHEN ''ABO_B''  THEN 2
            WHEN ''ABO_O''  THEN 3
            WHEN ''ABO_AB'' THEN 4
            ELSE 0
        END
    END AS abo,
    CASE
        WHEN (SELECT COUNT(*) FROM rh_ini_info) <> 1 THEN 0
        ELSE CASE (SELECT key2 FROM rh_ini_info)
            WHEN ''RH_PLUS''   THEN 1
            WHEN ''RH_MINUS''  THEN 2
            ELSE 0
        END
    END AS rh
;', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　電文種別チェック', '2025-07-08 14:58:44.747', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101502, 'UPDATE
    pat_personal_main
SET
    pat_blood_type_abo = @abo
  , pat_blood_type_rh = @rh
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0'' 
  ;', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　身長有効範囲チェック', '2025-08-14 10:38:18.609', CURRENT_TIMESTAMP, '[{"sql_cd": -1101503, "field_name": "abo", "replace_var": "@abo"}, {"sql_cd": -1101503, "field_name": "rh", "replace_var": "@rh"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101501, 'SELECT 1 WHERE @messageType = ''C1'';', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル　電文種別チェック', '2025-08-14 10:38:18.609', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101008, '-- key0/key1/key2 で絞り込み、
-- value が homeFlag と一致する要素があれば 1 行、なければ 0 行を返す
SELECT
  1 AS match_exists
WHERE
  EXISTS (
    SELECT
      1
    FROM
      ntss.mst_coop_ini AS m
      CROSS JOIN LATERAL jsonb_array_elements(m.coop_ini_info) AS x(elem)
    WHERE
      m.is_del       = ''0''                      -- 削除されていない
      AND m.facility_cd = @facilityCd            -- 施設コード
      AND x.elem->>''key0'' = @key0                -- key0 で絞り込み
      AND x.elem->>''key1'' = ''SCM_PATINFORCV''         -- key1 で絞り込み
      AND x.elem->>''key2'' = ''TARGET_FLAGS''   -- key2 で絞り込み
      AND @homeFlag = ANY(string_to_array(x.elem->>''value'', '',''))  -- カンマ区切りを分解して比較
  );
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者属性在宅フラグ判定', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101005, '
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
  , ''{}''
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコムの患者プロファイル_患者基本情報の新規', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101004, E'WITH names AS (
  SELECT
    -- 漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanjiName'',''''), ''[ 　]+'') AS name_arr,
    -- カナ氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanaName'',''''), ''[ 　]+'') AS kana_arr,
    -- その他連絡先漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@otherKanjiName'',''''), ''[ 　]+'') AS oname_arr
),
birthday_check AS (
-- 渡された値がYYYYMMDD形式の日付でない場合はNULLにする
SELECT
     CASE 
       WHEN NULLIF(''@birthday'','''') IS NULL THEN NULL
       WHEN ''@birthday'' ~ ''^(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])$'' 
            AND (
                 (''@birthday'' ~ ''^(19|20)\\d{2}02(29)$'' AND SUBSTRING(''@birthday'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@birthday'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@birthday'', 1, 4)::int % 400 = 0))
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}(0[13578]|1[02])(0[1-9]|[12]\\d|3[01])$'')
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}(0[469]|11)(0[1-9]|[12]\\d|30)$'')
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}02(0[1-9]|1\\d|2[0-8])$'')
            )
       THEN ''@birthday''
       ELSE NULL
     END AS birthday
)
UPDATE ntss.pat_personal_main AS t
SET
    -- 漢字氏名：姓を暗号化して更新
    pat_last_name       = personal_info_encrypt(name_arr[1]),
    -- 漢字氏名：名を暗号化（存在しない場合は空文字）して更新
    pat_first_name      = COALESCE(personal_info_encrypt(name_arr[2]),''''),

    -- カナ氏名：姓を暗号化して更新
    pat_last_name_kana  = personal_info_encrypt(kana_arr[1]),
    -- カナ氏名：名を暗号化（存在しない場合は空文字）して更新
    pat_first_name_kana = COALESCE(personal_info_encrypt(kana_arr[2]),''''),

    -- 生年月日(YYYYMMDD)：スラッシュを除去した文字列で更新
    pat_birthday        = COALESCE((SELECT birthday FROM birthday_check), pat_birthday),

    -- 性別コード：M→1, F→2, その他→NULL
    pat_sex             = CASE NULLIF(''@sex'','''')
                            WHEN ''1'' THEN 1
                            WHEN ''2'' THEN 2
                            ELSE NULL
                          END::smallint,

    -- 本人連絡先情報：既存JSONをマージして更新
    pat_contact_info    = CASE 
                            WHEN ''@zipCd'' = '''' AND ''@address'' = '''' AND ''@tel1'' = '''' THEN t.pat_contact_info
                            ELSE t.pat_contact_info ||
                              json_build_object(
                                ''zip_cd'',  NULLIF(REPLACE(''@zipCd'', ''-'', ''''),''''),
                                ''address'', NULLIF(''@address'',''''),
                                ''tel1'',    NULLIF(''@tel1'','''')
                              )::jsonb
                            END,

    -- その他連絡先情報：
    --   otherKanjiName が NULL/空 の場合は変更せず既存値を保持、
    --   登録する場合は1つめの要素を更新。
    other_contact_info = CASE
      -- 値がなければ何もしない
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN
        t.other_contact_info

      -- それ以外は既存配列に新要素を追記
      ELSE
        jsonb_set(coalesce(t.other_contact_info, ''[]''::jsonb), ''{0}'', 
            jsonb_build_object(
              ''ctl_no'', 1,
              ''disp_order'', 0,
              ''last_name'',     oname_arr[1],
              ''first_name'',    COALESCE(oname_arr[2], ''''),
              ''zip_cd'',        NULLIF(REPLACE(''@otherZipCd'', ''-'', ''''), ''''),
              ''address'',       NULLIF(''@otherAddress'',''''),
              ''tel1'',          NULLIF(''@otherTel1'',''''),
              ''relation_cd'',   NULL,
              ''relation_name'', ''その他''
            )
          )
    END,
    -- 更新日時を現在時刻に
    up_date             = CURRENT_TIMESTAMP

FROM names
WHERE
    -- 対象レコードの絞り込み：患者ID＋施設コード＋削除フラグ未削除
      t.pat_id  = ''@patId''
  AND t.facility_cd = ''@facilityCd''
  AND t.is_del      = ''0'';
', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の更新', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101003, 'WITH in_out_info AS (
SELECT array_to_json(ARRAY_AGG(json_build_object(
    ''ctl_no'', 1,
    ''in_out'', 0,
    ''reason'', null,
    ''to_course'', null,
    ''to_doctor'', null,
    ''disp_order'', 0,
    ''period_end'', null,
    ''facility_cd'', NULLIF(''@facilityCd'', ''''),
    ''from_course'', null,
    ''from_doctor'', null,
    ''move_in_out'', ''6'',
    ''to_facility'', null,
    ''period_start'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''from_facility'', null,
    ''course_is_free'', ''0'',
    ''doctor_is_free'', ''0'',
    ''period_end_day'', null,
    ''period_end_year'', null,
    ''facility_is_free'', ''0'',
    ''period_end_month'', null,
    ''period_start_day'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2),
    ''period_start_date'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''period_start_year'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4),
    ''period_start_month'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2),
    ''period_end_input_free'', ''0'',
    ''period_start_input_free'', ''0'',
    ''to_medicalInstitutionCd'', null,
    ''from_medicalInstitutionCd'', null
    ))) AS in_out_info_json
)
INSERT 
INTO pat_unique( 
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
) 
VALUES ( 
  @patId
  , ''[]''
  , (SELECT in_out_info_json FROM in_out_info)
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
  , NULL
)', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル_固有情報登録', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101002, '-- kanjiName が NULL／空文字ならレコードを返さず、
-- それ以外のときだけ 1 行返す
SELECT
  1 AS required_fields_flag
WHERE
  NULLIF(@kanjiName, '''') IS NOT NULL;
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者属性　漢字氏名が空欄チェック', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101001, '-- NULL／空文字のときはレコードを返さず、
-- それ以外のときだけ 1 行返す
SELECT
  1 AS required_fields_flag
WHERE
  NULLIF(@hospPatId, '''') IS NOT NULL;
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者属性　患者IDが空欄チェック', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1101000, E'WITH names AS (
  SELECT
    -- 漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanjiName'',''''), ''[ 　]+'') AS name_arr,
    -- カナ氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanaName'',''''), ''[ 　]+'') AS kana_arr,
    -- その他連絡先漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@otherKanjiName'',''''), ''[ 　]+'') AS oname_arr
),
birthday_check AS (
-- 渡された値がYYYYMMDD形式の日付でない場合はNULLにする
SELECT
     CASE 
       WHEN NULLIF(''@birthday'','''') IS NULL THEN NULL
       WHEN ''@birthday'' ~ ''^(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])$'' 
            AND (
                 (''@birthday'' ~ ''^(19|20)\\d{2}02(29)$'' AND SUBSTRING(''@birthday'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@birthday'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@birthday'', 1, 4)::int % 400 = 0))
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}(0[13578]|1[02])(0[1-9]|[12]\\d|3[01])$'')
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}(0[469]|11)(0[1-9]|[12]\\d|30)$'')
                 OR (''@birthday'' ~ ''^(19|20)\\d{2}02(0[1-9]|1\\d|2[0-8])$'')
            )
       THEN ''@birthday''
       ELSE NULL
     END AS birthday
)
INSERT INTO ntss.pat_personal_main (
    fn_pat_id,             -- FNW+で管理する施設内の一意な患者ID
    hosp_pat_id,           -- 院内表示用の患者ID
    nkk_pat_id,            -- 日機装内で管理する一意な患者ID
    facility_cd,           -- 登録施設コード

    pat_last_name,         -- 患者氏名(漢字姓)
    pat_first_name,        -- 患者氏名(漢字名)
    pat_last_name_kana,    -- 患者氏名(カタカナ姓)
    pat_first_name_kana,   -- 患者氏名(カタカナ名)

    pat_birthday,          -- 生年月日(YYYYMMDD)
    pat_sex,               -- 性別コード (M→1, F→2, その他→NULL)
    pat_blood_type_abo,    -- 血液型ABO
    pat_blood_type_rh,     -- 血液型RH
    pat_blood_type_serovar,-- 血液型亜型
    in_out_class,          -- 入外区分

    pat_contact_info,      -- 本人連絡先情報(jsonb)
    other_contact_info,    -- その他連絡先情報(jsonb), NULL可

    is_die,                -- 死亡患者フラグ(固定0)
    is_del,                -- 削除フラグ(固定0)
    reg_date,              -- 登録日時
    up_date                -- 更新日時
)
SELECT
    -- FNW+で管理する施設内の一意な患者ID
    NULLIF(''@fnPatId'','''')                           AS fn_pat_id,
    -- 院内表示用の患者ID
    ''@hospPatId''                         AS hosp_pat_id,
    -- 日機装内で管理する一意な患者ID
    NULLIF(''@nkkPatId'','''')                          AS nkk_pat_id,
    -- 登録施設コード
    NULLIF(''@facilityCd'','''')                        AS facility_cd,

    -- 漢字氏名：姓を暗号化
    personal_info_encrypt(name_arr[1])              AS pat_last_name,
    -- 漢字氏名：名を暗号化（存在しない場合は空文字）
    COALESCE(personal_info_encrypt(name_arr[2]),'''') AS pat_first_name,
    -- カナ氏名：姓を暗号化
    personal_info_encrypt(kana_arr[1])               AS pat_last_name_kana,
    -- カナ氏名：名を暗号化（存在しない場合は空文字）
    COALESCE(personal_info_encrypt(kana_arr[2]),'''')  AS pat_first_name_kana,
    (SELECT birthday FROM birthday_check)          AS pat_birthday,
    -- 性別コード：M→1, F→2, その他→NULL
    CASE NULLIF(''@sex'','''')
      WHEN ''1'' THEN 1
      WHEN ''2'' THEN 2
      ELSE NULL
    END::smallint                                   AS pat_sex,
    ''0''                                              AS pat_blood_type_abo,
    ''0''                                              AS pat_blood_type_rh,
    ''0''                                              AS pat_blood_type_serovar,
    -- 入外区分コード
    0                AS in_out_class,

    -- 本人連絡先情報をJSONB化
    jsonb_build_object(
        ''fax'', null,
        ''tel1'',    NULLIF(''@tel1'',''''),
        ''tel2'', null,
        ''memo1'', null,
        ''memo2'', null,
        ''e_mail'', null,
        ''zip_cd'',  NULLIF(REPLACE(''@zipCd'', ''-'', ''''),''''),
        ''address'', NULLIF(''@address'',''''),
        ''work_tel'', null,
        ''work_name'', null,
        ''work_address'', null
    )                                                AS pat_contact_info,

    -- その他連絡先情報：otherKanjiName が NULL/空 の場合は登録せず NULL、
    CASE
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN NULL
      ELSE json_build_array(
        json_build_object(
          ''last_name'',     oname_arr[1],
          ''first_name'',    COALESCE(oname_arr[2],''''),
          ''zip_cd'',        NULLIF(REPLACE(''@otherZipCd'', ''-'', ''''), ''''),
          ''address'',       NULLIF(''@otherAddress'',''''),
          ''tel1'',          NULLIF(''@otherTel1'',''''),
          ''relation_cd'',   NULL,
          ''relation_name'', ''その他'',
          ''ctl_no'',        1,
          ''disp_order'',    0

        )
      )::jsonb
    END                                              AS other_contact_info,

    -- 死亡患者フラグは常に0
    ''0''                                              AS is_die,
    -- 削除フラグは常に0
    ''0''                                              AS is_del,
    -- 登録日時を現在時刻で
    CURRENT_TIMESTAMP                                AS reg_date,
    -- 更新日時を現在時刻で
    CURRENT_TIMESTAMP                                AS up_date

FROM names
;
', '3', '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の新規', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100014, 'select
@e01 as e01,
@e02 as e02,
@e03 as e03,
@e04 as e04,
@e05 as e05,
@e06 as e06,
@e07 as e07,
@e08 as e08,
@e09 as e09,
@e10 as e10
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_汎用（親レイアウトで取得した値を返却する）', '2025-08-14 10:44:26.94', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100006, 'WITH coop_ini_info AS (
    -- 連携設定取得(pre_sqlにて取得)
    SELECT coop_info->>''key1'' AS key1,
        coop_info->>''key2'' AS key2,
        coop_info->>''value'' AS value
    FROM json_array_elements(@coopIniInfo::json) coop_info
)
, converted_in_out_class AS (
    -- in_out_class変換値の取得（なければ''1''をデフォルトにする）
    SELECT ppm.pat_id,
        ppm.hosp_pat_id,
        ppm.in_out_class,
        COALESCE((  
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''CONV_INOUT_TO_KARTE''
                AND key2 = CASE
                    WHEN ppm.in_out_class::text = ''3'' THEN ''0''
                    ELSE ppm.in_out_class::text
                END
            LIMIT 1
        ), ''1'') AS converted_in_out_class
    FROM pat_personal_main ppm
    WHERE ppm.pat_id = @patId
)
, ini_value AS (
    -- 患者ID桁数の取得
    SELECT (
            SELECT CASE 
            WHEN value::int > 12 THEN ''12''
            ELSE value
            END
            FROM coop_ini_info
            WHERE key1 = ''SCM_COMMON''
                AND key2 = ''PATID_LEN''
            LIMIT 1
        ) AS patid_len
)
SELECT LPAD(
    RIGHT(converted.hosp_pat_id::text, ini_value.patid_len::integer),
    ini_value.patid_len::integer,''0'') AS hosp_pat_id,
    converted.converted_in_out_class AS in_out_class
FROM converted_in_out_class converted
    CROSS JOIN ini_value;', '3', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', '2025-05-27 13:22:20.351', CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coopIniInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100005, 'WITH get_coop_ini AS (
SELECT
  info ->> ''key1'' as key1,
  info ->> ''key2'' as key2,
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') as value
FROM
  mst_coop_ini as ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
)
SELECT jsonb_agg(get_coop_ini)::text AS coop_ini_info
FROM get_coop_ini', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_汎用（連携設定情報を取得）', '2025-07-08 15:03:18.464', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100003, 'WITH get_users AS (
SELECT 
user_id,
disp_user_id
FROM 
mst_user_authentication
WHERE facility_cd = @facilityCd
)
SELECT jsonb_agg(get_users)::text AS user_list
FROM get_users', '1', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_汎用（利用者マスタ（mst_user_authentication）を取得）', '2025-07-08 15:03:18.464', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100000, 'WITH all_values AS (
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
    ''SCM_XRAY_ORDER_SEND'',
    ''SCM_CONV_UNIT_MEDI''
    )
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
  (SELECT
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') AS hospital_id,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') AS course_cd1,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') AS course_cd2,
    (SELECT value FROM all_values WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''XX_TYPE_CODE'') AS xx_type_code
  ) AS ini_value
CROSS JOIN jounal', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', '2025-06-03 08:30:43.103', CURRENT_TIMESTAMP, NULL);

