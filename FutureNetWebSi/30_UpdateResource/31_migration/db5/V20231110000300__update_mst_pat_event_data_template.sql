-- add 9933 by caiyanan start
UPDATE mst_pat_event_data_template
SET input_params = regexp_replace(input_params::TEXT, '"is_rst_copy": 0', '"is_rst_copy": "0"', 'g')::JSONB
WHERE input_params::jsonb @> '[{"format_class": 7}]'::jsonb
-- add 9933 by caiyanan end