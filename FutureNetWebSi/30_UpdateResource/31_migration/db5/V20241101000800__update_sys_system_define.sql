DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 9;

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('9', '003', '印刷サーバーアプリケーション最新バージョン', '{"version": "1.0.0.2"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);
