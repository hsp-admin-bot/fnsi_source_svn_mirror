DELETE FROM ntss.sys_data_set 
WHERE sql_cd IN (-1103013, -1103016, -1103017, -1103018, -1103019, -1103020, -1103021, -1103022);

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103013, '-- SQL: -1103013 begin
WITH ord_main_switch AS(
    -- ord_mainまたはord_main_restoreから、当連携処理のord_noに該当するの最新のレコードを取得する
    (
        SELECT TRUE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.rst_edition_date AS up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
            and is_del = ''0''
    )
    UNION
    (
        select FALSE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.del_date AS up_date_switch
        FROM ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY del_date DESC
        LIMIT 1
    )
    ORDER BY up_date_switch DESC NULLS LAST
    LIMIT 1
)
, inject_cancel_file_output_flg AS (
    -- 注射中止ファイル出力有無を判断するフラグを取得する
    SELECT CASE
            -- 処理対象ord_noに紐づく最新のオーダーがord_main_restoreから取得できた場合
            -- 注射中止ファイルを出力する
            WHEN oms.is_from_ord_main = FALSE THEN TRUE 
            -- それ以外の場合
            -- rst_dialysis_stateが存在して、ord_main_restore.del_dateよりも最新の場合（実績が更新されている）
            -- 注射中止ファイルを出力しない
            ELSE FALSE
        END AS value
    FROM ord_main_switch AS oms
)
, raw_data AS (
	SELECT @contentJson::jsonb AS data
)
, rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)
, get_rp_no AS (
    SELECT row ->> 8 AS rp_no
    FROM rows
)
SELECT
    ''01'' AS detail_id,
    rp_no AS rp_no
FROM get_rp_no
WHERE (select value from inject_cancel_file_output_flg)
    AND EXISTS (
    SELECT 1 FROM rows
    )
ORDER BY rp_no::int
-- SQL: -1103013 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射中止ファイル', '2025-08-01 15:43:21.288', '2025-08-05 12:21:25.294', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103016, '-- SQL: -1103016 begin
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
-- SQL: -1103016 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 新規処理dump取得用', '2025-07-24 22:27:41.417', '2025-07-31 17:30:38.167', NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103017, '-- SQL: -1103017 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
)
,rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- このSQLでは処置実績ファイルのファイル出力有無を判断します。
-- ファイル出力を行う場合は1件のレコードを返却します。
-- ファイル出力を行わない場合はレコードを返却しません。
SELECT 
    ''01'' AS detail_id
WHERE EXISTS (
  SELECT 1 FROM rows
);
-- SQL: -1103017 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績(削除電文用)', '2025-07-24 22:27:41.353', '2025-07-24 22:27:41.353', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103018, '-- SQL: -1103018 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
)
,rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- このSQLでは注射実績ファイルのファイル出力有無を判断します。
-- ファイル出力を行う場合は1件以上のレコードを返却します。
-- ファイル出力を行わない場合はレコードを返却しません。
-- このSQLに指定できるfileSubKindには''inj_index''を指定してください。
-- 注射実績のオーダーインデックスの9番目の要素を参照し、RP番号を出力します。
SELECT 
    ''01'' AS detail_id,
    (row ->> 8)::numeric AS rp_no
FROM rows
WHERE EXISTS (
  SELECT 1 FROM rows
)
order by rp_no;
-- SQL: -1103018 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績(削除電文用)', '2025-08-05 10:51:12.178', '2025-08-05 10:51:12.178', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103019, '-- SQL: -1103019 begin
-- このSQLは、透析実績連携の最新の新規処理によって生成されたファイルの内容を出力します。
-- recordタグのSqlCodeに指定する形で使用してください。
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
-- SQL: -1103019 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 行取得用(削除電文用)', '2025-07-24 22:27:41.353', '2025-07-24 22:27:41.353', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103020, '-- SQL: -1103020 begin
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
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 項目取得用(削除電文用)', '2025-08-05 10:51:12.178', '2025-08-05 10:51:12.178', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103021, '-- SQL: -1103021 begin
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
FROM rows
where row->>@conditionTargetColNo = @conditionValue::text;
-- SQL: -1103021 end
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績 行取得用(削除電文用)', '2025-08-05 10:51:12.178', '2025-08-05 10:51:12.178', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103022, '-- SQL: -1103022 begin
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
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績 項目取得用(削除電文用)', '2025-08-05 10:51:12.178', '2025-08-05 10:51:12.178', '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);