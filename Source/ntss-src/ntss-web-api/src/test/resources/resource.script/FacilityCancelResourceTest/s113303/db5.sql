DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '113303';


DELETE FROM
  pat_main
WHERE
  facility_cd = '113303';

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330301, '113303');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330302, '113303');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330303, '113303');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330304, '113303');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330305, '113303');
