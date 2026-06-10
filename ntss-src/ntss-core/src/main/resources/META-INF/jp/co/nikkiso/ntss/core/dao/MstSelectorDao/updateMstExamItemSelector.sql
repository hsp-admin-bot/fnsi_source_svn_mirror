UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 ('items',order_settings::jsonb->'items' || json_build_array(
   json_build_object('code', /*setCode*/null, 
   'name', CAST(/*setName*/NULL AS TEXT), 'jlac10Cd', CAST(/*setJlac10Cd*/NULL AS TEXT)))::jsonb
 )::jsonb
WHERE 
  facility_cd = /*facilityCd*/'1'
AND
  master_physical_name = /*masterPhysicalName*/'1'
;
