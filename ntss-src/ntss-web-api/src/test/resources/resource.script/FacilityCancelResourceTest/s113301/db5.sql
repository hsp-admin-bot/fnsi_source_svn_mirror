DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '113301';


DELETE FROM
  pat_main
WHERE
  facility_cd = '113301';

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330101, '113301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330102, '113301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330103, '113301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330104, '113301');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330105, '113301');
