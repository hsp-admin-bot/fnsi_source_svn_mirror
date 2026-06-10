select 
	count(*)
from pat_unique,
	jsonb_to_recordset(medical_hst_info) 
	as j1(
		out_come smallint,
		disease_cd bigint
	)
where 
	is_del = '0'
	and pat_id = /*patId*/0
	-- 転帰：3: 治癒
	and j1.out_come != 3
	and j1.disease_cd = /*diseaseCd*/0
;