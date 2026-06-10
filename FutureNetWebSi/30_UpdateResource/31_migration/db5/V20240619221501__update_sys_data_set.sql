DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2440)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2440, 'SELECT
    m_m.in_hospital_cd_1 AS deviceno            --装置番号
    , m_m.machine_name AS devicename     --装置名称
    , m_mr.machine_serial AS deviceserial --製造番号
    , to_char(m_mr.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
    , to_char(m_mr.event_reg_date, ''hh24mi'') AS meintetime   --測定時刻
    , m_mr.contents ->> ''47'' AS meinteresult                      --配管自己診断結果
    , '''' AS meintegen --減圧テスト
    , m_mr.contents ->> ''43'' AS meintemore  --配管系漏れ（陰圧)
    , m_mr.contents ->> ''44'' AS meinteymore --配管系漏れ（陽圧）
    , m_mr.contents ->> ''48'' AS meintejyo   --除水テスト
    , m_mr.contents ->> ''46'' AS meintebara  --バランステスト
    , m_mr.contents ->> ''45'' AS meinteetcf  --ＣＦフィルタ漏れ
    , m_mr.contents ->> ''49'' AS meinteetcf2 --ＣＦ２フィルタ漏れ
FROM
    mst_machine m_m
    INNER JOIN mnt_motion_record m_mr
        ON m_m.facility_cd = m_mr.facility_cd
        AND m_m.machine_type_cd = m_mr.machine_type_cd
        AND m_m.machine_serial = m_mr.machine_serial
WHERE
    m_m.facility_cd = @facilityCd
    AND @fromDate <= m_mr.event_reg_date AND m_mr.event_reg_date < @toDate
    AND m_mr.test_type = 1
    AND m_mr.contents IS NOT NULL
    AND m_mr.contents <> ''{}'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
