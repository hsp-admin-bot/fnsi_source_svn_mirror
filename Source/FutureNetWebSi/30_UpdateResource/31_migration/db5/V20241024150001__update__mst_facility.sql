DELETE FROM sys_facility_setting WHERE facility_setting_no = '3123';
INSERT INTO sys_facility_setting( 
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
    '3123'
    , '測定患者選択画面の車いすマスタ編集'
    , '0'
    , 4
    , '[{"id":"0","name":"0:管理者のみ表示"},{"id":"1","name":"1:全ユーザ表示"}]'
    , '体重測定・条件送信'
    , 1
    , '測定患者選択画面で車いす編集ボタンを表示するアカウントを設定します。
0：管理者のみ表示
1：全ユーザ表示'
    , 128
    , now()
    , now()
    , '2'
);