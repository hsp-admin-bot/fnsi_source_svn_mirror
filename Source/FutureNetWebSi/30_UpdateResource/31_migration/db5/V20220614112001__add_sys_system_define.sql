-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 1011;

INSERT INTO sys_system_define (
  ctl_no, service_cd, name, value,
  description,
  is_enable, up_date
) VALUES (
  1011, '003', 'ロガー設定更新対象モジュールリスト', '{"10.1.10.11": ["ntss-admin-web", "ntss-client-comm"], "10.1.10.12": ["ntss-alive-moni", "ntss-alive-moni-auto", "ntss-coop-api", "ntss-data-gathering", "ntss-data-gathering-auto", "ntss-device-edge", "ntss-device-edge-updater", "ntss-m-notice", "ntss-web-api"]}',
  'ログ参照画面のボタンから各モジュールにロガー設定更新処理を行う際の宛先を管理します。 ・書式：{ "IPアドレス:8080"：["ntss-admin-web", ・・・], ・・・ } ・設定を元に発行されるRest："http://" +  "IPアドレス:8080" + "/" + モジュール名 + ""/api/logger-reset/flg-on"',
  '1', current_timestamp
);
