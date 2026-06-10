delete from mst_selector;
insert into mst_selector
  (facility_cd,master_physical_name,order_settings)
 values
  ('000001','mst_master1','{"items": [{ "code": 3, "name": "商品C" }, { "code": 2, "name": "商品B" }, { "code": 1, "name": "商品A" }]}'),
  ('000001','mst_master2','{"items": [{ "code": 2, "name": "商品B" }, { "code": 1, "name": "商品A" }]}'),
  ('000001','mst_master3','{"items": [{ "code": 1, "name": "商品A" }]}'),
  ('000001','mst_master4','{"items": [{ "code": 3, "name": "商品C" }]}')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_selector
ADD COLUMN dummy character varying(1) -- ダミー列
;
