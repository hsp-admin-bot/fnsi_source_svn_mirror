--データ削除
DELETE FROM sys_function WHERE function_cd = '040';
--データの復元
UPDATE sys_function SET disp_order = 10 WHERE function_cd ='014';
UPDATE sys_function SET disp_order = 11 WHERE function_cd ='011';
UPDATE sys_function SET disp_order = 12 WHERE function_cd ='012';
UPDATE sys_function SET disp_order = 13 WHERE function_cd ='015';
UPDATE sys_function SET disp_order = 14 WHERE function_cd ='006';
UPDATE sys_function SET disp_order = 15 WHERE function_cd ='027';
UPDATE sys_function SET disp_order = 16 WHERE function_cd ='016';
UPDATE sys_function SET disp_order = 17 WHERE function_cd ='030';
UPDATE sys_function SET disp_order = 18 WHERE function_cd ='029';
UPDATE sys_function SET disp_order = 19 WHERE function_cd ='020';
UPDATE sys_function SET disp_order = 20 WHERE function_cd ='037';
UPDATE sys_function SET disp_order = 21 WHERE function_cd ='021';
UPDATE sys_function SET disp_order = 22 WHERE function_cd ='022';
UPDATE sys_function SET disp_order = 23 WHERE function_cd ='018';
UPDATE sys_function SET disp_order = 24 WHERE function_cd ='039';
UPDATE sys_function SET disp_order = 25 WHERE function_cd ='019';
UPDATE sys_function SET disp_order = 26 WHERE function_cd ='008';
UPDATE sys_function SET disp_order = 27 WHERE function_cd ='001';
UPDATE sys_function SET disp_order = 28 WHERE function_cd ='034';
UPDATE sys_function SET disp_order = 29 WHERE function_cd ='033';
UPDATE sys_function SET disp_order = 30 WHERE function_cd ='032';
UPDATE sys_function SET disp_order = 31 WHERE function_cd ='005';
UPDATE sys_function SET disp_order = 32 WHERE function_cd ='035';
UPDATE sys_function SET disp_order = 33 WHERE function_cd ='031';
UPDATE sys_function SET disp_order = 34 WHERE function_cd ='036';
UPDATE sys_function SET disp_order = 35 WHERE function_cd ='003';
UPDATE sys_function SET disp_order = 36 WHERE function_cd ='038';
UPDATE sys_function SET disp_order = 37 WHERE function_cd ='002';
--データ変更
UPDATE                    sys_function
SET                     disp_order = disp_order + 1
WHERE                       (disp_order > 9) AND (disp_order < 98);
--データ追加
insert into sys_function(
function_cd, function_name, is_disp , is_del, reg_date , up_date , disp_order, target_facility, is_nkk, system_use_disp
)
values (
'040','スケールベッド',1,0,current_timestamp,current_timestamp,10,NULL,0,2
);

