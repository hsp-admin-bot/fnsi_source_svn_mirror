DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '113302';


DELETE FROM
  pat_main
WHERE
  facility_cd = '113302';

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330201, '113302');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330202, '113302');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330203, '113302');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330204, '113302');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330205, '113302');
