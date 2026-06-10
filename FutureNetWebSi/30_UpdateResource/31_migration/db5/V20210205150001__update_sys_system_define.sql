-- システム設定

-- アプリケーションログ、ログダウンロードのパス変更
DELETE FROM sys_system_define WHERE ctl_no IN (27, 1000);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) values (
  27, '003', 'アプリケーションログ',
  '{"path_output": "/efs/{0}/サーバー/{0}.log", "file_pattern": "/efs/{0}/サーバー/{0}_%d''{''yyyyMMdd''}''.log"}',
  'アプリケーションログの出力パスとファイル命名規則の設定。', '1', current_timestamp
);

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) values (
  1000, '003', 'ログダウンロード',
 '{"path_output": "/efs"}',
  'ログダウンロード', '1', current_timestamp
);