SELECT 
S1.ord_no,
S1.rst_start_date,
to_char(S1.rst_start_date,'yyyymmddHH24MISS') As rst_start_date_name,
to_char(S1.rst_start_date,'yyyy/mm/dd') || ' ' || S1.rst_kur_name || ' ' || S1.rst_treatment_name As rst_list_name
FROM
ntss.ord_main S1
WHERE
S1.pat_id =  /*patId*/null
AND S1.facility_cd =  /*facilityCd*/null
AND S1.rst_dialysis_state >= '3'
order by S1.rst_start_date DESC
limit 5;