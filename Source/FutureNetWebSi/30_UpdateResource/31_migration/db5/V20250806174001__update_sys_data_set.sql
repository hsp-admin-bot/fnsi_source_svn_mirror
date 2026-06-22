DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1107004;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107004, 'WITH not_send_items AS (
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
             ELSE '' '' || U&''\FF5E'' || '' '' ||
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
             length(regexp_replace(r.log_target,''[\x01-\x7E\｡-ﾟ]'','''',''g''))
           ))) ||
    ''：'' ||
    regexp_replace(
      r.log_content,
      E''\r?\n'',
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
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコム　指示変更履歴連携_カルテ記録テキスト取得', '2025-06-08 20:39:48.343', '2025-06-25 08:53:33.371', '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]'::jsonb);