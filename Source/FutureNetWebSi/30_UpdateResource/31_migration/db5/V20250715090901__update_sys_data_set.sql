DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106005);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106005, 'WITH get_ocuurdate_seqno AS (
    --ファイルパスから送信日時取得
    SELECT
        SUBSTRING(dump_path FROM LENGTH(dump_path) - 20 FOR 8) AS occure_date,
        SUBSTRING(dump_path FROM LENGTH(dump_path) - 11 FOR 6) AS seq_no
    FROM
        sys_coop_journal scj
    WHERE
        scj.ctl_no = @ctlNo
)
INSERT
    INTO
    ntss.pat_coop_detail(
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
    @patId::integer,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''rad_main'',
        ''ord_no'', @ordNo ::int,
        ''memo'', (SELECT CONCAT(occure_date, ''|'', seq_no) FROM get_ocuurdate_seqno)
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    @coopVersion', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Secom連携_放射線オーダ連携_送信履歴メモ', '2025-07-14 21:24:14.285', CURRENT_TIMESTAMP, NULL);