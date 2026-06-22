DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '213301';

  DELETE FROM
  mst_facility
WHERE
  facility_cd = '213301';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('213301', 'test');

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330101, '213301', '2020-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330102, '213301', '2020-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330103, '213301', '2020-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330104, '213301', '2020-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330105, '213301', '2020-01-01');
