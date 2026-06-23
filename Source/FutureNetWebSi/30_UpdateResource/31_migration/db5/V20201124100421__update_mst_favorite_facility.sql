ALTER TABLE ntss.mst_favorite_facility ADD medical_institution_cd varchar(10) NULL;
UPDATE ntss.mst_favorite_facility SET medical_institution_cd=repeat( chr(int4(random()*26)+65),10);
ALTER TABLE ntss.mst_favorite_facility ALTER COLUMN medical_institution_cd SET NOT NULL;

ALTER TABLE ntss.mst_favorite_facility ALTER COLUMN favorite_facility_cd DROP NOT NULL;
COMMENT ON COLUMN ntss.mst_favorite_facility.medical_institution_cd IS '医療機関コード';