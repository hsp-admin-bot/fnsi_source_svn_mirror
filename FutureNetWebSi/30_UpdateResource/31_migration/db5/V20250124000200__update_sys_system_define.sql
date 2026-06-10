DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 7;
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('7', '003', '帳票レイアウトデザイナーアプリケーション最新バージョン', '{"version": "1.1.0.8"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);


DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 35;
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('35', '003', 'データセット最新バージョン', '{"version": "1.1.0.4"}', 'データセット最新バージョン', '1', CURRENT_TIMESTAMP);
