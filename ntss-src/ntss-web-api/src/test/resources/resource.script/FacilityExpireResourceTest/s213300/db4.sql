DELETE FROM
  mst_pat_hash
WHERE
  facility_cd = '213300';

INSERT INTO mst_pat_hash(facility_cd, hash_value,up_date)
VALUES('213300', 'ABC', '2010-01-01');
