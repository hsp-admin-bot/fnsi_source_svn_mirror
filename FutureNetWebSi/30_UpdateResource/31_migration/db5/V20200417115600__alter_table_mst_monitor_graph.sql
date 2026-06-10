-- 治療記録モニタグラフマスタの表示項目定義のデータ型を integer から character varying(5) に変更する
alter table mst_monitor_graph alter column left_data_index type character varying(5);
alter table mst_monitor_graph alter column right_data_index type character varying(5);