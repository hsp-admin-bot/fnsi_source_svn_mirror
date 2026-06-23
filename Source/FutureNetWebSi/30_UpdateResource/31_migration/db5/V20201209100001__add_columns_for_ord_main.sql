--治療情報に最終更新指示者ID追加 
ALTER TABLE ntss.ord_main ADD up_ind_user_id bigint NULL;	
COMMENT ON COLUMN ntss.ord_main.up_ind_user_id IS '最終更新指示者ID';
--治療情報に最終更新者ID追加 
ALTER TABLE ntss.ord_main ADD up_user_id bigint NULL;	
COMMENT ON COLUMN ntss.ord_main.up_user_id IS '最終更新者ID';