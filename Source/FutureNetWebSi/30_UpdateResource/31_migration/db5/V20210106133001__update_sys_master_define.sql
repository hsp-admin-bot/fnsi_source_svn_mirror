--治療状況透析液調製装置グラフレイアウトマスタ  詳細ページ項目の追加
UPDATE ntss.sys_master_define
SET combo_data='{"combos":[{"values":[{"text":"DRO","value":"001"},{"text":"DAB","value":"002"},{"text":"DAD","value":"003"},{"text":"DRY_A","value":"006"},{"text":"DRY_B","value":"007"}],"physical_name":"model"}]}'
WHERE master_physical_name='mst_trend_graph_template';