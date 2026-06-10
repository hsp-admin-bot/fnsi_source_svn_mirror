DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '213300';

  DELETE FROM
  mst_facility
WHERE
  facility_cd = '213300';

INSERT INTO mst_facility (
  facility_cd
  , facility_name
) VALUES ('213300', 'test');

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330001, '213300', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330002, '213300', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330003, '213300', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330004, '213300', '2010-01-01');

INSERT INTO pat_main(pat_id, facility_cd, up_date)
VALUES (21330005, '213300', '2010-01-01');
