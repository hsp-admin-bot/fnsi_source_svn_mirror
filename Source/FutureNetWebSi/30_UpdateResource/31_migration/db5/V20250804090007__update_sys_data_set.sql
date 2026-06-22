DELETE FROM sys_data_set WHERE sql_cd IN (-1108001);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1108001, 'INSERT
    INTO
    pat_coop_detail(
        facility_cd,
        pat_id,
        save_1,
        save_2,
        is_disp,
        is_del,
        user_id,
        up_date,
        reg_date,
        coop_version
    )
SELECT
    @facilityCd,
    @patId::numeric,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''rep_dial'',
        ''ord_no'', @ordNo ::numeric,
        ''memo'', dump_path
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    @coopVersion
FROM
        sys_coop_journal
WHERE
        ctl_no = @ctlNo;', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Secom連携_レポート連携_送信履歴メモ', '2025-08-01 22:58:55.634', CURRENT_TIMESTAMP, NULL);