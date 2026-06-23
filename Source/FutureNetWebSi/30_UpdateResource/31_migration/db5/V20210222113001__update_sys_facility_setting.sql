DELETE FROM "sys_facility_setting" WHERE "facility_setting_no" in ('3004');

--V20201124100493__add_sys_facility_setting.sql
-- 修正内容：帳票未指定時のデフォルト帳票
INSERT INTO "ntss"."sys_facility_setting"("facility_setting_no", "setting_name", "default_value", "input_type", "option_value", "function_name", "maker_setting", "description", "disp_order", "reg_date", "up_date", "system_use_disp") VALUES ('3004', '帳票未指定時のデフォルト帳票', '0', '8', '', '帳票', '0', '', '117', '2021-02-03 16:24:48.283', '2021-02-03 16:24:48.283', '2');
