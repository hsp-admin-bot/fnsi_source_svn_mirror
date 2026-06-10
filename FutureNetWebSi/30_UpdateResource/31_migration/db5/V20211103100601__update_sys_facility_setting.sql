UPDATE sys_facility_setting
	SET description='前回検査日を検索する期間を設定します。<br>単位：日。'
WHERE facility_setting_no='3012'
	AND disp_order='112';
	
UPDATE sys_facility_setting
	SET description='(治療状況マップ・リスト共通)自動更新の間隔(秒)を設定します。'
WHERE facility_setting_no='3001'
	AND disp_order='101';