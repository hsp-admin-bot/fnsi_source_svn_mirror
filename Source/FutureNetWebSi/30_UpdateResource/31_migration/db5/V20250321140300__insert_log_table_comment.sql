--log_table_commentデータ登録
DELETE FROM log_table_comment WHERE tbl_name = 'mst_menu_group';

insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'menu_group_cd', 'メニューグループコード', 0, 1, 1, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'facility_cd', '施設コード', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'menu_group_name ', 'メニューグループ名', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'menu_list', 'メニュー一覧', 1, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'icon_info', 'URL', 1, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'is_disp', '表示フラグ', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'is_del', '削除フラグ', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'reg_date', '登録日時', 0, 1, 0, 0);
insert into log_table_comment(tbl_name, tbl_comment, col_name, col_comment, json_flg, keystep, pk_flg, ord_main_hst_ins_flg) values ('mst_menu_group', 'メニューグループマスタ', 'up_date', '更新日時', 0, 1, 0, 0);
