UPDATE sys_master_define
SET combo_data ='{"combos": [{"values": [{"text": "日常点検", "value": "1"}, {"text": "定期点検", "value": "2"}], "physical_name": "mainte_class"}, {"values": [{"text": "0:日常点検", "value": "0"}, {"text": "1:定期点検", "value": "1"}, {"text": "2:チェック", "value": "2"}], "physical_name": "ans_pattern"}, {"values": [{"text": "0:コメントなし", "value": "0"}, {"text": "1:コメント要", "value": "1"}], "physical_name": "is_cmt"}]}',
    up_date = CURRENT_TIMESTAMP
WHERE master_physical_name = 'mst_mainte_detail';
