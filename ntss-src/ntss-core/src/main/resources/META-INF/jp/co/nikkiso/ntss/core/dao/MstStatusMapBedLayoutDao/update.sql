update mst_status_map_bed_layout set
  facility_cd = /*param.facilityCd*/'999999',
  layout_name = /*param.layoutName*/'',
  bed_layout = /*param.bedLayout*/'{}'::jsonb,
  background_image = /*param.backgroundImage*/E'\\000'::bytea,
  is_del = /*param.isDel*/'0',
  is_disp = /*param.isDisp*/'1',
  is_home_dialysis = /*param.isHomeDialysis*/'0',
  up_date = CURRENT_TIMESTAMP
where
  layout_id = /*param.layoutId*/0