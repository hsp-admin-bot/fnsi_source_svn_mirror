delete from sys_data_set;
insert into sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
values
(1, 'select * from hoge', 2, '[{
    "data_category": "data_category",
    "data_class": "data_class",
    "data_code": "data_code",
    "data_name": "data_name",
    "field_name": "field_name",
    "conv_table": [{"code": "code", "item": "item", "disp": "disp"}],
    "data_type": "data_type",
    "preview": "preview",
    "disp_format": "disp_format",
    "can_calc": "can_calc",
    "facility_filter_type": "facility_filter_type",
    "facility_table": "facility_table"
}, {"data_code": "pat_name_code", "field_name": "pat_name_name"}]', '3', '{"test1": "value1"}', '{"classes":[4, 5]}', 'memo', '2019-05-29 17:24:00.000', '2019-05-29 17:25:00.000')
,(10, 'select', 9, '[{"test": "value"}]', null, null, null, null, '2019-05-29 17:24:00.000', '2019-05-29 17:25:00.000')
;
