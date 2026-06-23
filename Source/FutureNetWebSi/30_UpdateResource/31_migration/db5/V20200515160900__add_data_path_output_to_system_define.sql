insert into sys_system_define(
  ctl_no,
  service_cd,
  name,
  value,
  description,
  is_enable,
  up_date
) 
values (
  27,
  '003',
  'アプリケーションログ',
  '{"path_output":"/opt/ntss-admin-web/log/app/{0}/{0}.log","file_pattern":"/opt/ntss-admin-web/log/app/{0}/{0}_%d''{''yyyyMMdd''}''.log"}',
  'アプリケーションログの出力パスとファイル命名規則の設定。',
  '1',
  now()
), (
  28,
  '003',
  'イベントログ',
  '{"path_output":"/tmp/ntss-admin-web/log/{0}/{0}.log",
  "file_pattern":"/tmp/ntss-admin-web/log/{0}/{0}_%d''{''yyyyMMdd''}''.log"}',
  'イベントログの出力パスとファイル命名規則の設定。',
  '1',
  now()
);

