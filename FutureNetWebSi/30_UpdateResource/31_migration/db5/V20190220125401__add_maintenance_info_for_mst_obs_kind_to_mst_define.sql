-- mst_obs_kindのマスタメンテナンスを行う設定を追加
insert into ntss.sys_master_define(master_physical_name,master_name,disp_class,mode,allow_sort,allow_add_record,disp_order,column_info,combo_data,reg_date,up_date) values ('mst_obs_kind','観察記録カテゴリマスタ','2','1','1','1',10,'{
"fields": [
{"type":"number", "alias":"code", "title":"カテゴリコード", "physical_name":"kind_no"}
,{"type":"string", "alias":"name", "title":"カテゴリ名", "physical_name":"kind_name", "validation":{"required":true, "maxlength":40}}
,{"type":"combo1", "title":"区分", "physical_name":"kind_class", "validation":{"required":true}}
,{"type":"combo1", "title":"治療実績とのリンク有無", "physical_name":"is_link_ord_no", "validation":{"required":true}}
,{"type": "del", "title": "削除", "physical_name": "is_del"}
,{"type": "disp", "title": "削除", "physical_name": "is_disp"}
]
}
','{
"combos":[
{"physical_name":"kind_class", "values":[
{"value":"0", "text":"その他"}
,{"value":"1", "text":"SOAP"}
,{"value":"2", "text":"FDAR"}
]},
{"physical_name":"is_link_ord_no", "values":[
{"value":"0", "text":"なし"}
,{"value":"1", "text":"あり"}
]}
]
}',now(),now());