-- ベース：V20200917170002__add_notification_config_for_sys_system_define.sql
-- 修正内容：檢查結果通知

UPDATE "ntss"."sys_system_define" SET "ctl_no" = '12', "service_cd" = '003', "name" = '通知カテゴリ設定', "value" = '[{"name": "患者情報通知", "category": 10}, {"name": "治療中通知", "category": 20}, {"name": "患者イベント通知", "category": 30}, {"name": "治療スケジュール通知", "category": 40}, {"name": "施設イベント通知", "category": 50}, {"name": "連携通知", "category": 60}, {"name": "マスタ通知", "category": 70}, {"name": "機能遷移通知", "category": 0}, {"name": "検査通知", "category": 80}]', "description" = '個人設定の通知設定にて表示する、通知カテゴリの名称を設定します。', "is_enable" = '1', "up_date" = '2020-03-31 12:01:06.011' WHERE "ctl_no" = '12';
