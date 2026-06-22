-- 手技マスタと投与タイミングマスタの削除の確認用
-- mst_procedure(手技マスタ)　のデータ更新
--{"code": 1, "name": "静脈注射"}と{"code": 3, "name": "静脈側回路内注射"}, を削除扱いにする
UPDATE
  mst_procedure
SET
  is_disp = '0'
WHERE
  procedure_cd = 1
;
UPDATE
  mst_procedure
SET
  is_del = '1'
WHERE
  procedure_cd = 3
;

-- mst_medicate_timing(投与タイミングマスタ)　のデータ更新
--{"code": 1, "name": "透析後"}と{"code": 2, "name": "透析中"}, を削除扱いにする
UPDATE
  mst_medicate_timing
SET
  is_disp = '0'
WHERE
  medicate_timing_cd = 1
;
UPDATE
  mst_medicate_timing
SET
  is_del = '1'
WHERE
  medicate_timing_cd = 2
;
-- mst_selector(選択肢マスタ)　のデータ更新
UPDATE
  mst_selector
SET
  order_settings = '{"items": [{"code": 3, "name": "透析前"}, {"code": 4, "name": "その他"}, {"code": 5, "name": "透析終了時"}, {"code": 6, "name": "透析終了30分前"}, {"code": 7, "name": "透析終了1時間前"}]}'
WHERE
  master_physical_name = 'mst_medicate_timing'
;
UPDATE
  mst_selector
SET
  order_settings = '{"items": [{"code": 2, "name": "皮下注射"}, {"code": 4, "name": "動脈側回路内注射"}, {"code": 5, "name": "点滴静脈注射"}, {"code": 6, "name": "筋肉注射"}, {"code": 7, "name": "静脈側回路内点滴注射"}, {"code": 8, "name": "動脈側回路内点滴注射"}, {"code": 9, "name": "その他"}]}'
WHERE
  master_physical_name = 'mst_procedure'
;
