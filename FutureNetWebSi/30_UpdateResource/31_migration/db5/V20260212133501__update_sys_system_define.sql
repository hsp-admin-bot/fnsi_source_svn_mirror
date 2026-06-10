-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 37;

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  37, '003', 'DE更新用zipファイルパスデフォルト', '{"path":"ntss-s3-root-service/DE_Updated"}',
  'デバイスエッジ遠隔監視の更新用zipファイルパスのデフォルトを設定。',
  '1', current_timestamp
);
