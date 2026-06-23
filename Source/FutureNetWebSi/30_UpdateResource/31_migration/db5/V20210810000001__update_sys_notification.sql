UPDATE sys_notification 
SET help = 'チェックON：通知の画面遷移アイコンで画面遷移すると既読にします。
チェックOFF：通知の画面遷移アイコンで画面遷移しても既読にしません。' 
WHERE
	notification_no = 27;