DELETE from ntss.mst_if_edge_command where ctl_no in (11);
INSERT INTO "ntss"."mst_if_edge_command"("ctl_no", "command_key", "command", "add_setting", "is_del", "reg_date", "up_date", "processing", "processing_detail") VALUES (11, 'versionup', 'datapath=DATA_PATH
cp /home/ntss/if_edge/maint/$datapath/files/ntss_if.json /home/ntss/.node-red/ntss_if.json;
cp /home/ntss/if_edge/maint/$datapath/files/ntss_maint.json /home/ntss/.node-red/ntss_maint.json;
cp /home/ntss/if_edge/maint/$datapath/files/setting.config  /home/ntss/if_edge/conf/ifedge_setting.json
cp /home/ntss/if_edge/maint/$datapath/files/ntssif.env /home/ntss/ntss_if_setup/files/ntssif.env;
systemctl stop nodered;systemctl daemon-reload;systemctl restart nodered;systemctl restart ntssifmaint;', '0', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'ファイルアップロードとIFエッジ再起動', 'ファイルアップロードとIFエッジ再起動');
