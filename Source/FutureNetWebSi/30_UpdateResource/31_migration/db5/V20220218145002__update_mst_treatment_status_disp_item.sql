UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='sttc_vns_prssr',field_name='rst_weight_info',is_del='0',table_name='ord_main',item_name='静的静脈圧'
	WHERE item_cd=14;
UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='iap_rt',field_name='rst_weight_info',is_del='0',table_name='ord_main',item_name='IAP Ratio'
	WHERE item_cd=47;
UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='ihdf_pll',field_name='rst_weight_info',is_del='0',table_name='ord_main',item_name='IHDF引き残し量'
	WHERE item_cd=48;