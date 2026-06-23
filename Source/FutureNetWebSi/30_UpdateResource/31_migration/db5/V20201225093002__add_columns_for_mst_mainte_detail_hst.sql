-- add 日常・定期点検項目マスタ  用途   回答パターン   補足コメント有無    初期展開テキスト
ALTER TABLE ntss.mst_mainte_detail_hst ADD mainte_class varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail_hst.mainte_class IS '用途';
ALTER TABLE ntss.mst_mainte_detail_hst ADD ans_pattern varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail_hst.ans_pattern IS '回答パターン';
ALTER TABLE ntss.mst_mainte_detail_hst ADD is_cmt varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail_hst.is_cmt IS '補足コメント有無';
ALTER TABLE ntss.mst_mainte_detail_hst ADD ini_text varchar NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail_hst.ini_text IS '初期展開テキスト';