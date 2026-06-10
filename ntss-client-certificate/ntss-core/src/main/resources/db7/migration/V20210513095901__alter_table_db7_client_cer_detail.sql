ALTER TABLE client_cer_detail ADD COLUMN many_facility_cd character varying(200)  NULL;
ALTER TABLE client_cer_detail ADD COLUMN many_facility_name character varying(200)  NULL;
COMMENT ON COLUMN "client_cer_detail"."many_facility_cd" IS E'複数施設CD';
COMMENT ON COLUMN "client_cer_detail"."many_facility_name" IS E'複数施設名';