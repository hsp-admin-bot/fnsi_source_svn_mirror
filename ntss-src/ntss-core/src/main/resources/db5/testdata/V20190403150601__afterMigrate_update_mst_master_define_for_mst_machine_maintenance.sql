-- 装置マスタ mst_machine メンテナンスのためのデータ更新
update
  sys_master_define
  set
    combo_data = '{"combos": [{"values": [{"text": "DCS3(I)", "value": "I"}, {"text": "DBB3(J)", "value": "J"}, {"text": "DCG3(M)", "value": "M"}, {"text": "DBG3(N)", "value": "N"}, {"text": "DCG3(P)", "value": "P"}, {"text": "DBG3(Q)", "value": "Q"}, {"text": "DAB", "value": "A"}, {"text": "DAD", "value": "D"}, {"text": "DRO", "value": "R"}], "physical_name": "com_format_cd"}, {"values": [{"text": "なし", "value": "0"}, {"text": "あり", "value": "1"}], "physical_name": "is_ftp"}, {"values": [{"text": "新通信", "value": "1"}, {"text": "NX通信", "value": "2"}], "physical_name": "com_type"}, {"values": [{"text": "使用可能", "value": "0"}, {"text": "使用不可", "value": "1"}], "physical_name": "is_disable"}]}'

where
  master_physical_name = 'mst_machine'
;
