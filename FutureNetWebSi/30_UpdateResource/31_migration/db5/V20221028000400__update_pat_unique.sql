UPDATE pat_unique
SET physical_info = regexp_replace(physical_info::text, '{"editValue": null, "initValue": null}', 'null')::jsonb
