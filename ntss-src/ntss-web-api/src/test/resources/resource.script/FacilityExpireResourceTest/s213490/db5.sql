DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '213490';

DELETE FROM
  mst_facility
WHERE
  facility_cd = '213490';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('213490', 'test');

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349001, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349002, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349003, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349004, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349005, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349006, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21349007, '213490', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (21349008, '213490');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (21349009, '213490');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (21349010, '213490');
