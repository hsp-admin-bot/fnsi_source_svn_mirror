DELETE from ntss.log_table_comment where tbl_name = 'mst_facility_hash' AND col_name = 'is_signin_disp';
    
INSERT INTO ntss.log_table_comment(tbl_name,tbl_comment,col_name,col_comment,json_flg,keystep,pk_flg,delete_flg,ord_main_hst_ins_flg) VALUES 
    ('mst_facility_hash','施設マスタハッシュ','is_signin_disp','サインインIF表示設定','0',1,0.0,NULL,0.0);
