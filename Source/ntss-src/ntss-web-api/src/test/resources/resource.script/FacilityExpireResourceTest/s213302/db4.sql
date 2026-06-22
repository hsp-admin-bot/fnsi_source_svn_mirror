DELETE FROM
  mst_pat_hash
WHERE
  facility_cd = '213302';

INSERT INTO mst_pat_hash(facility_cd, hash_value,up_date)
VALUES('213302', 'ABC', '2010-01-01');
