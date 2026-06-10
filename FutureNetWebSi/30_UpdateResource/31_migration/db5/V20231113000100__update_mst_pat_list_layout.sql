-- add 9225 データリストレイアウトマスタのテンプレート「患者情報1」の診療情報修正 zy start
UPDATE mst_pat_list_layout
SET disp_item_info = regexp_replace( disp_item_info :: TEXT, ', "facility_cd_MstName"', '' ) :: JSONB
WHERE
	template_cd = 3;
UPDATE mst_pat_list_layout
SET disp_item_info = regexp_replace( disp_item_info :: TEXT, '"facility_cd_MstName",', '' ) :: JSONB
WHERE
	template_cd = 3;
UPDATE mst_pat_list_layout
SET disp_item_info = regexp_replace( disp_item_info :: TEXT, '"facility_cd_MstName"', '' ) :: JSONB
WHERE
	template_cd = 3;
-- add 9225 データリストレイアウトマスタのテンプレート「患者情報1」の診療情報修正 zy end
