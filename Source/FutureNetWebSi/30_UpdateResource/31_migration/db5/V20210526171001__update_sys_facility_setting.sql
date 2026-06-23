-- 設定説明の変更
UPDATE sys_facility_setting SET description = '装置とデバイスエッジの通信中断から復帰時、装置が運転中で治療開始時刻＋実績治療時間＋治療時間判定時間を経過していた場合、治療を終了して未登録運転に移行します。' WHERE facility_setting_no = '2003';
UPDATE sys_facility_setting SET description = '操作範囲詳細画面の「DP=Qd+Qs(補液速度加算)」表示設定 OFF：非表示、ON：表示' WHERE facility_setting_no = '3010';


