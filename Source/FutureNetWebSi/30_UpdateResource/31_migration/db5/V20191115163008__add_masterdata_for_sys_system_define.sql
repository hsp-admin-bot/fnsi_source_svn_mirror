-- システム設定
DELETE FROM sys_system_define Where ctl_no = 10;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
 (10, '003', '在宅透析前体重入力時データ取得リトライ間隔', '{"interval_second": "30"}', '在宅透析の前体重入力画面で、装置から作成されるord_mainデータの待機時に再取得する待機間隔の値を設定する。指定は秒。', '1', current_timestamp)
;
