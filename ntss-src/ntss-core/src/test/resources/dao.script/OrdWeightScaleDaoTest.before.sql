insert into ord_weight_scale
(weight_scale_no, ord_no, facility_cd, weight_cd, weight_name, machine_no, machine_name, weight_scale_status, message,
 measure_date, kur_cd, kur_name, bed_cd, bed_name, pat_id, scale_class, scale_mode, scale_value, rst_tare_info, rst_off_water_info,
 weight_value, target_weight_value, off_water_limit, wheel_chair_cd, wheel_chair_name, wheel_chair_weight, user_id, reg_date, up_date)
values
(9999, 0, 'wstest', 0, 'test', 0, 'test', 0, 'test',
 '2000/1/1 00:00:00', 0, 'test', 0, 'test', 0, 0, 0, 51.5, E'{}', E'{}',
 51, 50, 2.5, 0, 'test', 10000, 0, '2000/1/1 00:00:00', '2000/1/1 00:00:00'),
(10000, 0, 'wstest', 0, 'test', 0, 'test', 0, 'test',
 '2000/1/2 00:00:00', 0, 'test', 0, 'test', 0, 0, 0, 51.5, E'{}', E'{}',
 51, 50, 2.5, 0, 'test', 10000, 0, '2000/1/2 00:00:00', '2000/1/2 00:00:00')
 ;