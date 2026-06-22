DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '212213';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '212213';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('212213', 'test');
