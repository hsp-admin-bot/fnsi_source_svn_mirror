DELETE from ntss.log_table_comment where tbl_name = 'mst_round_type' AND col_name = 'highlighting';

INSERT INTO ntss.log_table_comment(tbl_name,tbl_comment,col_name,col_comment,json_flg,keystep,pk_flg,delete_flg,ord_main_hst_ins_flg) VALUES 
    ('mst_round_type','種別マスタ','highlighting','強調表示','0',1,0,NULL,0);
