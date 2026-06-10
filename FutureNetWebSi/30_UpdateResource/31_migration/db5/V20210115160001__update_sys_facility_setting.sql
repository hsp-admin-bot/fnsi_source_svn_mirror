--検査依頼 文言の変更
UPDATE sys_facility_setting
SET option_value = '[{"id":"1","name":"1:検査依頼を透析予定日に変更"},{"id":"2","name":"2:検査依頼キャンセル"},{"id":"3","name":"3:検査依頼変更なし"},{"id":"4","name":"4:上記設定項目を手動で選択"}]'
WHERE
	facility_setting_no = '1007';
