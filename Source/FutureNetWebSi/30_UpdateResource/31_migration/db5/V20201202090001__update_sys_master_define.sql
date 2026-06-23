UPDATE ntss.sys_master_define
	SET master_name='薬効換算マスタ'
	WHERE master_physical_name='mst_medicine_group';

UPDATE ntss.sys_master_define
	SET master_name='治療状況透析液調製装置トレンドレイアウトマスタ'
	WHERE master_physical_name='mst_trend_graph_monitor_set';

UPDATE ntss.sys_master_define
	SET master_name='治療状況透析液調製装置グラフレイアウトマスタ'
	WHERE master_physical_name='mst_trend_graph_template';

