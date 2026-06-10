DELETE FROM sys_facility_setting WHERE facility_setting_no = '1061';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1062';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1063';

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
  '1061',
  'サインイン失敗時のアカウントロック',
  '1',
  4,
  '[{"id":"0","name":"0:アカウントロックしない"},{"id":"1","name":"1:アカウントロックする"}]',
  'サインイン',
  0,
  '連続サインイン失敗時のアカウントロック設定。<br>
  【アカウントロックしない】<br>
  　連続サインイン失敗してもアカウントロックは行いません。<br>
  【アカウントロックする】<br>
  　サインイン失敗回数が設定したサインイン失敗許容回数に達した場合、<br>
  　アカウントロックを行います。',
  61,
  now(),
  now(),
  '3'
), (
  '1062',
  'サインイン失敗許容回数',
  '5',
  2,
  '[{"min":"1",  "max":"99"}]',
  'サインイン',
  0,
  'アカウントロックとするサインイン失敗許容回数の設定。<br>
  1回～99回の設定が可能。<br>
（初期値：5回）',
  62,
  now(),
  now(),
  '3'
), (
  '1063',
  '2要素認証失敗許容回数',
  '5',
  2,
  '[{"min":"1",  "max":"99"}]',
  'サインイン',
  0,
  '再度サインインさせるための2要素認証失敗許容回数の設定。<br>
  1回～99回の設定が可能。<br>
（初期値：5回）',
  63,
  now(),
  now(),
  '3'
);