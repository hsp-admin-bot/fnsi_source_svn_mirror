SELECT DISTINCT pat_id
FROM pat_exam_main
WHERE to_char(reg_exam_date, 'YYYYMMDD')  = /*date*/NULL AND is_del = '0'
AND facility_cd = /*facilityCd*/NULL 