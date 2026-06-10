DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '312200';

  DELETE FROM
  mst_facility
WHERE
  facility_cd = '312200';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('312200', 'test');
