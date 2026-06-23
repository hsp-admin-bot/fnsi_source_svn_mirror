delete from mst_machine_record where machine_record_cd in ('F4AC', 'F4AD');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('F4AC','ストロークボリューム確認',now(),now(),'0','6','5');
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model) values ('F4AD','ストロークボリューム確認　報知解除',now(),now(),'0','6','5');
