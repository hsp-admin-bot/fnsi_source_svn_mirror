ALTER TABLE ntss.mst_kur ADD mst_user_authentication jsonb NULL;	
COMMENT ON COLUMN ntss.mst_kur.mst_user_authentication IS '担当医情報';	
