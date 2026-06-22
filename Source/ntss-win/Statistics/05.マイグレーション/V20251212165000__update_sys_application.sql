DELETE FROM ntss.sys_application
WHERE path in ('\ntss-admin-web\src\main\frontend\public\application\download\StatisticsSetup.msi');
-- 初期データ登録
INSERT INTO sys_application VALUES ('2025年度JSDT統計調査アプリ','2.0.0.5','\ntss-admin-web\src\main\frontend\public\application\download\StatisticsSetup.msi',6,current_timestamp,current_timestamp);
