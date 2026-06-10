--mst_diseaseに列を修正
ALTER TABLE ntss.mst_disease ALTER COLUMN standard_disease_cd TYPE varchar USING standard_disease_cd::varchar;			
