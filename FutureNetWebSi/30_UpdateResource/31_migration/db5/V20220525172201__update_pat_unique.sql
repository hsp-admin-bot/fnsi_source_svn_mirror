UPDATE pat_unique
SET physical_info = regexp_replace(pat_unique.physical_info::TEXT, '\+0900', '+09:00') :: jsonb
WHERE
	pat_unique.physical_info :: TEXT LIKE '%+0900%'