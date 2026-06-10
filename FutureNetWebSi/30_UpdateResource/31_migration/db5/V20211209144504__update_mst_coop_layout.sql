UPDATE "mst_coop_layout" 
SET coop_format = TRIM ( coop_format ) 
WHERE
	coop_format LIKE'% '