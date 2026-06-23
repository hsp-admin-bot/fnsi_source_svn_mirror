-- #10934 データリストの行背景色がオレンジ色のスタイル修正
-- 治療予定・治療記録から「治療日」を除去
DELETE FROM sys_data_list_detail where data_list_detail_cd = 1404;
