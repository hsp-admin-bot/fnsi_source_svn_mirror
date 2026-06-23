DELETE FROM sys_facility_setting WHERE facility_setting_no = '1049';

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
  up_date
) VALUES(
  '1049',
  '導入期加算算定条件',
  '1',
  4,
  '[{"id":"1", "name":"同月内"},{"id":"2", "name":"日付計算"}]',
  '導入期加算',
  0,
  '「同月内」：導入開始日に登録された月と「同じ月」（その月の終わりの日まで）の透析日の透析実績に算定する。<br>
  「日付計算」：導入開始日に登録された日付のうち、「次の月の同じ日付ー１」までの透析日の透析実績に算定する。',
  49,
  now(),
  now()
);
