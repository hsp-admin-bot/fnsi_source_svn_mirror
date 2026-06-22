SELECT
	cd,
	medicine_type,
	STRING_AGG ( NO, ',' ) AS no_list
FROM
	(
	SELECT DISTINCT
		jsonb_array_elements ( ind_medi_info ) ->> 'cd' AS cd,
		jsonb_array_elements ( ind_medi_info ) ->> 'medicine_type' AS medicine_type,
		jsonb_array_elements ( ind_medi_info ) ->> 'no' AS NO
	FROM
		ord_main
	WHERE
        is_del = '0'
        AND rst_dialysis_state = '0'
        AND facility_cd = /*ordMainRequest.facilityCd*/'009998'
        AND pat_id = /*ordMainRequest.patId*/'000000000001'
        AND treat_date >= /*ordMainRequest.dialysisDateFrom*/'20180220'
        /*%if ordMainRequest.dialysisDateTo != null */
        AND treat_date <= /*ordMainRequest.dialysisDateTo*/'20180226'
        /*%end*/
    UNION ALL
	SELECT DISTINCT
		jsonb_array_elements ( rst_medi_info ) ->> 'cd' AS cd,
		jsonb_array_elements ( rst_medi_info ) ->> 'medicine_type' AS medicine_type,
		jsonb_array_elements ( rst_medi_info ) ->> 'no' AS NO
	FROM
		ord_main
    WHERE
        is_del = '0'
        AND rst_dialysis_state = '0'
        AND facility_cd = /*ordMainRequest.facilityCd*/'009998'
        AND pat_id = /*ordMainRequest.patId*/'000000000001'
        AND treat_date >= /*ordMainRequest.dialysisDateFrom*/'20180220'
        /*%if ordMainRequest.dialysisDateTo != null */
        AND treat_date <= /*ordMainRequest.dialysisDateTo*/'20180226'
        /*%end*/
	) AS A
GROUP BY
	cd,
	medicine_type;
