delete from sys_facility_setting where facility_setting_no = '1017';

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
  '1017'
  , '性別不明患者の正常範囲参照設定'
  , '1'
  , 4
  , '[{"id":"1", "name":"1:男性数値使用"},{"id":"2", "name":"2:女性数値使用"}]'
  , '検査結果'
  , 0
  , '患者の性別が「不明」の場合に参照する検査項目の正常値範囲を設定。<br>「1:男性数値使用」に設定した場合、正常値（男性）を参照。<br>「2:女性数値使用」に設定した場合、正常値（女性）を参照。'
  , 19
  , now()
  , now()
);
