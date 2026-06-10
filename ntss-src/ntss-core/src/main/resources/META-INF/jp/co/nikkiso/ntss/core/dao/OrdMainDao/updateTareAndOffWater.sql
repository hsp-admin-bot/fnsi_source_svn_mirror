WITH query1 AS (SELECT rst_dialysis_state FROM ord_main WHERE ord_no = /*ordNo*/0)

UPDATE
  ord_main

SET
/*%if null != tareInfo*/
  ind_tare_info = jsonb_merge_recursive(ind_tare_info, /*tareInfo*/'{}'::jsonb),
  rst_tare_info = 
    CASE
      WHEN query1.rst_dialysis_state = '1' OR query1.rst_dialysis_state = '2' OR query1.rst_dialysis_state = '3' THEN
        jsonb_merge_recursive(jsonb_merge_recursive(rst_tare_info, (json_build_object('before', /*tareInfo*/'{}'::jsonb))::jsonb), json_build_object('after', /*tareInfo*/'{}'::jsonb)::jsonb)
      ELSE
        jsonb_merge_recursive(rst_tare_info, (json_build_object('before', /*tareInfo*/'{}'::jsonb))::jsonb)
     END,
/*%end*/
/*%if null != offWaterInfo*/
	ind_off_water_info = jsonb_merge_recursive(ind_off_water_info, /*offWaterInfo*/'{}'::jsonb),
	rst_off_water_info = 
	  CASE
      WHEN query1.rst_dialysis_state = '1' OR query1.rst_dialysis_state = '2' OR query1.rst_dialysis_state = '3' THEN
        jsonb_merge_recursive(ind_off_water_info, /*offWaterInfo*/'{}'::jsonb)
	    ELSE
	      rst_off_water_info
	  END,
/*%end*/
	up_date = CURRENT_TIMESTAMP
	
FROM
  query1
  
WHERE
  ord_no = /*ordNo*/0 