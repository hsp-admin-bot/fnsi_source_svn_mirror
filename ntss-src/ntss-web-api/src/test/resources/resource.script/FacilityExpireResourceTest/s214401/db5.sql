DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '214401';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '214401';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('214401', 'test');
