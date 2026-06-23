UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='sttc_vns_prssr',field_name=' rst_weight_info',is_del='0',table_name='ord_main',item_name='静的静脈圧'
	WHERE item_cd=14;
UPDATE ntss.mst_treatment_status_disp_item
	SET field_name=NULL,table_name=NULL
	WHERE item_cd=22;
UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='iap_rt',field_name=' rst_weight_info',is_del='0',table_name='ord_main',item_name=' IAP Rate'
	WHERE item_cd=47;
UPDATE ntss.mst_treatment_status_disp_item
	SET is_disp='1',json_key_name='ihdf_pll',field_name=' rst_weight_info',is_del='0',table_name='ord_main',item_name='IHDF引き残し量'
	WHERE item_cd=48;
UPDATE ntss.mst_treatment_status_disp_item
	SET field_name=NULL,table_name=NULL
	WHERE item_cd=56;
UPDATE ntss.mst_treatment_status_disp_item
	SET field_name=NULL,table_name=NULL
	WHERE item_cd=57;
UPDATE ntss.mst_treatment_status_disp_item
	SET item_name='透析液流量(治療条件)'
	WHERE item_cd=86;
UPDATE ntss.mst_treatment_status_disp_item
	SET item_name='透析液温度(治療条件)'
	WHERE item_cd=88;
UPDATE ntss.mst_treatment_status_disp_item
	SET item_name='補液温度(治療条件)'
	WHERE item_cd=93;
UPDATE ntss.mst_treatment_status_disp_item
	SET item_name='補液速度(治療条件)'
	WHERE item_cd=94;
