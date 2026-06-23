DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 7;

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('7', '003', '帳票レイアウトデザイナーアプリケーション最新バージョン', '{"version": "1.0.0.16"}', '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する', '1', CURRENT_TIMESTAMP);