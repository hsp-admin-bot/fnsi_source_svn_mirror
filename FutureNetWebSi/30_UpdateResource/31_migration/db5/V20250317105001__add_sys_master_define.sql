-- #11618 単体アプリダウンロード画面作成
-- マスタ定義
DELETE FROM sys_master_define WHERE master_physical_name='sys_application';

INSERT INTO sys_master_define(master_physical_name, master_name, disp_class, mode, allow_sort, allow_add_record, disp_order, column_info, reg_date, up_date, edit_level, system_use_disp)
 VALUES ('sys_application', 'アプリケーションダウンロード', '2', '2', '0', '0', 1300, '{"fields":[{"type":"string","title":"アプリケーション名","physical_name":"application_name"},{"type":"string","title":"パス","physical_name":"path"},{"type":"string","title":"バージョン","physical_name":"version"},{"type":"string","title":"表示順","physical_name":"disp_order"},{"type":"disp","title":"表示フラグ","physical_name":"is_disp"},{"type":"del","title":"削除フラグ","physical_name":"is_del"}]}', current_timestamp, current_timestamp, '5', '2');
