-- 施設設定マスタ
delete from mst_facility_setting where facility_setting_no = '2001' and facility_cd = '000001';
insert into mst_facility_setting (facility_setting_no, facility_cd, value, reg_date, up_date)values('1001','000001', 1, current_timestamp, current_timestamp);
