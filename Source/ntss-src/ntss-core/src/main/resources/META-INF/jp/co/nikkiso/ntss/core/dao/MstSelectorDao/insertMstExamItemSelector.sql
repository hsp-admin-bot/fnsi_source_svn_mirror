insert into mst_selector
(
  facility_cd 
  , master_physical_name
  , order_settings
  , reg_date
  , up_date
)values
(
  /*facilityCd*/'1',
  /*masterPhysicalName*/'1',
  json_build_object
  ('items',json_build_array(json_build_object('code', /*setCode*/null, 'name', CAST(/*setName*/NULL AS TEXT), 'jlac10Cd', CAST(/*setJlac10Cd*/NULL AS TEXT)))::jsonb )::jsonb,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
;