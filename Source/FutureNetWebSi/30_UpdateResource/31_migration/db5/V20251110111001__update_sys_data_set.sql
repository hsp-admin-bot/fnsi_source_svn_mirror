DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1100018);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100018, '-- SQL: -1100018 begin
WITH params AS (
    SELECT 
        CASE
            WHEN @coopCd in(''ind_dial'',''rst_dial'') THEN 2
            WHEN @coopCd in(''exam_ord'',''rad_ord'') THEN 1
        END AS coopCd
),
memo AS (
    SELECT
        split_part(save_2 ->> ''memo'', ''#'', coopCd) AS memo,
        split_part(save_2 ->> ''memo'', ''#'', coopCd+2) AS karte_memo
    FROM
        pat_coop_detail AS detail,params
    WHERE
        facility_cd = @facilityCd
        AND pat_id = @patId
        AND (save_2 ->> ''ord_no'')::integer = @ordNo
        AND (save_2 ->> ''coop_cd'') = @coopCd
    ORDER BY
        up_date DESC
    LIMIT 1
)
SELECT 
    TO_CHAR(
        TO_DATE(
            split_part(memo, ''|'', @position),
            ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            split_part(memo, ''|'', @position+1),
            ''HH24MISS''
        ), ''HH24:MI:SS''
    ) AS seq_no,
    TO_CHAR(
        TO_DATE(
            CASE
                WHEN @coopCd in(''ind_dial'',''rst_dial'')
                    THEN split_part(karte_memo, ''|'', @position)
            END , ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS k_send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            CASE
                WHEN @coopCd in(''ind_dial'',''rst_dial'')
                    THEN split_part(karte_memo, ''|'', @position+1)
            END, ''HH24MISS''
        ), ''HH24:MI:SS''
    ) AS k_seq_no
FROM
    memo
-- SQL: -1100018 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 送信履歴メモから発生日/SEQ番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
