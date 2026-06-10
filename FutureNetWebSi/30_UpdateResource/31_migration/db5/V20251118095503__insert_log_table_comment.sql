DELETE from ntss.log_table_comment where tbl_name = 'mst_job' AND col_name = 'default_notification_settings';

INSERT INTO ntss.log_table_comment(tbl_name,tbl_comment,col_name,col_comment,json_flg,keystep,pk_flg,delete_flg,ord_main_hst_ins_flg) VALUES 
    ('mst_job','職種マスタ','default_notification_settings','デフォルト通知設定','1',1,0,NULL,0);