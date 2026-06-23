DELETE from ntss.log_table_comment where tbl_name = 'pat_main' AND col_name = 'wheel_chair_cd';

INSERT INTO ntss.log_table_comment(tbl_name,tbl_comment,col_name,col_comment,json_flg,keystep,pk_flg,delete_flg,ord_main_hst_ins_flg) VALUES 
    ('pat_main','患者情報','wheel_chair_cd','車いすコード','0',1,0,NULL,0);
