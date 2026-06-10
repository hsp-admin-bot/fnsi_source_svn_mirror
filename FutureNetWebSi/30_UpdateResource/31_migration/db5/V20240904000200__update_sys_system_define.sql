DELETE FROM "ntss"."sys_system_define" WHERE ctl_no = 35;

INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('35', '003', 'データセット最新バージョン', '{"version": "1.0.0.1"}', 'データセット最新バージョン', '1', CURRENT_TIMESTAMP);
