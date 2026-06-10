--検査項目マスタ詳細画面　対象外　→　表示しない 対象　　→　表示する
UPDATE ntss.sys_master_define 	
SET combo_data = '{"combos": [{"values": [{"text": "文字", "value": "0"}, {"text": "数値", "value": "1"}], "physical_name": "data_type"}, {"values": [{"text": "共通", "value": "0"}, {"text": "男女", "value": "1"}], "physical_name": "normal_value_class"}, {"values": [{"text": "表示しない", "value": "0"}, {"text": "表示する", "value": "1"}], "physical_name": "console_class"}, {"values": [{"text": "検査項目", "value": "0"}, {"text": "システム標準計算項目", "value": "1"}, {"text": "検査計算項目", "value": "2"}], "physical_name": "exam_class"}, {"values": [{"text": "未使用", "value": "0"}, {"text": "BUN", "value": "1"}, {"text": "血清Ca濃度", "value": "2"}, {"text": "血清アルブミン", "value": "3"}, {"text": "クレアチニン", "value": "4"}, {"text": "血清鉄", "value": "5"}, {"text": "総鉄結合能", "value": "6"}, {"text": "ヘマトクリット", "value": "7"}, {"text": "検査計算使用", "value": "8"}], "physical_name": "default_calc_exam_item_cd"}]}'
WHERE master_physical_name='mst_exam_item';	

