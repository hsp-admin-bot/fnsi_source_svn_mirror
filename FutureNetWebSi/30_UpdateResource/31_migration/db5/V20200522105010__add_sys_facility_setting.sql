insert
into sys_facility_setting(
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
  up_date
) values (
  '1047',
  'シェーマ機能スタンプ定型文字',
  E'Ｖ\r\nA\r\n良好\r\n不良\r\n狭窄\r\n閉塞\r\n禁止',
  6,
  '',
  '患者イベント',
  0,
  'シェーマ機能のフォントスタンプで選択できる定型文字を設定する。<br>改行で複数項目登録できる。',
  47,
  now(),
  now()
);