DELETE FROM "ntss"."sys_system_define" where ctl_no in (1013);
INSERT INTO "ntss"."sys_system_define" ("ctl_no", "service_cd", "name", "value", "description", "is_enable", "up_date") VALUES ('1013', '003', 'フォント設定', '{"default": "IPAexゴシック", "fontconfig": [{"alias": {"from": [{"family": "STHupo"}, {"family": "Forte"}], "family": "BIZ UDPゴシック"}}, {"alias": {"from": [{"family": "STCaiyun"}], "family": "HG創英角ﾎﾟｯﾌﾟ体"}}]}', 'フォント設定', '1', CURRENT_TIMESTAMP);

