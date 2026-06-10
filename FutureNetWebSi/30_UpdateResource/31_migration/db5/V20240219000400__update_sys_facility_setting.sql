UPDATE ntss.sys_facility_setting
SET option_value = '[{"id":"1","name":"1：患者イベントを治療予定日に変更"},{"id":"2","name":"2：患者イベントキャンセル"},{"id":"3","name":"3：患者イベント変更なし"},{"id":"4","name":"4：画面に手動選択"}]',
description = '治療予定日変更時に紐付く患者イベントへの処理を設定します。<br>1：変更された治療予定の日付に患者イベントの日付を変更します。<br>また、治療予定がキャンセルされた場合、患者イベントもキャンセルされます。<br>2：患者イベントをキャンセルします。<br>3：患者イベントへの処理は行いません。<br>4：画面に上記設定項目を手動選択する。',
up_date = CURRENT_TIMESTAMP
WHERE
	"facility_setting_no" = '3005';
