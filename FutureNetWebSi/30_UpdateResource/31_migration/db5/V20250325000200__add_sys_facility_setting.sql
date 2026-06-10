-- #11626 シェーマ機能のグリッド設定が存在しない
-- シェーマ機能のグリッド設定
DELETE FROM sys_facility_setting WHERE facility_setting_no='3132';
INSERT INTO sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, system_use_disp, reg_date, up_date)
 VALUES ('3132', 'シェーマのグリッド設定', E'10*10\r\n10*15\r\n15*20', 6, '', '患者イベント', 0, 'シェーマのグリッド機能の行列パターンを設定します。<br>改行することにより複数項目を登録できます。<br>行列数入力範囲：1～100<br>範囲外の項目はリストに表示しません。', 138, 2, current_timestamp, current_timestamp );
