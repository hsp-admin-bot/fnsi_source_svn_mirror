update sys_facility_setting set default_value = '1' where facility_setting_no = '1036';
update sys_facility_setting set default_value = '4' where facility_setting_no = '1037';
delete from sys_system_define where ctl_no = 27;
delete from sys_system_define where ctl_no = 28;
insert into sys_system_define(ctl_no,service_cd,name,"value",description,is_enable,up_date) values (27,'003','アプリケーションログ','{"path_output": "/tmp/nksfn-log/app/{0}/{0}.log", "file_pattern": "/tmp/nksfn-log/app/{0}/{0}_%d''{''yyyyMMdd''}''.log"}','アプリケーションログの出力パスとファイル命名規則の設定。','1',now());
insert into sys_system_define(ctl_no,service_cd,name,"value",description,is_enable,up_date) values (28,'003','イベントログ','{"path_output": "/tmp/nksfn-log/event/{0}/{0}.log", "file_pattern": "/tmp/nksfn-log/event/{0}/{0}_%d''{''yyyyMMdd''}''.log"}','イベントログの出力パスとファイル命名規則の設定。','1',now());
