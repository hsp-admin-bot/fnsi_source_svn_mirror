-- #11318 処方セットマスタ
-- log_table_commentデータ登録
DELETE FROM log_table_comment WHERE tbl_name = 'mst_prescription_set';

insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'prescription_set_cd', '処方セットコード', 0, 1, 1, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'facility_cd', '施設コード', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'prescription_set_name ', '処方セット名', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'set_info', 'セット情報', 1, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'in_hospital_cd_1', '連携コード1', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'in_hospital_cd_2', '連携コード2', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'is_disp', '表示フラグ', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'is_del', '削除フラグ', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'reg_date', '登録日時', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_prescription_set', '処方セットマスタ', 'up_date', '更新日時', 0, 1, 0, 0);
