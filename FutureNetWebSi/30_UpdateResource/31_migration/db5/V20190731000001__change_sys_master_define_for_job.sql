-- 職種マスタ定義編集
update sys_master_define
set mode = 2,
column_info = '{
	"fields": [
		{
			"type": "number",
			"alias": "code",
			"title": "職種コード",
			"physical_name": "job_cd"
		},
		{
			"type": "string",
			"alias": "name",
			"title": "職種名",
			"validation": {
				"required": "true",
				"maxlength": 40
			},
			"physical_name": "job_name"
		},
		{
			"type": "combo1",
			"title": "医師フラグ",
			"physical_name": "is_doctor"
		},
		{
			"type": "json",
			"title": "デフォルトメニュー設定",
			"hidden": "true",
			"validation": {
				"required": "true"
			},
			"defaultValue": "{\"initial_menu_function\": \"005\", \"default_menu_functions\": [\"005\"]}",
			"physical_name": "default_menu_settings"
		},
		{
			"type": "modal",
			"title": "デフォルトメニュー設定",
			"physical_name": "default_menu_settings"
		},
		{
			"type": "string",
			"title": "デフォルト権限設定",
			"hidden": "true",
			"defaultValue": "[]",
			"physical_name": "default_authorized_authorities"
		},
		{
			"type": "modal",
			"title": "デフォルト権限設定",
			"physical_name": "default_authorized_authorities"
		},
		{
			"type": "disp",
			"title": "削除",
			"physical_name": "is_disp"
		}
	]
}'
where master_physical_name = 'mst_job';