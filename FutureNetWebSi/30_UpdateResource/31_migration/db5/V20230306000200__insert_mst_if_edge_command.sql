delete from "mst_if_edge_command" where "ctl_no" = 12;
INSERT INTO "mst_if_edge_command" ("ctl_no", "command_key", "command", "add_setting", "is_del", "reg_date", "up_date", "processing", "processing_detail") VALUES (12, 'getTodayLog', 'touch /home/ntss/if_edge/conf/getTodayLog', '0', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '取得当日のログ', 'getTodayLogファイルを作成する');
