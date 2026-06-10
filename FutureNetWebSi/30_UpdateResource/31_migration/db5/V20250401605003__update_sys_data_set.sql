DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-310015);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310015, 'UPDATE
    pat_exam_main
SET
    is_lock = ''1''
WHERE
    exam_main_cd = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査依頼実績連携 検査依頼変更不可更新', '2023-11-21 23:54:57.716', '2023-11-21 23:54:57.716', NULL);