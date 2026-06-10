update ntss.sys_data_set set sql = 'WITH A AS (
	SELECT
		pat_id,
		MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
    GROUP BY
        pat_id 
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out
        
    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id 
        AND A.ctl_no = B.ctl_no 
    )
SELECT COUNT
    ( * ) AS COUNT 
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
    ord_main.treat_date BETWEEN @dateFrom 
    AND @dateTo 
    AND in_out.in_out = ''0''
    AND ord_main.facility_cd = @facilityCd 
    AND ord_main.is_del = ''0''
	AND ord_main.rst_dialysis_state = ''0''
    ;' where sql_cd = -11042;
update ntss.sys_data_set set sql = 'WITH A AS (
    SELECT
        pat_id,
        MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    GROUP BY
        pat_id 
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out
        
    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id 
        AND A.ctl_no = B.ctl_no 
    )
SELECT COUNT
    ( * ) AS COUNT 
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
    ord_main.treat_date BETWEEN @dateFrom 
    AND @dateTo 
    AND in_out.in_out = ''1''
    AND ord_main.facility_cd = @facilityCd 
    AND ord_main.is_del = ''0''
	AND ord_main.rst_dialysis_state = ''0''
    ;' where sql_cd = -11041;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0''' where sql_cd = -11023;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0''' where sql_cd = -11022;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''' where sql_cd = -11021;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''' where sql_cd = -11020;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 0 and facility_cd = @facilityCd AND is_del = ''0''' where sql_cd = -11019;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0''' where sql_cd = -11018;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state in (''1'',''2'',''3'',''4'',''5'',''6'') and facility_cd = @facilityCd AND is_del = ''0''' where sql_cd = -11017;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0''' where sql_cd = -11016;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0''' where sql_cd = -11015;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
	AND ordMain.rst_dialysis_state = ''0''' where sql_cd = -11014;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
	AND ordMain.rst_dialysis_state = ''0''' where sql_cd = -11013;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and rst_dialysis_state = ''0''' where sql_cd = -11012;
