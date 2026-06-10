-- #10419 患者カレンダー表示内容修正
-- 表示区分(disp_class) 列追加
DELETE from ntss.log_table_comment where tbl_name = 'mst_pat_calendar_layout' AND col_name = 'disp_class';

INSERT INTO ntss.log_table_comment(tbl_name,tbl_comment,col_name,col_comment,json_flg,keystep,pk_flg,delete_flg,ord_main_hst_ins_flg) VALUES 
    ('mst_pat_calendar_layout','患者カレンダーレイアウトマスタ','disp_class','表示区分','0',1,0,NULL,0);
