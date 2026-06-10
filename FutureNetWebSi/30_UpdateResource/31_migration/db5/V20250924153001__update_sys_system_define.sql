DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 7;
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('7', '003', '帳票レイアウトデザイナーアプリケーション最新バージョン', '{"version": "2.0.0.13"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);
DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 11;
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('11', '003', '浄化装置通信アプリケーション最新バージョン', '{"version": "2.0.0.1"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);
