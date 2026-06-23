
delete from sys_facility_setting where facility_setting_no = '1039';

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
  '1039'
  , '空きベッド候補切替指示期間(日)'
  , '29'
  , 2
  , '[{"min":"0",  "max":"365"}]'
  , '患者経過総合ビューア'
  , 0
  , '設定値以上の指示期間日数の場合、設定No1035の設定に基づいた予定存在ベッドも候補に表示します。<br>設定値未満の指示期間日数の場合、予定が既に存在するベッドは候補としません。'
  , 39
  , current_timestamp
  , current_timestamp
);
