DELETE FROM sys_function_advanced WHERE function_adv_cd = 'A13';
INSERT INTO "ntss"."sys_function_advanced"("function_adv_cd", "function_adv_name", "disp_order", "is_disp", "is_del", "reg_date", "up_date", "target_facility", "is_nkk", "system_use_disp") VALUES ('A13', '施設切替', '13', '1', '0', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL, '0', '2');
