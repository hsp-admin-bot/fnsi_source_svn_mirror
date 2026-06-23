DELETE FROM sys_facility_setting WHERE facility_setting_no = '1055';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1056';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1057';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1058';

INSERT INTO sys_facility_setting(
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date,
  system_use_disp
) VALUES (
  '1055',
  '外部警報入力1 OFF時メッセージ変更',
  '外部警報入力1がOFFになりました',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報入力1」がOFFになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  55,
  now(),
  now(),
  '3'
), (
  '1056',
  '外部警報入力2 OFF時メッセージ変更',
  '外部警報入力2がOFFになりました',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報入力2」がOFFになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  56,
  now(),
  now(),
  '3'
), (
  '1057',
  '外部警報入力3 OFF時メッセージ変更',
  '外部警報入力3がOFFになりました',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報入力3」がOFFになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  57,
  now(),
  now(),
  '3'
), (
  '1058',
  '外部警報入力4 OFF時メッセージ変更',
  '外部警報入力4がOFFになりました',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報入力4」がOFFになった際のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  58,
  now(),
  now(),
  '3'
);