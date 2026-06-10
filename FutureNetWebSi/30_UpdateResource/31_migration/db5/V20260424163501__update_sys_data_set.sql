DELETE FROM ntss.sys_data_set WHERE sql_cd=-1102033;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102033, '-- SQL:-1102033
WITH raw_data AS (
    SELECT @contentJson::jsonb AS data
),
rows AS (
    SELECT JSONB_ARRAY_ELEMENTS(data) AS row
    FROM raw_data
)
,memo_text AS (
	SELECT
	  save_2->>''memo'' AS memo
	FROM
	  pat_coop_detail
	WHERE
	  pat_id = @patId
	  AND save_2->>''coop_cd'' = ''ind_dial''
	  AND pat_coop_detail.facility_cd = @facilityCd
	  AND save_2->>''ord_no'' = @ordNo::text
	ORDER BY
	  up_date DESC
	LIMIT 1
)
,memo_parts AS (
    SELECT UNNEST(STRING_TO_ARRAY(memo, ''#'')) AS line
    FROM memo_text
)
,i_record AS (
    SELECT STRING_TO_ARRAY(line, ''|'') AS parts
    FROM memo_parts
    WHERE line LIKE ''I|%''
)
,i_has_item AS (
    -- 項目情報(6つ目の要素)の存在有無を返却する
    SELECT (parts[6] IS NOT NULL AND parts[6] <> '''') AS has_item
    FROM i_record
)

SELECT
    ''01'' AS detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no,
    @time AS time   
WHERE (1 = 1
        AND @dumpResult::TEXT = ''1'' 
        AND EXISTS (SELECT 1 FROM rows)
    ) 
    OR @dumpResult::TEXT = ''''
    AND (SELECT has_item FROM i_has_item) = TRUE;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼(削除電文用)', current_timestamp, current_timestamp, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);