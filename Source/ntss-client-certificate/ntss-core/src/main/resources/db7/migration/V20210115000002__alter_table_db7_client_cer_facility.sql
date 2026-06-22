ALTER TABLE client_cer_facility ADD COLUMN is_provisional character varying(1) NOT NULL;
ALTER TABLE client_cer_facility ADD COLUMN is_delete character varying(1) NOT NULL;