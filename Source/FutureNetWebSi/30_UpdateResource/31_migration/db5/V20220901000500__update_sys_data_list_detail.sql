-- #6062-装置情報で項目の不足 徐博
update sys_data_list_detail
set master_display_name = replace(master_display_name, 'ダイアライザー血液入口圧自動設定警報監視有無','ダイアライザ入口圧自動設定警報監視有無') ,
function_display_name = replace(master_display_name, 'ダイアライザー血液入口圧自動設定警報監視有無','ダイアライザ入口圧自動設定警報監視有無')
where master_display_name like '%ダイアライザー血液入口圧自動設定警報監視有無%';

update sys_data_list_detail
set master_display_name = replace(master_display_name, 'ダイアライザー気泡抜き時間','ダイアライザ気泡抜き時間') ,
function_display_name = replace(master_display_name, 'ダイアライザー気泡抜き時間','ダイアライザ気泡抜き時間')
where master_display_name like '%ダイアライザー気泡抜き時間%';
