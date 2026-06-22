select
  layout_id
  , facility_cd
  , layout_name
  , bed_layout
  , encode(background_image, 'escape') as background_image
  , is_disp
  , is_del
  , is_home_dialysis
  , reg_date
  , up_date
from
  mst_status_map_bed_layout A
where
  facility_cd = /*facilityCd*/'1'
  and
  is_disp = '1'
  and
  is_del = '0'
;
