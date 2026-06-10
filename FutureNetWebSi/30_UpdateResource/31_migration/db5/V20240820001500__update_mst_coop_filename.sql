UPDATE mst_coop_filename
SET coop_version = CASE
        facility_cd
        WHEN 'nkknkk' THEN
        'NKK'
        WHEN 'F_hosp' THEN
        'GX'
        WHEN 'N_hosp' THEN
        'HR'
        WHEN 'S_hosp' THEN
        'SSI'
        WHEN 'NEC-iS' THEN
        'IS'
        WHEN 'C_hosp' THEN
        'CSI'
        WHEN 'P_hosp' THEN
        'MED'
END
WHERE
    facility_cd IN ( 'nkknkk', 'F_hosp', 'N_hosp', 'S_hosp', 'NEC-iS', 'C_hosp', 'P_hosp' );
