-- 透析装置
update sys_monitor_item set moni_data_name = 'ΔＢＶ' , moni_data_short_name = 'ΔBV' , up_date = current_timestamp where moni_data_no = '17';
update sys_monitor_item set moni_data_name = 'ΔBV低下警報点1' , moni_data_short_name = 'ΔBV低警1' , up_date = current_timestamp where moni_data_no = '49';
update sys_monitor_item set moni_data_name = 'ΔBV低下警報点2' , moni_data_short_name = 'ΔBV低警2' , up_date = current_timestamp where moni_data_no = '50';
update sys_monitor_item set moni_data_name = 'ΔBV変化率警報点' , moni_data_short_name = 'ΔBV変化' , up_date = current_timestamp where moni_data_no = '51';
update sys_monitor_item set moni_data_name = 'ΔBV変化率' , moni_data_short_name = 'ΔBV変化' , unit = '％/min' , up_date = current_timestamp where moni_data_no = '80';
update sys_monitor_item set moni_data_name = 'ΔBVリファレンスエリア上限' , moni_data_short_name = 'ΔBV上' , is_disp = '0' , up_date = current_timestamp where moni_data_no = '85';
update sys_monitor_item set moni_data_name = 'ΔBVリファレンスエリア下限' , moni_data_short_name = 'ΔBV下' , is_disp = '0' , up_date = current_timestamp where moni_data_no = '86';
update sys_monitor_item set moni_data_name = 'ΔBV5分平均値' , moni_data_short_name = 'ΔBV5平' , is_disp = '0' , up_date = current_timestamp where moni_data_no = '95';
update sys_monitor_item set moni_data_name = 'ΔBV最大最小を除いた5分平均値' , moni_data_short_name = 'ΔBV5平(大小除)' , is_disp = '0' , up_date = current_timestamp where moni_data_no = '96';
update sys_monitor_item set moni_data_name = 'ΔBV(BVplus)' , moni_data_short_name = 'ΔBVplus' , up_date = current_timestamp where moni_data_no = '100';
update sys_monitor_item set moni_data_name = '血液入口～静脈平均圧', moni_data_short_name = '血静平均', unit = 'mmHg', up_date = current_timestamp where moni_data_no = '16';
update sys_monitor_item set moni_data_name = 'PWI', moni_data_short_name = 'PWI', is_disp = '0', up_date = current_timestamp where moni_data_no = '81';
update sys_monitor_item set moni_data_name = '再循環率測定結果(BVMS連携用)', moni_data_short_name = '再循環率', is_disp = '0', up_date = current_timestamp where moni_data_no = '89';
