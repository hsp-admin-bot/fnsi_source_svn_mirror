insert into mnt_client_connect
(
ip_address
,facility_cd
,reg_date
,up_date
,server_type
)
values
(
 /*mntClientConnect.ipAddress*/'127.0.0.1'
,/*mntClientConnect.facilityCd*/'000000'
,CURRENT_TIMESTAMP(3)
,CURRENT_TIMESTAMP(3)
,/*mntClientConnect.serverType*/0
)
;
