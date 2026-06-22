-- システム設定(背景色のカラーコード)の削除
-- 既に登録されている場合はコメントアウトして下さい。
DELETE FROM sys_system_manager WHERE ctl_no = 2;
-- システム設定(背景色のカラーコード)の登録
INSERT INTO sys_system_manager (
  ctl_no, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  2,
  'サインイン画面とサイドコンテンツエリア展開IFの背景色',
  '{"color": "#ffffff"}',
  'サインイン画面とサイドコンテンツエリア展開IFの背景色を設定します。#FFFFFFはシステムの標準色が適用されます。',
  '1',
  current_timestamp
);
