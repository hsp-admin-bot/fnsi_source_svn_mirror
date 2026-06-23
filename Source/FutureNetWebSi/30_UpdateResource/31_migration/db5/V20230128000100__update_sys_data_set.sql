delete from sys_data_set where sql_cd in ('-99995', '-99990');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-99990, e'WITH journal AS (
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, \'YYYYMMDD\') = TO_CHAR(coop1.reg_date, \'YYYYMMDD\') 
        AND coop2.coop_cd = coop1.coop_cd
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        AND coop2.coop_version = coop1.coop_version
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
-- add 2023-01-28 bug #8134 exam_ord連携 検査依頼一覧画面で複数区分の検査をオーダすると1電文しか出力されない zhaoqi start
        AND coop1.ctl_no <= @ctlNo
-- add 2023-01-28 bug #8134 exam_ord連携 検査依頼一覧画面で複数区分の検査をオーダすると1電文しか出力されない zhaoqi end
    )
) 
SELECT \'Dialysis\' || to_char(CURRENT_TIMESTAMP, \'YYYYMMDDHH24MISS\') || TO_CHAR((journal.CNT - 1)%1000, \'FM099\') || \'.txt\' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', null, '日機装 透析実績[送信]ファイル名取得(拡張)', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-99995, e'WITH journal AS ( 
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, \'YYMMDD\') = TO_CHAR(coop1.reg_date, \'YYMMDD\') 
        AND coop2.coop_cd = coop1.coop_cd
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        AND coop2.coop_version = coop1.coop_version
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
-- add 2023-01-28 bug #8134 exam_ord連携 検査依頼一覧画面で複数区分の検査をオーダすると1電文しか出力されない zhaoqi start
        AND coop1.ctl_no <= @ctlNo
-- add 2023-01-28 bug #8134 exam_ord連携 検査依頼一覧画面で複数区分の検査をオーダすると1電文しか出力されない zhaoqi end
    )
) 
SELECT to_char(CURRENT_TIMESTAMP, \'YYMMDD\') || \'_\' || TO_CHAR((journal.CNT - 1)%100, \'FM09\') || \'.txt\' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', null, 'Medicom検査オーダファイル名取得', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, null);
