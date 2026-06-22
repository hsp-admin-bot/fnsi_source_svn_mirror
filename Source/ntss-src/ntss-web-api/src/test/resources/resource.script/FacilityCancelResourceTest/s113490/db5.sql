DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '113490';

DELETE FROM
  mst_report
WHERE
  facility_cd = '113490';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '113490';

INSERT INTO mst_facility (
facility_cd, facility_name, reg_date, up_date
) VALUES
('113490', '削除確認用施設', now(), now());

INSERT INTO mst_report (
report_cd, facility_cd, report_name, reg_date, up_date) VALUES
(-100, '113490', '削除確認', now(), now()),
(-101, '113490', '削除確認', now(), now());
