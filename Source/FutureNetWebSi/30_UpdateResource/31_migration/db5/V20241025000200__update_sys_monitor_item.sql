update sys_monitor_item set is_disp = '1' where moni_data_no in ('81','85','86','95','96');

delete from sys_monitor_item where moni_data_no in ('110','111','112','113','114','115','116','117','A99','D99','R99');
