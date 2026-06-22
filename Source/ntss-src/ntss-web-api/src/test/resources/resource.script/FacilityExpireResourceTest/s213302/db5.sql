DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '213302';

  DELETE FROM
  mst_facility
WHERE
  facility_cd = '213302';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('213302', 'test');

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330001, '213302', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330002, '213302', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330003, '213302', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330004, '213302', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330005, '213302', '2010-01-01');
