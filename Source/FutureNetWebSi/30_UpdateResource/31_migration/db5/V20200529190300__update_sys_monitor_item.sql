-- sys_monitor_item の KM-8900／KM-900 のビットデータ系項目 を 0:文字列(※装置よりHex文字列を受信) として再定義
update
  sys_monitor_item
set
  data_type = 0, up_date = now()
where
  moni_data_no in ('Z212', 'Z224', 'Z234', 'Z244', 'Z254', 'Z264', 'Z274', 'Z284', 'Z294', 'Z304', 'Z314', 'Z324', 'Z334');
