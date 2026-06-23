DELETE FROM "ntss"."sys_system_define" WHERE ctl_no IN (1001, 1002, 1003, 1004, 1005, 1010);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1001', '003', '帳票レイアウトデザイナーアプリケーションログ出力先', '{"path": "/efs/{0}/{1}/帳票レイアウトデザイナー/"}', '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', CURRENT_TIMESTAMP);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1002', '003', '体重計アプリケーションログ出力先', '{"path": "/efs/{0}/{1}/体重計アプリ/"}', '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', CURRENT_TIMESTAMP);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1003', '003', '印刷サーバーアプリケーションログ出力先', '{"path": "/efs/{0}/{1}/印刷サーバーアプリ/"}', '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', CURRENT_TIMESTAMP);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1004', '003', '浄化装置通信アプリケーションログ出力先', '{"path": "/efs/{0}/{1}/特殊浄化通信アプリ/"}', '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', CURRENT_TIMESTAMP);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1005', '003', '不明アプリケーションログ出力先', '{"path": "/efs/system/{1}/不明なアプリケーション/"}', '定義外アプリケーションのログファイル出力先を指定する。', '1', CURRENT_TIMESTAMP);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1010', '003', 'カード読み取りアプリケーションログ出力先', '{"path": "/efs/{0}/{1}/FNSiカードアプリ/"}', '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', CURRENT_TIMESTAMP);

DELETE FROM "ntss"."sys_system_define" WHERE ctl_no in (1012);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1012', '003', 'CONVERTエッジログPath', '{"path": "/efs/{0}/{1}/コンバータアプリ/"}', 'CONVERTエッジログPath', '1', CURRENT_TIMESTAMP);

DELETE FROM "ntss"."sys_system_define" WHERE ctl_no in (1006);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1006', '003', 'デバイスエッジログ出力先', '{"path": "/efs/{0}/{1}/デバイスエッジログ"}', 'デバイスエッジのログファイル出力先を指定する。 ※{0}は施設コードに変換/{1}は日付に変換', '1', CURRENT_TIMESTAMP);

DELETE FROM "ntss"."sys_system_define" WHERE ctl_no in (27);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('27', '003', 'アプリケーションログ', '{"out_flg": "ntss-admin-web=1,ntss-client-comm=1,ntss-web-api=1,ntss-coop-api=1,device_edge=1,ntss-m-notice=1,device_edge_updater=1,data_gathering=1,data_gathering_auto=1,alive_moni=1,alive_moni_auto=1", "path_output": "/efs/{0}/today/サーバー/{1}/{2}/{0}_{2}_{1}.log", "file_pattern": "/efs/{0}/%d''{''yyyyMMdd''}''/サーバー/{1}/{2}/{0}_{2}_{1}_%d''{''yyyyMMdd''}_%i''.log.gz", "max_file_size": "100"}', 'アプリケーションログの出力パスとファイル命名規則の設定。', '1', CURRENT_TIMESTAMP);

DELETE FROM "ntss"."sys_system_define" WHERE ctl_no in (1007);

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1007', '003', 'IFエッジログPath', '{"path": "/efs/{0}/{1}/IFエッジログ/"}', 'IFエッジログPath', '0', CURRENT_TIMESTAMP);
