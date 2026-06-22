DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '112300';

DELETE FROM mst_coop_facility
WHERE facility_cd = '112300';

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230001, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230002, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230003, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230004, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230005, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230006, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230007, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230008, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230009, '112300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230010, '112300');