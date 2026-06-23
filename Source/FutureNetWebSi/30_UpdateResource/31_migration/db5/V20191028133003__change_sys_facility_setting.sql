delete from sys_facility_setting where facility_setting_no = '1009';

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
  '1009'
  , '検査結果取込時院内コード選択'
  , '1'
  , 4
  , '[{"id":"1","name":"1:院内コード１"},{"id":"2","name":"2:院内コード２"},{"id":"3","name":"3:院内コード３"}]'
  , '検査結果取込時項目コード設定'
  , 0
  , '検査結果を取込時にマスタを参照する際の院内コードの指定<BR>  1：院内コード1、2：院内コード2、3：院内コード3'
  , 9
  , now()
  , now()
);
