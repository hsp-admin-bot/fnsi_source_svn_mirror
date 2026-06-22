SELECT
      function_cd ,
      function_name,
      print_report_class,
      is_disp,
      is_del,
      reg_date,
      up_date,
      report_setting_no
FROM  sys_report_setting  A
INNER JOIN (
	  SELECT
            jsonb_array_elements((B.use_function->>'func_cds')::JSONB)->>'func_cd'	AS func_cd
      FROM
            mst_facility B
      WHERE
            facility_cd = /* facilityCd */'0'
	 ) C
ON
	 SUBSTR(A.function_cd, 1,3) = C.func_cd
WHERE
      A.is_disp = '1'
AND   A.is_del ='0'
