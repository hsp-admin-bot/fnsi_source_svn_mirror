UPDATE sys_function SET is_nkk = '1', up_date = now() WHERE function_cd = '003' or function_cd = '038';
UPDATE sys_function SET is_nkk = '0', up_date = now() WHERE function_cd != '003' and function_cd != '038';

UPDATE sys_function SET system_use_disp = '0', up_date = now() WHERE function_cd = '001' or function_cd = '005' or function_cd = '038';
UPDATE sys_function SET system_use_disp = '2', up_date = now() WHERE function_cd != '001' and function_cd != '005' and function_cd != '038';
