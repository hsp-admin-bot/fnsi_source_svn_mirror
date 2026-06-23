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
  '1007'
  , '透析予定日変更時 検査予定変更機能'
  , '3'
  , 4
  , '[{"id":"1","name":"1:検査依頼を透析予定日に変更"},{"id":"2","name":"2:検査依頼キャンセル"},{"id":"3","name":"3:検査依頼変更なし"}]'
  , '検査予定変更機能'
  , 0
  , '透析予定日変更時に紐付く検査依頼への処理を設定します。<br>
    1：変更された透析予定の日付に検査依頼の日付を変更します。<br>
    また、透析予定がキャンセルされた場合、検査依頼もキャンセルされます。<br>
    2：検査依頼をキャンセルします。<br>
    3：検査依頼への処理は行いません。'
    , 7
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
  '1008'
  , '透析予定日変更時 放射線検査予定変更機能'
  , '3'
  , 4
  , '[{"id":"1","name":"1:検査依頼を透析予定日に変更"},{"id":"2","name":"2:検査依頼キャンセル"},{"id":"3","name":"3:検査依頼変更なし"}]'
  , '放射線検査予定変更機能'
  , 0
  , '透析予定日変更時に紐付く放射線検査依頼への処理を設定します。<br>
    1：変更された透析予定の日付に放射線検査依頼の日付を変更します。<br>
    また、透析予定がキャンセルされた場合、放射線検査依頼もキャンセルされます。<br>
    2：放射線検査依頼をキャンセルします。<br>
    3：放射線検査依頼への処理は行いません。'
  , 8
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
  '1009'
  , '検査結果取込 項目コード出力先設定機能'
  , '1'
  , 4
  , '[{"id":"1","name":"1:院内コード１"},{"id":"2","name":"2:院内コード２"},{"id":"3","name":"3:院内コード３"}]'
  , '検査結果取込 項目コード出力先設定'
  , 0
  , '検査結果一覧画面における取り込みファイル：項目コードの出力先を設定します。<br>
    1：項目コードを院内コード１に出力します。<br>
    2：項目コードを院内コード２に出力します。<br>
    3：項目コードを院内コード３に出力します。'
  , 9
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
  '1010'
  , '検査結果検索範囲月'
  , '3'
  , 2
  , '[{"min":"1",  "max":"99"}]', '検査結果検索範囲月'
  , 0
  , '検索結果一覧の検索範囲指定の月数を保持します'
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
  '1011'
  , '検査依頼変更締切り日数'
  , '1'
  , 2
  , '[{"min":"0",  "max":"999"}]'
  , '検査依頼変更締切り日数'
  , 0
  , '検査依頼を変更する際に何日前まで受付可能かを設定します。'
  , 12
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
  '1012'
  , '検査依頼変更締切り時間'
  , '0000'
  , 1
  , ''
  , '検査依頼変更締切り時間'
  , 0
  , '検査依頼を変更する際に何時まで受付可能かを設定します(時分指定)。'
  , 13
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
  '1013'
  , '放射線検査依頼変更締切り日数'
  , '1'
  , 2
  , '[{"min":"0",  "max":"999"}]'
  , '放射線検査依頼変更締切り日数'
  , 0
  , '放射線検査依頼を変更する際に何日前まで受付可能かを設定します。'
  , 15
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
  '1014'
  , '放射線検査依頼変更締切り時間'
  , '0000'
  , 1
  , ''
  , '放射線検査依頼変更締切り時間'
  , 0
  , '放射線検査依頼を変更する際に何時まで受付可能かを設定します(時分指定)。'
  , 16
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
  '1015'
  , '検査依頼変更締切り有無'
  , '0'
  , 3
  , ''
  , '検査依頼変更締切り有無'
  , 0
  , '検査依頼を変更する締切り有無を設定します。<br>
    ONにすると変更締切り時刻を過ぎてから検査依頼を変更登録する際に警告メッセージが出力されるようになります。'
  , 11
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
  '1016'
  , '放射線検査依頼変更締切り有無'
  , '0'
  , 3
  , ''
  , '放射線検査依頼変更締切り有無'
  , 0
  , '放射線検査依頼を変更する締切り有無を設定します。<br>
    ONにすると変更締切り時刻を過ぎてから放射線検査依頼を変更登録する際に警告メッセージが出力されるようになります。'
  , 14
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
  '1017'
  , '性別未設定時検査項目上下限取得設定'
  , '1'
  , 4
  , '[{"id":"1", "name":"1:男性数値使用"},{"id":"2", "name":"2:共通設定値使用"}]'
  , '性別未設定時検査項目上下限取得設定'
  , 0
  , '患者の性別が未設定の場合に検査項目の上限及び下限の値についてどの項目から取得するか設定。未設定時は男性の数値をデフォルトで使用。'
  , 17
  , now()
  , now()
);
