update sys_master_define set combo_data =
'{"combos": [{"values": [{"text": "両方", "value": "0"}, {"text": "左", "value": "1"}, {"text": "右", "value": "2"}, {"text": "なし", "value": "3"}, {"text": "不明", "value": "-"}], "physical_name": "va_direct"}]}'
where master_physical_name ='mst_va';

