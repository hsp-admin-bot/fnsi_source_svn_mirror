SELECT DISTINCT pat_id
FROM pat_event
WHERE replace(event_start_date, '-', '')  = /*date*/NULL AND is_del = '0'
AND facility_cd = /*facilityCd*/NULL AND category_cd = /*cd*/0