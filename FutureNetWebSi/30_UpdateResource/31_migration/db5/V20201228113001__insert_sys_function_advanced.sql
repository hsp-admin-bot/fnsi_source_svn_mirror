--施設マスタにて「投薬支援」を追加（「拡張機能」にＯＮ，ＯＦＦを持たせる。）
INSERT INTO sys_function_advanced ( function_adv_cd, function_adv_name, disp_order, is_disp, is_del, reg_date, up_date, is_nkk, system_use_disp )
VALUES
	( 'A10', '投薬支援', '10', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '0', '2' );