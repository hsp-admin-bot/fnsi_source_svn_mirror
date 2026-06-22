DELETE FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = '113300';


TRUNCATE pat_main;

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330001, '113300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330002, '113300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330003, '113300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330004, '113300');

INSERT INTO pat_main(pat_id, facility_cd)
VALUES (11330005, '113300');
