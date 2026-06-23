DELETE FROM "ntss"."sys_system_define" WHERE ctl_no in (8 ,15);
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('8', '003', '体重計アプリケーション最新バージョン', '{"version": "1.0.0.6"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('15', '003', 'カードアクセスアプリケーション', '{"version": "1.0.0.6"}', 'カードアクセスアプリケーション', '1', CURRENT_TIMESTAMP);
