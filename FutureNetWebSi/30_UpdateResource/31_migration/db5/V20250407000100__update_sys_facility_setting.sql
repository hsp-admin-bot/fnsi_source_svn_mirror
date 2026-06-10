-- #11700 施設設定の説明文NG
-- 施設設定マスタのNo.130～134 の設定説明を修正
UPDATE sys_facility_setting SET description = '治療状況マップ画面でユーザーが操作せずに自動更新のみが行われた場合、設定により一定時間後に自動的にサインアウトするかどうかを選択できます。<br>0:自動サインアウトする<br>1:自動サインアウトしない', up_date = now() WHERE facility_setting_no = '3124';
UPDATE sys_facility_setting SET description = '治療状況リスト大画面でユーザーが操作せずに自動更新のみが行われた場合、設定により一定時間後に自動的にサインアウトするかどうかを選択できます。<br>0:自動サインアウトする<br>1:自動サインアウトしない', up_date = now() WHERE facility_setting_no = '3125';
UPDATE sys_facility_setting SET description = '治療状況リスト画面でユーザーが操作せずに自動更新のみが行われた場合、設定により一定時間後に自動的にサインアウトするかどうかを選択できます。<br>0:自動サインアウトする<br>1:自動サインアウトしない', up_date = now() WHERE facility_setting_no = '3126';
UPDATE sys_facility_setting SET description = 'チェックリスト画面でユーザーが操作せずに自動更新のみが行われた場合、設定により一定時間後に自動的にサインアウトするかどうかを選択できます。<br>0:自動サインアウトする<br>1:自動サインアウトしない', up_date = now() WHERE facility_setting_no = '3127';
UPDATE sys_facility_setting SET description = '遠隔監視画面でユーザーが操作せずに自動更新のみが行われた場合、設定により一定時間後に自動的にサインアウトするかどうかを選択できます。<br>0:自動サインアウトする<br>1:自動サインアウトしない', up_date = now() WHERE facility_setting_no = '3128';
