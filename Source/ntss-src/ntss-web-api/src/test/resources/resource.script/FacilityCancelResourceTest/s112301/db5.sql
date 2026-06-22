DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '112301';

TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230101, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230102, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230103, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230104, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230105, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230106, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230107, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230108, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230109, '112301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11230110, '112301');