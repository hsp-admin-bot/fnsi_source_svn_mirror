
delete from sys_facility_setting where facility_setting_no = '1021';

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
  '1021'
  , '在宅透析患者指示変更のお知らせカテゴリID'
  , null
  , 5
  , '[{"master_physical_name":"mst_pat_event_category"}]'
  , '在宅透析患者用'
  , 0
  , '在宅透析患者指示変更のお知らせのカテゴリIDを設定します。'
  , 21
  , current_timestamp
  , current_timestamp
);