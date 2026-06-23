--sys_facility_settingの不要なレコードを削除
DELETE FROM sys_facility_setting where facility_setting_no in ('1001', '1002', '1006');