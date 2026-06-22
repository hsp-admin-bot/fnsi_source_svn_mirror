DROP INDEX IF EXISTS idx_mst_personal_user_01;
CREATE INDEX idx_mst_personal_user_01 ON mst_personal_user USING btree (facility_cd,user_email_address_1,user_email_address_2);