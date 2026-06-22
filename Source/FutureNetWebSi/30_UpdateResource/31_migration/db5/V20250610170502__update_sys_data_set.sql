DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101507);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101507, 'WITH params AS (
    SELECT
        @dataType::text AS dt ,
        @content::text  AS val
), violation AS (
    SELECT 1 AS violation
    FROM params
    WHERE
        (dt = ''01''
         AND NOT (val ~ ''^\s*[+-]?\d+(\.\d+)?\s*$''))

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
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコム　患者プロファイル　データタイプチェック', '2025-06-08 20:39:48.343', '2025-06-08 20:39:52.940', NULL);