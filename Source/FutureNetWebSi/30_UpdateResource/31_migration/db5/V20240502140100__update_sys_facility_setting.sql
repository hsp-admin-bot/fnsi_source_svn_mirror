-- 有効投薬指示取得期間設定値 option_value.min、description 更新
update sys_facility_setting 
set
    option_value = '[{"min":"-1",  "max":"365"}]'
    , description = replace (description, '0', '-1')
    , up_date = CURRENT_TIMESTAMP 
where
    facility_setting_no = '3008';
