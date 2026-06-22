DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1102029, -1102030);

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
),
-- 最新の新規登録のsys_coop_journalを取得
get_sys_coop_journal AS (
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
  ORDER BY up_date DESC
  LIMIT 1
),
-- ファイル名を取得
file_names AS (
  SELECT u.ord AS id,
    u.path
  FROM get_sys_coop_journal j,
    UNNEST(j.path_array) WITH ORDINALITY AS u(path, ord)
),
-- 透析指示連携で生成されるファイル種類の列挙
file_sub_kinds(id, name) AS (
  VALUES (1, ''res''),
    (2, ''trt_index''),
    (3, ''trt_hader''),
    (4, ''trt_unit''),
    (5, ''trt_item''),
    (6, ''trt_null''),
    (7, ''inj_index''),
    (8, ''inj_header''),
    (9, ''inj_unit''),
    (10, ''inj_item''),
    (11, ''inj_null''),
    (12, ''med'')
),
-- ファイル名とファイル種類を結合
joined_files AS (
  SELECT fk.id,
    fk.name,
    fn.path
  FROM file_sub_kinds fk
    LEFT JOIN file_names fn ON fk.id = fn.id
),
-- SHIFT_JISにでコード（文字化け対策）
decoded AS (
  SELECT ctl_no,
    CONVERT_FROM(dump, ''SHIFT_JIS'') AS text_data
  FROM sys_coop_journal
  WHERE ctl_no = (
      SELECT ctl_no
      FROM get_sys_coop_journal
    )
),
-- dumpの内容をレコードにして出力
lines AS (
  SELECT l.ctl_no,
    ROW_NUMBER() OVER (
      PARTITION BY l.ctl_no
      ORDER BY ordinality
    ) AS rn,
    line
  FROM decoded l,
    LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
),
-- 再帰的にファイル名を伝播させる
parsed AS (
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

SELECT
  file_sub_kind,
  JSON_AGG(content_array)::TEXT AS content_json
FROM file_content_rows
where file_sub_kind = @fileSubKind
GROUP BY file_sub_kind
ORDER BY file_sub_kind;
-- SQL: -1102029 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 新規処理dump取得用', current_timestamp, current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102030, '-- SQL: -1102030 begin
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
    ''01'' AS detail_id,
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
-- SQL: -1102030 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼/注射依頼(削除電文用)', current_timestamp, current_timestamp, '[{"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);