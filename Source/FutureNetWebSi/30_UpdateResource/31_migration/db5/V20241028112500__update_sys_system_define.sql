DELETE FROM "ntss"."sys_system_define" where ctl_no = 38;

INSERT INTO "ntss"."sys_system_define" ( "ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date" )
VALUES
	( '38', '003', 'デフォルト帳票配置パス', '{"path": "/efs/default_report"}', '施設追加時に登録するデフォルト帳票配置パス。', '1', NOW( ) );
