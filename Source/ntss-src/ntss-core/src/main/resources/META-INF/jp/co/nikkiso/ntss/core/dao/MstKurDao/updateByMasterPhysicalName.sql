update mst_selector
set
  order_settings = /* master_physical_name */null,
  up_date = /* nowDate */null
where
  facility_cd = /*facility_cd*/null
and
  master_physical_name = 'mst_kur'
;