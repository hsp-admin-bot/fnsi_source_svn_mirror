DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1102033);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102033, 'WITH raw_data AS (
    SELECT @contentJson::jsonb AS data
),
rows AS (
    SELECT JSONB_ARRAY_ELEMENTS(data) AS row
    FROM raw_data
)
SELECT
    ''01'' AS detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no   
WHERE (1 = 1
        AND @dumpResult::TEXT = ''1'' 
        AND EXISTS (SELECT 1 FROM rows)
    ) 
    OR @dumpResult::TEXT = ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼(削除電文用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]'::jsonb);
