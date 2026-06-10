-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 1008;

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1008, '003', 'coop-api配信ファイル保持フォルダ', '{"path":"/efs/tmp-report-delivery/"}',
  'coop-apiでの電文作成処理で作成され、電文配信処理で取得されるファイルの一時保存フォルダです。冗長構成の場合、電文作成と電文配信が別々のサーバで実行される可能性がある為、/efs に保存するようにしています。',
  '1', current_timestamp
);
