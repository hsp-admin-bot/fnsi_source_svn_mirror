DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 15;

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('15', '003', 'カードアクセスアプリケーション', '{"version": "1.1.0.0"}', 'カードアクセスアプリケーション', '1', CURRENT_TIMESTAMP);
