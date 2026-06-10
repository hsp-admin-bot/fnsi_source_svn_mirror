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
  '1048',
  '複数端末同時サインイン',
  '0',
  4,
  '[{"id":"0","name":"0:無効"},{"id":"1","name":"1:有効"}]',
  'サインイン',
  0,
  '複数端末で同一アカウント同時ログインの可否を切り替えます。<br>無効にすると、サインイン状態で別端末からサインインをした場合に、サインイン端末が既に存在することを案内し、「現在の端末サインインしない」か「既にサインインされている端末を強制サインアウトして、現在の端末でサインインする」かを選ぶことができます。',
  48,
  now(),
  now()
);
