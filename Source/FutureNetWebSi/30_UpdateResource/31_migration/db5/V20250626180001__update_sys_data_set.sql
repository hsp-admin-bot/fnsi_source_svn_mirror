DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1107004);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107004, '-- ============================================================
-- 帳票テキスト生成（sort_no = 460 はコメント行を最後に集約）
--   ordNo      : オーダ番号（数値）
--   facilityCd : 施設コード
--   key0       : INI 取得キー
--   content    : JSON 形式の指示変更ログ配列
-- ============================================================

-- 1) ord_mainを取得 ---------------------------
WITH ord_main_cte AS (
  SELECT
    -- treat_type カラムの定義
    ord_main.treat_type AS treat_type
  FROM
    ord_main
  WHERE
    ord_main.ord_no = @ordNo
    AND facility_cd = @facilityCd
),

-- 2) INI から「出力しない item_id」の一覧を配列で取得 --------
not_send_items AS (
    SELECT COALESCE(
               string_to_array(
                   (SELECT COALESCE(NULLIF(info ->> ''value'',''''),
                                    info ->> ''default_v'')
                    FROM   mst_coop_ini AS ini
                           CROSS JOIN LATERAL
                           jsonb_array_elements(ini.coop_ini_info) AS info
                    WHERE  facility_cd       = @facilityCd
                      AND  ini.is_del        = ''0''
                      AND  info ->> ''key0''   = @key0
                      AND  info ->> ''key1''   = ''SCM_IND_CHANGE_LOG''
                      AND  info ->> ''key2''   = ''NOT_SEND_ITEM_ID''
                      AND  info ->> ''is_effect'' = ''1''
                    LIMIT 1),
               '',''),                -- 例: ''10,40'' → {10,40}
           ''{}'')::int[] AS ids      -- 空なら空配列
),

-- 3) 変更ログ JSON をフラット化 ------------------------------
content_raw AS (
    SELECT  (elem ->> ''sort_no'')::int        AS sort_no,
            elem ->> ''log_target''            AS log_target,
            elem ->> ''log_date''              AS log_date,
            elem ->> ''treatment_weekday''     AS treatment_weekday,
            elem ->> ''treatment_method''      AS treatment_method,
            elem ->> ''treatment_course''      AS treatment_course,
            elem ->> ''log_class''             AS log_class,
            elem ->> ''log_content''           AS log_content,
            elem ->> ''treatment_start_date''  AS treatment_start_date,
            elem ->> ''treatment_end_date''    AS treatment_end_date
    FROM    jsonb_array_elements(@content::jsonb) AS elem
),

-- 4) sort_no → 行順・項目 ID・曜日表示有無 --------------------
sort_map(sort_no, seq, item_id, show_weekday) AS (
    VALUES
      ( 10,  2,  0, true ), ( 20,  3, 10, true ), ( 30,  4,  1, false ), ( 40,  5,  3, true ),
      ( 50,  6,  4, true ), ( 60,  7,  5, true ), ( 70,  8,  2, true ), ( 80,  9,  7, true ),
      ( 90, 10,  6, true ), (100, 11,  9, true ), (110, 12,  8, true ), (120, 13, 11, true ),
      (130, 14, 12, true ), (140, 15, 13, true ), (150, 16, 14, true ), (160, 17,  0, true ),
      (170, 18,  0, true ), (180, 19,  0, true ), (190, 20, 40, true ), (200, 21,  0, true ),
      (210, 22, 15, true ), (220, 23, 30, true ), (230, 24, 31, true ), (240, 25, 32, true ),
      (250, 26, 33, true ), (260, 27, 34, true ), (270, 28, 35, true ), (280, 29, 36, true ),
      (290, 30, 37, true ), (300, 31, 38, true ), (310, 32, 39, true ), (320, 33, 16, true ),
      (330, 34, 17, true ), (340, 35, 18, true ), (350, 36, 19, true ), (360, 37, 20, true ),
      (370, 38, 21, true ), (380, 39, 25, true ), (390, 40, 22, true ), (400, 41, 23, true ),
      (410, 42, 24, true ), (420, 43, 26, true ), (430, 44, 27, true ), (440, 45, 28, true ),
      (450, 46, 29, true ), (460, 47, 42, true ), (470, 48, 41, true ), (480, 49, 43, true )
),

-- 5) 同一 sort_no 内で行番号付与 ------------------------------
ranked AS (
    SELECT  cr.*,
            ROW_NUMBER() OVER (PARTITION BY cr.sort_no ORDER BY cr.log_target) AS rn
    FROM    content_raw cr
),

-- 6) sort_no = 460, 470 用 : 本文整形 + コメント抽出 ---------------
cte_460 AS (
    SELECT
        r.*,

        -- コメント値（無い場合は ''''）
        COALESCE(
            NULLIF(
                regexp_replace(
                    r.log_content,
                    E''.*?(?:\\r?\\n|^)コメント[:：]\\s*'',  -- コメント開始まで削除
                    '''',
                    ''s''
                ),
            ''''),
            ''''
        )                               AS comment_val,

        -- 本文整形
        regexp_replace(                                  -- ③ 全改行 → 空白
            regexp_replace(                              -- ② 動的ラベル [] 化
                regexp_replace(                          -- ① 行頭に [薬剤名]
                    regexp_replace(
                        r.log_content,
                        E''(?:\\r?\\n|^)コメント[:：].*'', -- コメント行をカット
                        '''',
                        ''s''
                    ),
                    E''^([^\\r\\n]+)'',
                    ''[薬剤名]\1''
                ),
                E''\\r?\\n([^:\\r\\n]+)[:：]'',
                '' [\1]'',
                ''g''
            ),
            E''\\r?\\n'',
            '' '',
            ''g''
        )                               AS body_fmt
    FROM   ranked r
    WHERE  r.sort_no = 460
),
cte_470 AS (
    SELECT
        r.*,

        -- コメント値（無い場合は ''''）
        COALESCE(
            NULLIF(
                regexp_replace(
                    r.log_content,
                    E''.*?(?:\\r?\\n|^)コメント[:：]\\s*'',  -- コメント開始まで削除
                    '''',
                    ''s''
                ),
            ''''),
            ''''
        )                               AS comment_val,

        -- 本文整形
        regexp_replace(                                  -- ③ 全改行 → 空白
            regexp_replace(                              -- ② 動的ラベル [] 化
                regexp_replace(                          -- ① 行頭に [薬剤名]
                    regexp_replace(
                        r.log_content,
                        E''(?:\\r?\\n|^)コメント[:：].*'', -- コメント行をカット
                        '''',
                        ''s''
                    ),
                    E''^([^\\r\\n]+)'',
                    ''[医材]\1''
                ),
                E''\\r?\\n([^:\\r\\n]+)[:：]'',
                '' [\1]'',
                ''g''
            ),
            E''\\r?\\n'',
            '' '',
            ''g''
        )                               AS body_fmt
    FROM   ranked r
    WHERE  r.sort_no = 470
),
-- 7) ヘッダ行 -----------------------------------------------
header_parts AS (
    -- タイトル
    SELECT 0 AS seq, 0 AS item_id,
           ''曜日：'' || COALESCE(cr.treatment_weekday, '''') ||
           '' 変更対象治療方法：'' || COALESCE(cr.treatment_method, '''') ||
           '' 変更対象クール：'' || COALESCE(cr.treatment_course, '''') || '' ('' ||
           TO_CHAR(to_date(cr.treatment_start_date, ''YYYYMMDD''), ''YYYY/MM/DD'') || '' ～ '' ||
           CASE
               WHEN cr.treatment_end_date = ''99991231''
                    OR cr.treatment_end_date = ''''
                    OR cr.treatment_end_date IS NULL
               THEN ''''
               ELSE TO_CHAR(to_date(cr.treatment_end_date, ''YYYYMMDD''), ''YYYY/MM/DD'')
           END || '')'' || CHR(10) AS part
    FROM   ord_main_cte f
    CROSS  JOIN LATERAL (
            SELECT * FROM content_raw ORDER BY sort_no LIMIT 1
          ) cr

    UNION ALL
    -- 罫線
    SELECT 1, 0, ''-----------------------------------------------------------------'' || CHR(10)
),

-- 8) 本文（コメント除外）--------------------------------------
detail_body AS (
    SELECT
        m.seq + CASE WHEN r.sort_no = 460 THEN r.rn * 0.01 ELSE 0 END AS seq_adj,
        m.item_id,

        -- 本文の組み立て
        (
        CASE
            -- ▼ sort_no = 80, 100, 110, 210, 230, 240, 250, 290, 300, 310, 330, 340, 350, 380, 390, 400, 430, 450 専用処理 : 単位を括弧で囲む
            WHEN r.sort_no IN (80, 100, 110, 210, 230, 240, 250, 290, 300, 310, 330, 340, 350, 380, 390, 400, 430, 450) THEN
                 regexp_replace(                                 -- ← 単位括弧化
                     (CASE
                          WHEN r.rn = 1 THEN
                               r.log_target
                               || repeat(
                                    '' '',
                                    GREATEST(
                                      0,
                                      22
                                      - ( length(r.log_target)
                                          + length(
                                              regexp_replace(
                                                r.log_target,
                                                ''[\x01-\x7E\｡-ﾟ]'',
                                                '''',
                                                ''g''
                                              )
                                            )
                                        )
                                    )
                                  )
                          ELSE repeat('' '',24)
                      END)
                      || CASE
                             WHEN r.rn = 1 AND m.show_weekday AND o.treat_type IN (1, 2, 3)
                                 THEN ''：['' || COALESCE(r.treatment_weekday,'''') || ''曜日]''
                             WHEN r.rn = 1
                                 THEN ''：''
                             ELSE ''''
                         END
                      || COALESCE(r.log_class,'''') || ''→''
                      || regexp_replace(r.log_content, E''\r?\n'', '' '', ''g'')  -- 改行→空白
                     ,
                     -- 数値の直後に続く任意の単位を () で括る
                     E''([0-9０-９]+(?:\\.[0-9０-９]+)?)(\\s*)([a-zA-Zµμ％%/]+(?:/min|/h|/s)?)'',
                     E''\\1\\2(\\3)'',
                     ''g''
                 )
            -- ▼ sort_no = 460 専用処理
            WHEN r.sort_no = 460 THEN
                 (CASE
                      WHEN r.rn = 1
                      THEN  r.log_target
                            || repeat('' '',
                               GREATEST(0, 22 - (
                                     length(r.log_target)
                                   + length(regexp_replace(r.log_target,''[\x01-\x7E\｡-ﾟ]'','''',''g''))
                               )))
                            || CASE
                                   WHEN m.show_weekday AND o.treat_type IN (1, 2, 3)
                                       THEN ''：['' || COALESCE(r.treatment_weekday,'''') || ''曜日]''
                                   ELSE ''：''
                               END
                      ELSE  repeat('' '',24)
                  END)
                  || COALESCE(r.log_class,'''') || ''→''
                  || c460.body_fmt                 -- 整形済み本文
            -- ▼ sort_no = 470 専用処理
            WHEN r.sort_no = 470 THEN
                 (CASE
                      WHEN r.rn = 1
                      THEN  r.log_target
                            || repeat('' '',
                               GREATEST(0, 22 - (
                                     length(r.log_target)
                                   + length(regexp_replace(r.log_target,''[\x01-\x7E\｡-ﾟ]'','''',''g''))
                               )))
                            || CASE
                                   WHEN m.show_weekday AND o.treat_type IN (1, 2, 3)
                                       THEN ''：['' || COALESCE(r.treatment_weekday,'''') || ''曜日]''
                                   ELSE ''：''
                               END
                      ELSE  repeat('' '',24)
                  END)
                  || COALESCE(r.log_class,'''') || ''→''
                  || c470.body_fmt                 -- 整形済み本文
            -- ▼ それ以外
            ELSE
                 (CASE
                      WHEN r.rn = 1
                      THEN  r.log_target
                            || repeat('' '',
                               GREATEST(0, 22 - (
                                     length(r.log_target)
                                   + length(regexp_replace(r.log_target,''[\x01-\x7E\｡-ﾟ]'','''',''g''))
                               )))
                      ELSE  repeat('' '',24)
                  END)
                  || CASE
                         WHEN r.rn = 1 AND m.show_weekday AND o.treat_type IN (1, 2, 3)
                             THEN ''：['' || COALESCE(r.treatment_weekday,'''') || ''曜日]''
                         WHEN r.rn = 1
                             THEN ''：''
                         ELSE ''''
                     END
                  || COALESCE(r.log_class,'''') || ''→''
                  || regexp_replace(r.log_content, E''\r?\n'', '' '', ''g'') -- 改行→空白
        END
        || CHR(10)
        ) AS part
    FROM   ranked r
    JOIN   sort_map m USING(sort_no)
    LEFT   JOIN cte_460 c460
           ON c460.sort_no = r.sort_no AND c460.rn = r.rn
    LEFT   JOIN cte_470 c470
           ON c470.sort_no = r.sort_no AND c470.rn = r.rn
    JOIN   ord_main_cte o ON TRUE
    WHERE  COALESCE(r.log_target,'''') <> ''''
),

-- 9) sort_no = 460, 470 のコメント行を末尾へ集約 -------------------
detail_comment_460 AS (
    SELECT 999 + r.rn AS seq_adj,        -- 本文より後ろに並ぶ番号
           0         AS item_id,
           repeat('' '',24) ||
           CASE WHEN r.rn = 1 THEN ''[コメント]'' ELSE ''          '' END ||
           c460.comment_val || CHR(10) AS part      -- 1 行目のみラベル付き
    FROM   cte_460 c460
    JOIN   ranked r USING(sort_no, rn)
),
detail_comment_470 AS (
    SELECT 999 + r.rn AS seq_adj,        -- 本文より後ろに並ぶ番号
           0         AS item_id,
           repeat('' '',24) ||
           CASE WHEN r.rn = 1 THEN ''[コメント]'' ELSE ''          '' END ||
           c470.comment_val || CHR(10) AS part      -- 1 行目のみラベル付き
    FROM   cte_470 c470
    JOIN   ranked r USING(sort_no, rn)
),

-- 10) ヘッダ + 本文 + コメント を結合 -------------------------
log_parts_raw AS (
    SELECT seq, item_id, part FROM header_parts
    UNION ALL
    SELECT seq_adj, item_id, part FROM detail_body
    UNION ALL
    SELECT seq_adj, item_id, part FROM detail_comment_460
    UNION ALL
    SELECT seq_adj, item_id, part FROM detail_comment_470
),

-- 11) 出力抑止対象の item_id を除外 --------------------------
log_parts AS (
    SELECT p.seq, p.part
    FROM   log_parts_raw p
    JOIN   not_send_items n ON TRUE
    WHERE  p.item_id = 0                -- ヘッダは常に出力
       OR  NOT (p.item_id = ANY(n.ids)) -- 抑止 ID に含まれない本文
)

-- 12) 最終テキストを連結 ------------------------------------
SELECT RTRIM(string_agg(part, '''' ORDER BY seq), CHR(10)) AS karte_text
FROM   log_parts;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコム　指示変更履歴連携_カルテ記録テキスト取得', '2025-06-08 20:39:48.343', '2025-06-26 14:06:07.388', '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]'::jsonb);
