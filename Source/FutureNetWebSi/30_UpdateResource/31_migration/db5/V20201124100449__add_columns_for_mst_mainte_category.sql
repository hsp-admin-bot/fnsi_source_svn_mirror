--日常・定期点検項目マスタ詳細追加 
ALTER TABLE ntss.mst_mainte_category ADD detail jsonb NULL;	
COMMENT ON COLUMN ntss.mst_mainte_category.detail IS '詳細';

