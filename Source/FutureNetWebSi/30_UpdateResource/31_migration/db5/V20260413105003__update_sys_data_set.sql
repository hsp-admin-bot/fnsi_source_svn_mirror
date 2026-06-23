DELETE FROM ntss.sys_data_set WHERE sql_cd=-604185;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-604185, '-- 【SQL_CD=-604185】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
memo_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        memo_node
    FROM (
        -- unnest を先にサブクエリで展開してから row_number を振る
        SELECT unnest(xpath(''//RST_RECEIPT_MEMO_HST'', dump_xml)) AS memo_node
        FROM latest_journal
    ) expanded
)
SELECT
    seq,
    (xpath(''//RST_RECEIPT_MEMO_HST/@NAME'',
        (''<root>'' || memo_node::text || ''</root>'')::xml
    ))[1]::text AS detail_id,
    (xpath(''//DIVISION/text()'', memo_node))[1]::text AS division,
    (xpath(''//ADD_FLG/text()'', memo_node))[1]::text AS is_dial_diff,
    (xpath(''//MAIN_DIAL_DIFF/text()'', memo_node))[1]::text AS is_main,
    (xpath(''//ITEM_NAME/text()'', memo_node))[1]::text AS dialysis_difficulty_name
FROM memo_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_RECEIPT_MEMO_HST)', current_timestamp, current_timestamp, NULL);