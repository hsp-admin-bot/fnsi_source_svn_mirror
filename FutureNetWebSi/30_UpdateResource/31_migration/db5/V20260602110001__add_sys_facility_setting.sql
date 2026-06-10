-- #12462 施設設定マスタ新規
DELETE FROM sys_facility_setting WHERE facility_setting_no='4001';
INSERT INTO "sys_facility_setting" ("facility_setting_no", "setting_name", "default_value", "input_type", "option_value", "function_name", "maker_setting", "description", "disp_order", "reg_date", "up_date", "system_use_disp") VALUES ('4001', '
系列施設扱い対象
', '[]', '7', '[{"master_physical_name":"mst_facility","facility_cd":"nkknkk"}]', '患者情報共有', '0', '施設同士相互系列施設扱い対象を設定することで、患者情報共有にて、自施設合意、共有先・元合意、患者合意の暗黙な了承を得たこと扱いとします。', '149', CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3), '2');