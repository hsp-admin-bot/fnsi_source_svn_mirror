--client_cer_facility施設詳細
ALTER TABLE
  client_cer_facility
ADD COLUMN facility_name character varying(40) --施設名
;

COMMENT ON COLUMN "client_cer_facility"."facility_name" IS E'施設名';
