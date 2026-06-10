DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 36;

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('36', '003', '帳票モデル最新バージョン', '{"version": "1.1.0.0"}', '帳票モデル最新バージョン', '1', CURRENT_TIMESTAMP);
