DELETE FROM
  mst_pat_hash
WHERE
  facility_cd = '113302';

INSERT INTO mst_pat_hash(facility_cd, hash_value)
VALUES('113302', 'ABC');
