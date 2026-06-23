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
  '1019'
  , '感染症検査結果反映時 陽性結果値群'
  , '+'
  , 1
  , ''
  , '感染症陽性結果値群'
  , 0
  , '検査結果の手入力やファイル取り込みを行った際、感染症の検査結果を<br>
    患者の感染症情報に陽性として反映させるための結果値群です。<br>
    複数指定する場合はカンマ区切りで記載します。<br>
    (入力例) +,++,+++'
    , 10
    , now()
    , now()
);

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
  '1020'
  , '感染症検査結果反映時 陰性結果値群'
  , '-'
  , 1
  , ''
  , '感染症陰性結果値群'
  , 0
  , '検査結果の手入力やファイル取り込みを行った際、感染症の検査結果を<br>
    患者の感染症情報に陰性として反映させるための結果値群です。<br>
    複数指定する場合はカンマ区切りで記載します。<br>
    (入力例) -,-,---'
    , 11
    , now()
    , now()
);