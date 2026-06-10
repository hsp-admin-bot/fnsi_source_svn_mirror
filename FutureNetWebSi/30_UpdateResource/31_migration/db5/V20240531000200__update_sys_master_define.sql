-- add 10378 by kangjie 20240523  start
UPDATE sys_master_define
SET column_info = jsonb_set ( column_info, '{fields}', column_info->'fields' ||'[{
	"type": "combo1",
	"alias": null,
	"title": "スケジュール延長除外",
	"format": null,
	"hidden": "false",
	"editable": "true",
	"validation": {
	"max": null,
	"min": null,
	"required": null,
	"maxlength": null
	},
	"physical_name": "is_schext_exception"
}]', TRUE ),
    combo_data = jsonb_set ( combo_data, '{combos}', combo_data->'combos' || '[{
	"values": [
	{
	"text": " ",
	"value": "0"
	},
	{
	"text": "除外",
	"value": "1"
	}
	],
	"physical_name": "is_schext_exception"
}]', TRUE )
WHERE
  master_physical_name = 'mst_facility';
-- add 10378 by kangjie 20240523  end
