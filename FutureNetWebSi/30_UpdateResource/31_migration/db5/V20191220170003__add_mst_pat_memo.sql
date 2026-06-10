INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '1' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '1');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '2' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '2');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '3' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '3');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '4' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '4');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '5' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '5');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '6' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '6');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '7' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '7');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '8' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '8');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '9' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '9');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '10' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '10');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '11' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '11');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '12' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '12');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '13' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '13');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '14' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '14');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '15' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '15');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '16' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '16');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '17' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '17');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '18' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '18');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '19' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '19');


INSERT INTO mst_pat_memo (facility_cd, pat_memo_no, title, content, reg_date, up_date)
SELECT
  MF.facility_cd AS facility_cd,
  '20' AS pat_memo_no,
  null AS title,
  null AS content,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
WHERE NOT EXISTS (SELECT * FROM mst_pat_memo MPM WHERE MPM.facility_cd = MF.facility_cd AND MPM.pat_memo_no = '20');


