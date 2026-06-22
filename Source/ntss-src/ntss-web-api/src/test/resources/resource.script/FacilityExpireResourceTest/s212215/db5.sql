DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '212215';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '212215';

-- 前月データとして登録
INSERT INTO mnt_facility_cancel_manage (
ctl_no
, facility_cd
, proc_class
, proc_period
, st_date
, stats
, proc_status
, is_disp
, is_del
, reg_date
, up_date

) VALUES (
-10
, '212215'
, '2'
, 1
, '2020-07-01'
, '[{"end": "2020-08-25T15:37:10.054+09:00", "start": "2020-08-25T15:37:10.049+09:00", "amount": 0, "db_name": "db4", "deleted": 0, "db_class": 1, "has_is_del": true, "table_name": "mst_pat_hash", "time_column_name": "up_date", "alias_column_name": null}, {"end": "2020-08-25T15:37:39.690+09:00", "start": "2020-08-25T15:37:39.686+09:00", "amount": 0, "db_name": "db5", "deleted": 0, "db_class": 2, "has_is_del": true, "table_name": "pat_main", "time_column_name": "up_date", "alias_column_name": null}, {"end": "2020-08-25T15:37:41.728+09:00", "start": "2020-08-25T15:37:41.723+09:00", "amount": 0, "db_name": "db6", "deleted": 0, "db_class": 3, "has_is_del": true, "table_name": "pat_insurance", "time_column_name": "up_date", "alias_column_name": null}]'
, '9'
, '1'
, '0'
, now()
, now());

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('212215', 'test');
