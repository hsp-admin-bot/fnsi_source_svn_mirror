DELETE FROM sys_facility_setting WHERE facility_setting_no = '2003';

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
  '2003',
  '治療時間判定時間（分）',
  '60',
  2,
  '[{"min":"0",  "max":"999"}]',
  'デバイスエッジ',
  0,
  '装置とデバイスエッジの通信断から復帰時、装置が運転中で治療開始時刻＋実績治療時間＋治療時間判定時間を経過していた場合、治療を終了して未登録運転に移行します。',
  68,
  now(),
  now(),
  '2'
);
