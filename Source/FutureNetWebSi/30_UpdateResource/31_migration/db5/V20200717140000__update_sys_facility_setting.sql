update
  sys_facility_setting
set
  setting_name = '外部警報入力1 ON時メッセージ変更',
  default_value = '外部警報入力1がONになりました',
  description = '装置記録「外部警報入力1」がONになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  up_date = now()
where
  facility_setting_no = '1051';

update
  sys_facility_setting
set
  setting_name = '外部警報入力2 ON時メッセージ変更',
  default_value = '外部警報入力2がONになりました',
  description = '装置記録「外部警報入力2」がONになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  up_date = now()
where
  facility_setting_no = '1052';

update
  sys_facility_setting
set
  setting_name = '外部警報入力3 ON時メッセージ変更',
  default_value = '外部警報入力3がONになりました',
  description = '装置記録「外部警報入力3」がONになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  up_date = now()
where
  facility_setting_no = '1053';

update
  sys_facility_setting
set
  setting_name = '外部警報入力4 ON時メッセージ変更',
  default_value = '外部警報入力4がONになりました',
  description = '装置記録「外部警報入力4」がONになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  up_date = now()
where
  facility_setting_no = '1054';
