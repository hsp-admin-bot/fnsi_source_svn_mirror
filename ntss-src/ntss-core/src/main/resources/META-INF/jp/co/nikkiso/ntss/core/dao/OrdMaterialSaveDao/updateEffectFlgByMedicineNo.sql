UPDATE ord_material_save
    set effect_flg = /*effectFlg*/1
WHERE
    supplies_base_no = /*suppliesBaseNo*/0
  AND supplies_source_class = '1'
  -- add 11624 by shiyw 20250415 start
  AND ind_rst_class = '2'
  -- add 11624 by shiyw 20250415 end
  AND medicine_no->>'no' in /*medicineNoList*/()
