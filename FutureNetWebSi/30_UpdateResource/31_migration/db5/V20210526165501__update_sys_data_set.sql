UPDATE sys_data_set 
SET SQL = 'SELECT count(DISTINCT e.pat_id) AS count
FROM pat_event AS e,
mst_pat_event_sub_category AS s
WHERE date(e.event_start_date) >= @dateFrom
AND date(e.event_start_date) <= @dateTo
AND e.is_del = ''0''
AND s.sub_category_cd = e.sub_category_cd
AND s.is_del = ''0''
AND e.facility_cd = @facilityCd
AND s.facility_cd = @facilityCd
AND s.sub_category_cd = @id' 
WHERE
	sql_cd = '-11038'