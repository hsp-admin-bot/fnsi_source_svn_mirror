--掲示板のFunctionCdの追加
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('020', '掲示板', '1', '0', current_timestamp, current_timestamp);

--患者カレンダーのFunctionCdの追加
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('024', '患者カレンダー', '1', '0', current_timestamp, current_timestamp);
