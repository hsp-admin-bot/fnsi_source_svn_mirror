DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '312201';

  DELETE FROM
  mst_facility
WHERE
  facility_cd = '312201';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('312201', 'test');
