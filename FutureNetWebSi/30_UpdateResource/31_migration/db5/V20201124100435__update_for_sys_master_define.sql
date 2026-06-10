-- 医療材料分類マスタ
-- 分類区分該当なしの文言修正
UPDATE ntss.sys_master_define 
SET combo_data='{"combos":[{"values":[{"text":"未分類","value":0},{"text":"血液回路","value":1},{"text":"穿刺針(SN以外)","value":2},{"text":"穿刺針(SN)","value":3},{"text":"吸着カラム","value":4},{"text":"吸着器","value":5},{"text":"分離器","value":6}],"physical_name":"class_type"},{"values":[{"text":"編集不可","value":"0"},{"text":"編集可","value":"1"}],"physical_name":"is_editable"}]}' 
WHERE master_physical_name='mst_equipment_class';		
