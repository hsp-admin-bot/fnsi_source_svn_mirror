-- DBB-200si ver.1.6で追加されるのモニタ項目を追加

insert into sys_monitor_item(moni_data_no,moni_data_type,moni_data_name,moni_data_short_name,data_type,decimal_figure,unit,upper,lower,is_disp,vital_monitor_class,conv_item,reg_date,up_date) values ('103',null,'補液回路内圧','補液回路内圧',1,0,'mmHg',580,-320,1,2,null,current_timestamp, current_timestamp);
