DELETE FROM ntss.sys_data_set WHERE sql_cd in (-1102029);

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102029, '-- SQL: -1102029 begin
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
-- SQL: -1102029 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 新規処理dump取得用', '2025-07-24 22:27:41.417', current_timestamp, NULL);