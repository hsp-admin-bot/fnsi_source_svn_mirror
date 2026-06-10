INSERT INTO sys_facility_setting(
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date,
  system_use_disp
) VALUES (
  '3000',
  '体重計モード・スケジュール変更設定',
  '0',
  4,
  '[{"id":"0","name":"0:変更不可"},{"id":"1","name":"1:変更可"}]',
  '体重測定・条件送信',
  0,
  '体重計モード・スケジュール変更設定。<br>0：変更不可　デフォルト<br>1：変更可',
  100,
  now(),
  now(),
  '3'
);
--検査依頼 追加选项 4：上記設定項目を手動で選択
UPDATE "ntss"."sys_facility_setting" SET "option_value" = '[{"id":"1","name":"1:検査依頼を透析予定日に変更"},{"id":"2","name":"2:検査依頼キャンセル"},{"id":"3","name":"3:検査依頼変更なし"},{"id":"4","name":"4：上記設定項目を手動で選択"}]', "description" = '透析予定日変更時に紐付く検査依頼への処理を設定します。<br>1：変更された透析予定の日付に検査依頼の日付を変更します。<br>また、透析予定がキャンセルされた場合、検査依頼もキャンセルされます。<br>2：検査依頼をキャンセルします。<br>3：検査依頼への処理は行いません。<br>4：上記設定項目を手動で選択。' WHERE "facility_setting_no" = '1007';
--検査結果項目を追加
delete from "ntss"."sys_facility_setting" where facility_setting_no = '3003';
INSERT INTO "ntss"."sys_facility_setting"("facility_setting_no", "setting_name", "default_value", "input_type", "option_value", "function_name", "maker_setting", "description", "disp_order", "reg_date", "up_date", "system_use_disp") VALUES ('3003', '検査結果ファイル取込時患者ID判定設定', '1', '4', '[{"id":"1","name":"1:12桁前方ゼロ詰め"},{"id":"2","name":"2:完全一致(前方スペース詰め)"}]', '検査結果', '0', '検査結果ファイル取込時の患者IDの判別方法を設定します。<br>
1:12桁ゼロ詰め。<br> システムに登録している患者IDを12桁0詰めして一致した患者に登録します。”0123”と”123”のような患者が存在した場合、ファイル内の患者ID”000000000123”を対象としたデータはエラーとなります。<br>
2:完全一致(前方スペース詰め)。<br>”0123”と”123”のような患者が存在しても区別して登録します。ファイル内の患者IDが”        0123”、”         123”のように登録されている必要があります。', '59', current_timestamp, current_timestamp, '2');
select * from "ntss"."sys_facility_setting" where facility_setting_no = '3003';
--帳票項目を追加
INSERT INTO "ntss"."sys_facility_setting"("facility_setting_no", "setting_name", "default_value", "input_type", "option_value", "function_name", "maker_setting", "description", "disp_order", "reg_date", "up_date", "system_use_disp") VALUES ('3004', '帳票未指定時のデフォルト帳票', '0', '8', '','帳票', '0', '', '60', current_timestamp, current_timestamp, '2');
insert 
into sys_facility_setting( 
  facility_setting_no
  , setting_name
  , default_value
  , input_type
  , option_value
  , function_name
  , maker_setting
  , description
  , disp_order
  , reg_date
  , up_date
  , system_use_disp
) 
values (
  '3001'
  , '治療状況自動更新間隔 （秒）'
  , '20'
  , 2
  , '[{"min":"20",  "max":"99999999"}]'
  , '治療状況'
  , 0
  , '治療状況の自動更新を有効にした際の更新間隔（秒）を設定します。'
  , 101
  , current_timestamp
  , current_timestamp
  , 3
);
--治療記録
INSERT INTO sys_facility_setting(
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date,
  system_use_disp
) VALUES (
  '3002',
  'チェックリスト変更時の版確定ボタン設定',
  '0',
  4,
  '[{"id":"0","name":"0:無効"},{"id":"1","name":"1:有効"}]',
  '治療記録',
  0,
  '確定済みの実績に紐づくチェックリストを変更した場合、治療記録画面で版確定ボタンの有効／無効を切り替えます。',
  102,
  now(),
  now(),
  '3'
);
--患者イベント変更機能
INSERT INTO sys_facility_setting(
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date,
  system_use_disp
) VALUES (
  '3005',
  '治療スケジュール変更時　患者イベント変更機能',
  '1',
  4,
  '[{"id":"1","name":"1.移動する"},{"id":"2","name":"2.移動しない"},{"id":"3","name":"3.中止"},{"id":"4","name":"4.選択する"}]',
  '患者イベント変更機能',
  0,
  'スケジュール表や患者経過総合ビューアで、治療スケジュール変更時に、対象となる患者の治療日と同一のイベント開始日を一緒に連動させる。<br>連動方法は下記4通りあり、デフォルトは1。<br>1.移動する<br>2.移動しない<br>3.中止<br>4.選択する',
  105,
  now(),
  now(),
  '3'
);
--時分入力項目に対して、入力規則を設定してない
UPDATE ntss.sys_facility_setting SET input_type ='2' ,option_value ='[{"min":"0",  "max":"9999"}]'
WHERE facility_setting_no in ('1012','1014');