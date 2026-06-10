-- add 日常・定期点検項目マスタ  用途   回答パターン   補足コメント有無    初期展開テキスト
ALTER TABLE ntss.mst_mainte_detail ADD mainte_class varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail.mainte_class IS '用途';
ALTER TABLE ntss.mst_mainte_detail ADD ans_pattern varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail.ans_pattern IS '回答パターン';
ALTER TABLE ntss.mst_mainte_detail ADD is_cmt varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail.is_cmt IS '補足コメント有無';
ALTER TABLE ntss.mst_mainte_detail ADD ini_text varchar NULL;
COMMENT ON COLUMN ntss.mst_mainte_detail.ini_text IS '初期展開テキスト';
