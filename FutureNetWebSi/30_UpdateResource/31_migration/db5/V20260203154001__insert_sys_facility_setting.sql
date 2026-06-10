-- 機能別患者検索表示列設定
DELETE FROM sys_facility_setting WHERE facility_setting_no='3140';
INSERT 
INTO ntss.sys_facility_setting( 
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
VALUES ( 
    '3140'
    , '機能別患者リスト表示設定'
    , '["1","2","4","6"]'
    , 7
    , '[{"id":"0","name":"0：治療日"},{"id":"1","name":"1：クール"},{"id":"2","name":"2：ベッド"},{"id":"3","name":"3：患者ID"},{"id":"4","name":"4：患者名"},{"id":"5","name":"5：治療ステータス"},{"id":"6","name":"6：回診状態"},{"id":"7","name":"7：治療開始時刻"},{"id":"8","name":"8：治療終了予定時刻"},{"id":"9","name":"9：治療終了時刻"}]'
    , '患者検索'
    , 0
    , 'スケジュール表、治療状況リスト、治療状況マップ、チェックリストから、別機能遷移後に変化する患者リストの表示項目と表示順を設定します。'
    , 148
    , CURRENT_TIMESTAMP
    , CURRENT_TIMESTAMP
    , '2'
);
