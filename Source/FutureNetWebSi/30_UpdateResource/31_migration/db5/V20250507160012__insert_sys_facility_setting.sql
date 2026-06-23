-- #11827 2025.05.20 add 仮想端末姓名結合設定 TDC米沢 start
-- 仮想端末姓名結合設定
DELETE FROM sys_facility_setting WHERE facility_setting_no='3134';
INSERT INTO sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES (
  '3134',
  '仮想端末姓名間空白設定',
  '0',
  4,
  '[{"id":"0", "name":"0:全角スペース"}, {"id":"1", "name":"1:半角スペース"}, {"id":"2", "name": "2:区切りなし"}]',
  '装置通信',
  '0',
  '仮想端末で表示される患者名、スタッフ名の姓名の間に入れる空白を設定します。',
  140,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '2'
);
-- #11827 2025.05.20 add 仮想端末姓名結合設定 TDC米沢 end
