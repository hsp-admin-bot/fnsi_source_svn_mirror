DELETE FROM
  mst_pat_hash
WHERE
  facility_cd = '213301';

INSERT INTO mst_pat_hash(facility_cd, hash_value, up_date)
VALUES('213301', 'ABC', '2020-01-01');
