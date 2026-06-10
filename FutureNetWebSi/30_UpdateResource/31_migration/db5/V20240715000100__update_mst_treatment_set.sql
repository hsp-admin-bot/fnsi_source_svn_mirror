WITH setCds AS ( 
	SELECT treatment_set_cd
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '15' 
			AND (ind_cond_info -> '15') ? 'value'
			AND NOT ((ind_cond_info -> '15') ? 'medicine_type')
			AND (ind_cond_info -> '15' ->> 'value' IS  NULL or ind_cond_info -> '15' ->> 'value' = '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{15, medicine_type}', 'null'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);

WITH setCds AS ( 
	SELECT treatment_set_cd
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '15' 
			AND (ind_cond_info -> '15') ? 'value'
			AND NOT ((ind_cond_info -> '15') ? 'medicine_type')
			AND (ind_cond_info -> '15' ->> 'value' IS NOT NULL AND ind_cond_info -> '15' ->> 'value' != '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{15, medicine_type}', '"1"'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);
	
WITH setCds AS ( 
	SELECT treatment_set_cd
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '19' 
			AND (ind_cond_info -> '19') ? 'value'
			AND NOT ((ind_cond_info -> '19') ? 'medicine_type')
			AND (ind_cond_info -> '19' ->> 'value' IS  NULL or ind_cond_info -> '19' ->> 'value' = '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{19, medicine_type}', 'null'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);

WITH setCds AS ( 
	SELECT treatment_set_cd
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '19' 
			AND (ind_cond_info -> '19') ? 'value'
			AND NOT ((ind_cond_info -> '19') ? 'medicine_type')
			AND (ind_cond_info -> '19' ->> 'value' IS NOT NULL AND ind_cond_info -> '19' ->> 'value' != '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{19, medicine_type}', '"1"'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);
	
WITH setCds AS ( 
	SELECT treatment_set_cd
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '25' 
			AND (ind_cond_info -> '25') ? 'value'
			AND NOT ((ind_cond_info -> '25') ? 'medicine_type')
			AND (ind_cond_info -> '25' ->> 'value' IS  NULL or ind_cond_info -> '25' ->> 'value' = '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{25, medicine_type}', 'null'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);

WITH setCds AS ( 
	SELECT treatment_set_cd,ind_cond_info -> '25' ->> 'value' as value
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '25' 
			AND (ind_cond_info -> '25') ? 'value'
			AND NOT ((ind_cond_info -> '25') ? 'medicine_type')
			AND (ind_cond_info -> '25' ->> 'value' IS NOT NULL AND ind_cond_info -> '25' ->> 'value' != '0')
),setCds2 AS ( 
	SELECT treatment_set_cd
	FROM setCds
	INNER JOIN  mst_medicine ms
	ON ms.medicine_cd::TEXT = setCds.value)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{25, medicine_type}', '"1"'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds2);

WITH setCds AS ( 
	SELECT treatment_set_cd,ind_cond_info -> '25' ->> 'value' as value
	FROM mst_treatment_set 
	WHERE 
			ind_cond_info ? '25' 
			AND (ind_cond_info -> '25') ? 'value'
			AND NOT ((ind_cond_info -> '25') ? 'medicine_type')
			AND (ind_cond_info -> '25' ->> 'value' IS NOT NULL AND ind_cond_info -> '25' ->> 'value' != '0')
)
UPDATE mst_treatment_set a
SET ind_cond_info = jsonb_set(ind_cond_info::jsonb, '{25, medicine_type}', '"2"'::jsonb, TRUE)
WHERE a.treatment_set_cd IN (SELECT treatment_set_cd FROM setCds);
