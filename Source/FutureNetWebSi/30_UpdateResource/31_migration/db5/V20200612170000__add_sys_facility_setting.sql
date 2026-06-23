delete from sys_facility_setting where facility_setting_no = '1050';

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
) 
values (
  '1050'
  , '指示承認設定'
  , '1'
  , 4
  , '[{"id":"1","name":"医師のみ操作"},{"id":"2","name":"医師リスト"},{"id":"3","name":"全ユーザー"}]'
  , '指示受け・指示承認'
  , 0
  , '指示承認設定 <br>​

医師のみ操作：医師のみが編集可能。選択リストも医師のみ <br>​
医師リスト：選択肢が医師のみ。全ユーザー操作可能。<br>​
全ユーザー：選択肢が全ユーザー。操作も全ユーザー可能。​'
    , 50
    , now()
    , now()
);
