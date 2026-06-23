
delete from sys_facility_setting where facility_setting_no = '1035';

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
  '1035'
  , '空きベッド検索除外予定数'
  , '0'
  , 2
  , '[{"min":"0",  "max":"9"}]'
  , '患者経過総合ビューア'
  , 0
  , 'スケジュール登録の各ベッドの予定件数しきい値を設定します。<br>対象ベッドの指定したクールと期間に属する予定件数が設定した値以内の場合、対象ベッドを選択可能とします。'
  , 35
  , current_timestamp
  , current_timestamp
);
