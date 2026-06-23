-- システム設定
DELETE FROM sys_system_define WHERE ctl_no IN (1001, 1002, 1003, 1004, 1005);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1001, '003', '帳票レイアウトデザイナーアプリケーションログ出力先', '{"path":"/efs/{0}/帳票レイアウトデザイナー/"}',
  '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1002, '003', '体重計アプリケーションログ出力先', '{"path":"/efs/{0}/体重計アプリ/"}',
  '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1003, '003', '印刷サーバーアプリケーションログ出力先', '{"path":"/efs/{0}/印刷サーバーアプリ/"}',
  '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1004, '003', '浄化装置通信アプリケーションログ出力先', '{"path":"/efs/{0}/特殊浄化通信アプリ/"}',
  '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1005, '003', '不明アプリケーションログ出力先', '{"path":"/efs/system/不明なアプリケーション/"}',
  '定義外アプリケーションのログファイル出力先を指定する。',
  '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1006, '003', 'デバイスエッジログ出力先', '{"path":"/efs/{0}/デバイスエッジログ"}',
  'デバイスエッジのログファイル出力先を指定する。 ※{0}は施設コードに変換',
  '1', current_timestamp
);