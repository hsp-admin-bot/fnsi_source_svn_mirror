-- #11124 酸素飽和度対応
-- モニタデータ削除
DELETE from ntss.sys_monitor_item where moni_data_no = '105';
