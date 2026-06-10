DELETE FROM sys_data_set WHERE sql_cd IN (-1101506);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101506, 'SELECT
    1
FROM
    sys_coop_journal
WHERE
    ctl_no = @ctlNo
    AND OCTET_LENGTH(dump) = @totalByte :: numeric;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　電文長チェック', '2025-06-07 18:22:20.053', CURRENT_TIMESTAMP, NULL);