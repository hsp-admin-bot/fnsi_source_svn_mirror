DELETE FROM sys_facility_setting WHERE facility_setting_no = '1051';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1052';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1053';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1054';

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
  '1051',
  '外部警報1メッセージ変更',
  '外部警報1',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報1」のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  51,
  now(),
  now(),
  '3'
), (
  '1052',
  '外部警報2メッセージ変更',
  '外部警報2',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報2」のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  52,
  now(),
  now(),
  '3'
), (
  '1053',
  '外部警報3メッセージ変更',
  '外部警報3',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報3」のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  53,
  now(),
  now(),
  '3'
), (
  '1054',
  '外部警報4メッセージ変更',
  '外部警報4',
  1,
  '',
  '遠隔監視',
  0,
  '装置記録「外部警報4」のメッセージを設定した文字列に変換して、警報通知メール送信と遠隔監視画面の表示をします。',
  54,
  now(),
  now(),
  '3'
);