-- システム設定
DELETE FROM sys_system_define WHERE ctl_no IN (7, 8, 9, 11);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  7, '003', '帳票レイアウトデザイナーアプリケーション最新バージョン', '{"version":"1.0.0.0"}',
  '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  8, '003', '体重計アプリケーション最新バージョン', '{"version":"1.0.0.0"}',
  '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  9, '003', '印刷サーバーアプリケーション最新バージョン', '{"version":"1.0.0.0"}',
  '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  11, '003', '浄化装置通信アプリケーション最新バージョン', '{"version":"1.0.0.0"}',
  '対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する',
  '1', current_timestamp
);