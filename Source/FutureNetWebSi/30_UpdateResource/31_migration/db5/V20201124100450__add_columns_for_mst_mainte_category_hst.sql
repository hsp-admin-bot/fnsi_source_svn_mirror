--定期点検項目グループ履歴マスタ詳細追加
ALTER TABLE ntss.mst_mainte_category_hst ADD detail jsonb NULL;
COMMENT ON COLUMN ntss.mst_mainte_category_hst.detail IS '詳細';