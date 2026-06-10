DELETE FROM
  mst_pat_hash
WHERE
  facility_cd = '113300';

INSERT INTO mst_pat_hash(facility_cd, hash_value)
VALUES('113300', 'ABC');
