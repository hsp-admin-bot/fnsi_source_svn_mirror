DELETE FROM ntss.mst_coop_distribute
WHERE ctl_no=-1207;

INSERT INTO ntss.mst_coop_distribute
(ctl_no,facility_cd,coop_cd,coop_cd_index,direction,coop_vender,description,is_editable,distribute_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version)
VALUES (-1207,'F_SX','iji_dial','','S','富士通LifeMark SX','医事実績','1','{"protocolInfo": {"host": "192.168.2.104", "port": "5002", "timeout": 60, "protocol": "ijisocket", "retryMax": 3, "sendType": "send", "socket-type": "FUJITSU_Recept", "retryInterval": 10}}','1','0',-1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');
