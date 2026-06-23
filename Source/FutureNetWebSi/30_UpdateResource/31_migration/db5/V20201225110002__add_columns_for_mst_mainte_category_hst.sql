-- add 日常・定期点検項目グループマスタ  用途
ALTER TABLE ntss.mst_mainte_category_hst ADD mainte_class varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_category_hst.mainte_class IS '用途';
