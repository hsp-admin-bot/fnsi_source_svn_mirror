update
  ord_material_save
set
  ind_rst_class = '4',
  is_confirm = '1'
where
    facility_cd = /*facilityCd*/'NKKSBR'
  and supplies_base_no in /*ordPrescriptionNos*/(0)
  and supplies_source_class = '4'
  and ind_rst_class = '3'
