-- システム設定
DELETE FROM sys_system_define Where ctl_no = 12;

INSERT INTO sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  12, 
  '003', 
  '通知カテゴリ設定', 
  '[{"name": "患者情報通知", "category": 10}, {"name": "治療中通知", "category": 20}, {"name": "患者イベント通知", "category": 30}, {"name": "治療スケジュール通知", "category": 40}, {"name": "施設イベント通知", "category": 50}, {"name": "連携通知", "category": 60}, {"name": "マスタ通知", "category": 70}, {"name": "機能遷移通知", "category": 0}, {"name": "検査通知", "category": 80}, {"name": "システム通知","category": 90}, {"name": "帳票印刷通知", "category": 100}]', 
  '個人設定の通知設定にて表示する、通知カテゴリの名称を設定します。', 
  '1', 
  current_timestamp
);
  