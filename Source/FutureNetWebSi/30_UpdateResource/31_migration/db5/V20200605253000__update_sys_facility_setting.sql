-- システム施設設定
update 
  sys_facility_setting
set
  setting_name = '透析予定日変更時 一般撮影検査予定変更機能',
  function_name = '一般撮影検査予定変更機能',
  description = '透析予定日変更時に紐付く一般撮影検査依頼への処理を設定します。<br>
    1：変更された透析予定の日付に一般撮影検査依頼の日付を変更します。<br>
    また、透析予定がキャンセルされた場合、一般撮影検査依頼もキャンセルされます。<br>
    2：一般撮影検査依頼をキャンセルします。<br>
    3：一般撮影検査依頼への処理は行いません。'
where facility_setting_no = '1008';

update 
  sys_facility_setting
set
  setting_name = '一般撮影検査依頼変更締切り有無',
  function_name = '一般撮影検査依頼変更締切り有無',
  description = '一般撮影検査依頼を変更する締切り有無を設定します。<br>
    ONにすると変更締切り時刻を過ぎてから一般撮影検査依頼を変更登録する際に警告メッセージが出力されるようになります。'
where facility_setting_no = '1016';

update 
  sys_facility_setting
set
  setting_name = '一般撮影検査依頼変更締切り日数',
  function_name = '一般撮影検査依頼変更締切り日数',
  description = '一般撮影検査依頼を変更する際に何日前まで受付可能かを設定します。'
where facility_setting_no = '1013';

update 
  sys_facility_setting
set
  setting_name = '一般撮影検査依頼変更締切り時間',
  function_name = '一般撮影検査依頼変更締切り時間',
  description = '一般撮影検査依頼を変更する際に何時まで受付可能かを設定します(時分指定)。'
where facility_setting_no = '1014';
