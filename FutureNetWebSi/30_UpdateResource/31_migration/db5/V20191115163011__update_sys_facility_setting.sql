-- システム施設設定
update sys_facility_setting set option_value = '[{"min":"1",  "max":"99"}]' where facility_setting_no = '1010';
update sys_facility_setting set option_value = '[{"min":"0",  "max":"999"}]' where facility_setting_no = '1011';
update sys_facility_setting set option_value = '[{"min":"0",  "max":"999"}]' where facility_setting_no = '1013';
