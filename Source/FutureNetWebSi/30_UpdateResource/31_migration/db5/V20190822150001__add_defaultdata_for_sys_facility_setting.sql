-- システム施設設定
delete from sys_facility_setting where facility_setting_no = '1005';

insert into sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date)  values ('1005', 'カード作成機能', '0', 3, '', 'カード作成機能', 1, '利用者マスタのカード作成列の表示/非表示の設定。（0：OFF、1：ON）<br>　「1：ON」に設定した場合、マスタ編集（利用者マスタ）にカード作成ボタンを表示します。', 5, current_timestamp, current_timestamp );
