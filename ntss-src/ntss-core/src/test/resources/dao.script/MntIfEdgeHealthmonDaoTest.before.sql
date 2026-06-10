DELETE FROM mnt_if_edge_healthmon;

insert into mnt_if_edge_healthmon
(
ctl_no
, facility_cd
, if_edge_no
, healthmon_facility_conn
, healthmon_server_conn
, reg_date
, up_date
)
values(1, '000001', 12
, '{"ini_dial": {"status": "01","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "01", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "01", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
, '{ "status": "01", "moni_time": "2020-01-01 00:00:01" }'
, '2019-12-10 12:50:00'
, '2019-12-10 13:00:03'
);

insert into mnt_if_edge_healthmon
(
ctl_no
, facility_cd
, if_edge_no
, healthmon_facility_conn
, healthmon_server_conn
, reg_date
, up_date
)
values(2, '000011', 3
, '{ "profile": { "status": "01", "type" : "request", "moni_time": "2020-01-01 00:00:01" } }'
, '{ }'
, '2019-12-10 11:50:00'
, '2019-12-10 15:00:03'
);

insert into mnt_if_edge_healthmon
(
ctl_no
, facility_cd
, if_edge_no
, healthmon_facility_conn
, healthmon_server_conn
, reg_date
, up_date
)
values(3, '000021', 99
, '{ }'
, '{ "status": "01", "moni_time": "2019-12-09 15:00:03" }'
, '2019-12-09 11:50:00'
, '2019-12-09 15:00:03'
);

insert into mnt_if_edge_healthmon
(
ctl_no
, facility_cd
, if_edge_no
, healthmon_facility_conn
, healthmon_server_conn
, reg_date
, up_date
)
values(4, '000001', 99
, '{ }'
, '{ "status": "01", "moni_time": "2019-12-08 15:00:03" }'
, '2019-12-08 11:50:00'
, '2019-12-08 15:00:03'
);

DELETE FROM mst_if_edge;
insert into mst_if_edge
(
serial_no
, facility_cd
, if_edge_no
, if_edge_name
, is_disp
, is_del
, setting_date
, delete_date
, memo
, reg_date
, up_date
)
values('1', '000001', 12, 'test1'
, '1', '0', '2019-12-10 12:50:00', NULL, 'memo1'
, '2019-12-10 12:50:00', '2019-12-10 13:00:03'
);

insert into mst_if_edge
(
serial_no
, facility_cd
, if_edge_no
, if_edge_name
, is_disp
, is_del
, setting_date
, delete_date
, memo
, reg_date
, up_date
)
values('2', '000011', 3, 'test2'
, '1', '0', '2019-12-10 11:50:00', NULL, 'memo2'
, '2019-12-10 11:50:00', '2019-12-10 11:50:00'
);

insert into mst_if_edge
(
serial_no
, facility_cd
, if_edge_no
, if_edge_name
, is_disp
, is_del
, setting_date
, delete_date
, memo
, reg_date
, up_date
)
values('3', '000021', 99, 'test3'
, '1', '0', '2019-12-09 11:50:00', NULL, 'memo3'
, '2019-12-09 11:50:00', '2019-12-09 11:50:00'
);

insert into mst_if_edge
(
serial_no
, facility_cd
, if_edge_no
, if_edge_name
, is_disp
, is_del
, setting_date
, delete_date
, memo
, reg_date
, up_date
)
values('4', '000001', 99, 'test4'
, '1', '1', '2019-12-09 11:50:00', NULL, 'memo4'
, '2019-12-09 11:50:00', '2019-12-09 11:50:00'
);
