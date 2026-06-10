ALTER TABLE pat_event 
ALTER COLUMN template_name TYPE VARCHAR(40);

ALTER TABLE pat_event
ALTER COLUMN sub_category_name TYPE VARCHAR(40);

ALTER TABLE pat_event
ALTER COLUMN category_name TYPE VARCHAR(40);

ALTER TABLE mst_pat_event_sub_category
ALTER COLUMN sub_category_name TYPE VARCHAR(40);

ALTER TABLE mst_pat_event_category
ALTER COLUMN category_name TYPE VARCHAR(40);

ALTER TABLE mst_pat_event_data_template
ALTER COLUMN template_name TYPE VARCHAR(40);