-- 本番環境へはReMS_対応にて先行適用する
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('A085','RO装置の送水ポンプ運転時間の設定ができません',now(),now(),'0','2','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF90','外部警報入力1がONになりました',now(),now(),'1','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF91','外部警報入力2がONになりました',now(),now(),'1','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF92','外部警報入力3がONになりました',now(),now(),'1','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF93','外部警報入力4がONになりました',now(),now(),'1','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF94','外部警報入力1がOFFになりました',now(),now(),'0','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF95','外部警報入力2がOFFになりました',now(),now(),'0','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF96','外部警報入力3がOFFになりました',now(),now(),'0','1','4');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('AF97','外部警報入力4がOFFになりました',now(),now(),'0','1','4');


delete from mst_m_notice where machine_record_cd in ('A100','6700','A800');



delete from mst_machine_record where machine_record_cd = 'A100';
delete from mst_machine_record where machine_record_cd = '6700';
delete from mst_machine_record where machine_record_cd = 'A800';


update mst_machine_record set machine_record_message = 'クエン酸熱水消毒不足報知', up_date = now() where machine_record_cd = '6712';
update mst_machine_record set machine_record_message = 'クエン酸熱水消毒温度警報（上限）', up_date = now() where machine_record_cd = '6713';
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('A084','工程信号異常警報（インターロック）',now(),now(),'1','1','4');

