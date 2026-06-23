--一般撮影検査依頼 前回検査日設定
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
  '3011',
  '前回検査日設定',
  '1',
  4,
  '[{"id":"1","name":"1：直近過去の一般撮影検査予定日"},{"id":"2","name":"2：最新のCTRを含む身体情報の測定日＋CTR値"}]',
  '一般撮影検査依頼',
  0,
  '一般撮影検査依頼の前回検査日のデータ取得元と表示場所を切り替えます。</br>１：本日から見て直近過去の一般撮影検査予定日を各検査項目行に表示します。<br>２：最新のCTRを含む身体情報の測定日＋CTR値を患者氏名行に表示します。',
  111,
  now(),
  now(),
  '3'
);