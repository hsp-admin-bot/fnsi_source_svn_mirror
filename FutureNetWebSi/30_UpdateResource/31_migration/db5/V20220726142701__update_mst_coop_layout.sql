DELETE 
FROM
	"ntss"."mst_coop_layout" 
WHERE
	ctl_no IN ( - 1010009,- 1010008,- 1010014, -1030005 );
INSERT INTO "ntss"."mst_coop_layout" (
	"ctl_no",
	"facility_cd",
	"coop_cd",
	"coop_cd_index",
	"direction",
	"coop_cd_sub",
	"coop_format",
	"coop_name",
	"coop_vender",
	"description",
	"is_editable",
	"coop_setting",
	"coop_ext_setting",
	"is_disp",
	"is_del",
	"user_id",
	"reg_date",
	"up_date" 
)
VALUES
	(
		- 1010009,
		'nkknkk',
		'rep_dial',
		'pdf',
		'S',
		'cre',
		'pdf',
		'日機装 透析レポート(pdf)',
		'日機装',
		'テスト用report',
		'1',
		'<rootnode></rootnode>',
		NULL,
		'1',
		'0', - 1,
		'2021-09-01 07:38:44.069',
		CURRENT_TIMESTAMP 
	);
INSERT INTO "ntss"."mst_coop_layout" (
	"ctl_no",
	"facility_cd",
	"coop_cd",
	"coop_cd_index",
	"direction",
	"coop_cd_sub",
	"coop_format",
	"coop_name",
	"coop_vender",
	"description",
	"is_editable",
	"coop_setting",
	"coop_ext_setting",
	"is_disp",
	"is_del",
	"user_id",
	"reg_date",
	"up_date" 
)
VALUES
	(
		- 1010008,
		'nkknkk',
		'rep_dial',
		'pdf',
		'S',
		'upd',
		'pdf',
		'日機装 透析レポート(pdf)',
		'日機装',
		'テスト用report',
		'1',
		'<rootnode></rootnode>',
		NULL,
		'1',
		'0', - 1,
		'2021-09-01 07:38:44.069',
		CURRENT_TIMESTAMP 
	);
INSERT INTO "ntss"."mst_coop_layout" (
	"ctl_no",
	"facility_cd",
	"coop_cd",
	"coop_cd_index",
	"direction",
	"coop_cd_sub",
	"coop_format",
	"coop_name",
	"coop_vender",
	"description",
	"is_editable",
	"coop_setting",
	"coop_ext_setting",
	"is_disp",
	"is_del",
	"user_id",
	"reg_date",
	"up_date" 
)
VALUES
	(
		- 1010014,
		'nkknkk',
		'rep_dial',
		'pdf',
		'S',
		'del',
		'pdf',
		'日機装 透析レポート(pdf)',
		'日機装',
		'テスト用report',
		'1',
		'<rootnode></rootnode>',
		NULL,
		'1',
		'0', - 1,
		'2022-07-04 12:22:10.543',
		CURRENT_TIMESTAMP 
	);
INSERT INTO "ntss"."mst_coop_layout" (
	"ctl_no",
	"facility_cd",
	"coop_cd",
	"coop_cd_index",
	"direction",
	"coop_cd_sub",
	"coop_format",
	"coop_name",
	"coop_vender",
	"description",
	"is_editable",
	"coop_setting",
	"coop_ext_setting",
	"is_disp",
	"is_del",
	"user_id",
	"reg_date",
	"up_date" 
)
VALUES
	(
		- 1030005,
		'nkknkk',
		'profile',
		'send_time',
		'S',
		'cre',
		'xml',
		'日機装標準',
		'nikkiso',
		'患者情報（XML）[送信](定時)',
		'1',
		'<rootnode></rootnode>',
		'{"dataset": [{"sqlCode": -113, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}',
		'1',
		'0', - 1,
		'2021-09-01 07:38:44.069',
	CURRENT_TIMESTAMP 
	);