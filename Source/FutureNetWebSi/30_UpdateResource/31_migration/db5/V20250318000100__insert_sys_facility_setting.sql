-- 治療記録 愁訴処置内の投与薬剤表示 追加
DELETE from ntss.sys_facility_setting where facility_setting_no = '3131';
INSERT INTO "ntss"."sys_facility_setting" ("facility_setting_no", "setting_name", "default_value", "input_type", "option_value", "function_name", "maker_setting", "description", "disp_order", "reg_date", "up_date", "system_use_disp") VALUES ('3131', 'データ種別順ソート設定', '0', '4', '[{"id":"0","name":"0：検査 ＞医療材料 ＞薬剤"},{"id":"1","name":"1：検査 ＞薬剤 ＞医療材料"},{"id":"2","name":"2：医療材料 ＞薬剤 ＞検査"},{"id":"3","name":"3：医療材料 ＞検査 ＞薬剤"},{"id":"4","name":"4：薬剤 ＞医療材料 ＞検査"},{"id":"5","name":"5：薬剤 ＞検査 ＞医療材料"}]', '帳票', '0', '帳票ソートキー「データ種別順」を設定します（ダイアライザは医療材料、調整薬剤は薬剤に含まれます）。', '137', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '3');



