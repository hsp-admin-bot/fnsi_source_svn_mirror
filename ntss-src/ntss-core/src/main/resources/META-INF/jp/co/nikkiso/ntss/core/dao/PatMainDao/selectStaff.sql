SELECT
 charge_staff ->> 'staff_cd' AS staff_cd
  FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = /*patId*/1

		AND charge_staff ->> 'is_main' = '1'
		order by charge_staff ->> 'ctl_no' LIMIT 1;
