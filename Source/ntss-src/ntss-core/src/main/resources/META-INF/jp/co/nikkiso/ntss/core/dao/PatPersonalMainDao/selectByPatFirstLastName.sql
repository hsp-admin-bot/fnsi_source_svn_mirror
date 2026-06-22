SELECT A.pat_id,A.pat_last_name,A.pat_first_name from
(SELECT
	pat_id,
	personal_info_decrypt(pat_last_name) as pat_last_name,
	personal_info_decrypt(pat_first_name) as pat_first_name
FROM
  pat_personal_main
WHERE
  facility_cd = /* facilityCd */null
AND
  is_del = '0') A
WHERE
CONCAT(A.pat_last_name,A.pat_first_name) LIKE CONCAT('%', REPLACE(REPLACE(REPLACE(/*patName*/'', '	', ''), '　', ''), ' ', ''), '%')


