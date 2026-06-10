DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '213491';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '213491';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('213491', 'test');

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349101, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349102, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349103, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349104, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349105, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349106, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349107, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349108, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349109, '213491', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349110, '213491', '2010-01-01');
