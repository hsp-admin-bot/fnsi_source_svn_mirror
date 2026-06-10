DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2440)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2440, 'SELECT
    ntss_db5_mst_m.in_hospital_cd_1 AS deviceno            --装置番号
    , ntss_db5_mnt_ms.machine_name AS devicename     --装置名称
    , ntss_db5_mnt_mr.machine_serial AS deviceserial --製造番号
    , to_char(ntss_db5_mnt_mr.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
    , to_char(ntss_db5_mnt_mr.event_reg_date, ''hh24mi'') AS meintetime   --測定時刻
    , ntss_db5_mnt_mr.contents ->> ''47'' AS meinteresult                      --配管自己診断結果
    , '''' AS meintegen --減圧テスト
    , ntss_db5_mnt_mr.contents ->> ''43'' AS meintemore  --配管系漏れ（陰圧)
    , ntss_db5_mnt_mr.contents ->> ''44'' AS meinteymore --配管系漏れ（陽圧）
    , ntss_db5_mnt_mr.contents ->> ''48'' AS meintejyo   --除水テスト
    , ntss_db5_mnt_mr.contents ->> ''46'' AS meintebara  --バランステスト
    , ntss_db5_mnt_mr.contents ->> ''45'' AS meinteetcf  --ＣＦフィルタ漏れ
    , ntss_db5_mnt_mr.contents ->> ''49'' AS meinteetcf2 --ＣＦ２フィルタ漏れ
FROM
    mst_machine ntss_db5_mst_m
    INNER JOIN mnt_motion_record ntss_db5_mnt_mr
        ON ntss_db5_mst_m.facility_cd = ntss_db5_mnt_mr.facility_cd
        AND ntss_db5_mst_m.machine_type_cd = ntss_db5_mnt_mr.machine_type_cd
        AND ntss_db5_mst_m.machine_serial = ntss_db5_mnt_mr.machine_serial
    INNER JOIN mnt_machine_state ntss_db5_mnt_ms
        ON ntss_db5_mst_m.facility_cd = ntss_db5_mnt_ms.facility_cd
        AND ntss_db5_mst_m.machine_type_cd = ntss_db5_mnt_ms.machine_type_cd
        AND ntss_db5_mst_m.machine_serial = ntss_db5_mnt_ms.machine_serial
WHERE
    ntss_db5_mst_m.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_mnt_mr.event_reg_date AND ntss_db5_mnt_mr.event_reg_date < @toDate
    AND ntss_db5_mnt_mr.test_type = 1
    AND ntss_db5_mnt_mr.contents IS NOT NULL
    AND ntss_db5_mnt_mr.contents <> ''{}'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
