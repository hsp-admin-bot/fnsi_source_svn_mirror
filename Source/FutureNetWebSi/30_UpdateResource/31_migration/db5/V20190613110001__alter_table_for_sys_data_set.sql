-- データセット.SQL のデータ長を無制限に変更
ALTER TABLE sys_data_set ALTER COLUMN sql TYPE character varying;
