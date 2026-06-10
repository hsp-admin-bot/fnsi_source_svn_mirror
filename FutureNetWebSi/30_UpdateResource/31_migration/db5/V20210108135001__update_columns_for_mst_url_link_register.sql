--外部リンクメニューマスタ  json 必入力
ALTER TABLE ntss.mst_url_link_register ALTER COLUMN url_info SET DEFAULT '{}'::jsonb;