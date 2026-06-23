--mst_infectionに列を修正
ALTER TABLE ntss.mst_infection ALTER COLUMN standard_infection_cd TYPE varchar USING standard_infection_cd::varchar;
